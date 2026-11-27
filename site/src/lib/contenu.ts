// Le contenu du site : exactement le paquet que l'app télécharge, dans le même mode.
import { resolve } from "node:path";
import { construirePaquet, lireFiches, lireNoms, serialiser, type FichePubliee } from "../../../tools/build-content.ts";
import { controlerDossier } from "../../../tools/check-fiches.ts";
import { preversion } from "./reglages.ts";

// « astro build » est lancé depuis site/. RACINE_DU_DEPOT permet de le lancer d'ailleurs.
const racine = resolve(process.env.RACINE_DU_DEPOT ?? resolve(process.cwd(), ".."));

const erreurs = controlerDossier(racine).flatMap((r) =>
  r.problemes.filter((p) => p.niveau === "erreur").map((p) => `${r.fichier} [${p.regle}] ${p.message}`),
);
if (erreurs.length > 0) {
  throw new Error(`Le contrôle des fiches échoue, le site n'est pas construit :\n${erreurs.join("\n")}`);
}

const toutes = lireFiches(racine);
export const paquet = construirePaquet(toutes, { preversion, noms: lireNoms(racine, toutes), date: process.env.DATE_DU_CONTENU });
export const { paquetJson, manifestJson } = serialiser(paquet);

export type { FichePubliee };

const collateur = new Intl.Collator("fr", { sensitivity: "base" });

/** Les fiches du mode choisi, par ordre alphabétique. */
export const fiches: FichePubliee[] = [...paquet.fiches].sort((a, b) => collateur.compare(a.mot, b.mot));
export const themes = paquet.themes;

const parSlug = new Map(fiches.map((f) => [f.slug, f]));

export function fiche(slug: string): FichePubliee | undefined {
  return parSlug.get(slug);
}

export function fichesDuTheme(slug: string): FichePubliee[] {
  return fiches.filter((f) => f.theme === slug);
}

export function nomDuTheme(slug: string): string {
  return themes.find((t) => t.slug === slug)?.nom ?? slug;
}

/** Les mots liés qui ont une page dans ce mode. Les autres ne sont pas affichés. */
export function motsLies(f: FichePubliee): FichePubliee[] {
  return f.mots_lies.flatMap((slug) => parSlug.get(slug) ?? []);
}

/** « 2026-12-03 » devient « 3 décembre 2026 ». */
export function dateLisible(iso: string): string {
  return new Intl.DateTimeFormat("fr-FR", { dateStyle: "long", timeZone: "UTC" }).format(new Date(`${iso}T00:00:00Z`));
}

/** Les fiches rangées par première lettre, sans accent. */
export function parLettre(): { lettre: string; fiches: FichePubliee[] }[] {
  const groupes = new Map<string, FichePubliee[]>();
  for (const f of fiches) {
    const lettre = f.mot.normalize("NFD").replace(/\p{M}/gu, "").charAt(0).toUpperCase();
    groupes.set(lettre, [...(groupes.get(lettre) ?? []), f]);
  }
  return [...groupes.entries()].map(([lettre, liste]) => ({ lettre, fiches: liste }));
}
