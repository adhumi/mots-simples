// Contrôle des fiches de content/mots.
// Usage : npm run check            (erreurs bloquantes, avertissements affichés)
//         npm run check -- --strict (les avertissements bloquent aussi)
// Code de sortie : 0 si tout passe, 1 sinon. C'est ce que la CI regarde.
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { basename, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parse } from "yaml";
import { ficheSchema, type Fiche } from "./schema.ts";

export const MAX_MOTS_PAR_PHRASE = 15;
const THEMES_ADMINISTRATIFS = new Set(["argent", "sante", "logement", "travail", "papiers", "justice"]);

export type Probleme = { niveau: "erreur" | "avertissement"; regle: string; message: string };
export type Contexte = {
  /** slugs de la liste de la V1 (content/liste-v1.csv) */
  slugsListe: Set<string>;
  /** slugs des fiches présentes dans content/mots */
  slugsFiches: Set<string>;
  /** thème attendu par slug, d'après la liste */
  themeParSlug: Map<string, string>;
};

/** Minuscules, sans accent, apostrophes droites. */
export function normaliser(texte: string): string {
  return texte
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .replace(/[’`]/g, "'")
    .toLowerCase();
}

export function slugifier(mot: string): string {
  return normaliser(mot)
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/** Coupe un texte en phrases, sur un point, un point d'interrogation ou d'exclamation. */
export function phrases(texte: string): string[] {
  return texte
    .trim()
    .split(/(?<=[.!?])\s+/)
    .map((p) => p.trim())
    .filter((p) => p.length > 0);
}

/** Un mot = un bloc séparé par des espaces qui contient une lettre ou un chiffre. « l'achat » compte pour 1. */
export function compterMots(phrase: string): number {
  return phrase.split(/\s+/).filter((bloc) => /[\p{L}\p{N}]/u.test(bloc)).length;
}

function occurrences(texte: string, mot: string): number {
  const motif = mot.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const re = new RegExp(`(?<![a-z0-9])${motif}(?![a-z0-9])`, "g");
  return (normaliser(texte).match(re) ?? []).length;
}

function controlerPhrase(
  phrase: string,
  champ: string,
  problemes: Probleme[],
): void {
  const n = compterMots(phrase);
  if (n > MAX_MOTS_PAR_PHRASE) {
    problemes.push({
      niveau: "erreur",
      regle: "phrase-trop-longue",
      message: `${champ} : ${n} mots, le maximum est ${MAX_MOTS_PAR_PHRASE} (« ${phrase} »)`,
    });
  }
  if (!/[.!?]$/.test(phrase)) {
    problemes.push({
      niveau: "erreur",
      regle: "ponctuation-finale",
      message: `${champ} : la phrase doit finir par un point (« ${phrase} »)`,
    });
  }
  if (/[()/]|\betc\b/i.test(phrase)) {
    problemes.push({
      niveau: "erreur",
      regle: "signe-interdit",
      message: `${champ} : pas de parenthèse, de barre oblique ni de « etc. » (« ${phrase} »)`,
    });
  }
  if (/\d/.test(phrase)) {
    problemes.push({
      niveau: "avertissement",
      regle: "chiffre",
      message: `${champ} : contient un chiffre. Vérifier qu'il ne s'agit pas d'un montant, d'un délai ou d'un seuil (« ${phrase} »)`,
    });
  }
}

function controlerUnePhrase(texte: string, champ: string, problemes: Probleme[]): void {
  const liste = phrases(texte);
  if (liste.length !== 1) {
    problemes.push({
      niveau: "erreur",
      regle: "une-phrase",
      message: `${champ} : une seule phrase attendue, ${liste.length} trouvées`,
    });
  }
  for (const p of liste) controlerPhrase(p, champ, problemes);
}

/** Contrôle une fiche déjà lue depuis le YAML. `nomFichier` est le nom sans dossier. */
export function controlerFiche(donnees: unknown, nomFichier: string, ctx: Contexte): Probleme[] {
  const problemes: Probleme[] = [];
  const resultat = ficheSchema.safeParse(donnees);
  if (!resultat.success) {
    for (const issue of resultat.error.issues) {
      problemes.push({
        niveau: "erreur",
        regle: "schema",
        message: `${issue.path.join(".") || "(racine)"} : ${issue.message}`,
      });
    }
    return problemes;
  }
  const fiche: Fiche = resultat.data;
  const motNorm = normaliser(fiche.mot);

  // Identité
  if (nomFichier !== `${fiche.slug}.yaml`) {
    problemes.push({ niveau: "erreur", regle: "nom-de-fichier", message: `le fichier doit s'appeler ${fiche.slug}.yaml` });
  }
  if (fiche.slug !== slugifier(fiche.mot)) {
    problemes.push({
      niveau: "erreur",
      regle: "slug",
      message: `slug attendu pour « ${fiche.mot} » : ${slugifier(fiche.mot)}`,
    });
  }
  const themeAttendu = ctx.themeParSlug.get(fiche.slug);
  if (themeAttendu && themeAttendu !== fiche.theme) {
    problemes.push({
      niveau: "avertissement",
      regle: "theme",
      message: `thème « ${fiche.theme} », alors que la liste de la V1 dit « ${themeAttendu} »`,
    });
  }
  if (/^[A-Z]{2,}$/.test(fiche.mot) && !fiche.prononciation) {
    problemes.push({
      niveau: "erreur",
      regle: "prononciation-sigle",
      message: "le mot est un sigle : remplir « prononciation »",
    });
  }

  // Statut
  if (fiche.statut === "valide" && !fiche.valide_le) {
    problemes.push({ niveau: "erreur", regle: "statut", message: "statut « valide » sans date « valide_le »" });
  }
  if (fiche.statut !== "valide" && fiche.valide_le) {
    problemes.push({ niveau: "erreur", regle: "statut", message: "« valide_le » rempli alors que le statut n'est pas « valide »" });
  }

  // Définition
  fiche.definition.forEach((p, i) => controlerUnePhrase(p, `definition[${i}]`, problemes));
  const debut = normaliser(fiche.definition[0]).indexOf(motNorm);
  if (debut < 0 || debut > 10) {
    problemes.push({
      niveau: "erreur",
      regle: "definition-commence-par-le-mot",
      message: `la première phrase doit commencer par le mot (« Une facture est… »)`,
    });
  }
  if (occurrences(fiche.definition.join(" "), motNorm) > 1) {
    problemes.push({
      niveau: "erreur",
      regle: "mot-repete",
      message: `« ${fiche.mot} » revient dans la définition après le début : utiliser « elle », « il », « ce document »`,
    });
  }

  // Exemple
  controlerUnePhrase(fiche.exemple, "exemple", problemes);
  const formes = [fiche.mot, ...fiche.formes_de_recherche].map(normaliser);
  if (!formes.some((f) => occurrences(fiche.exemple, f) > 0)) {
    problemes.push({ niveau: "erreur", regle: "exemple-sans-le-mot", message: "l'exemple doit contenir le mot expliqué" });
  }

  // Autres sens
  fiche.autres_sens.forEach((sens, i) => {
    sens.definition.forEach((p, j) => controlerUnePhrase(p, `autres_sens[${i}].definition[${j}]`, problemes));
    if (sens.exemple) controlerUnePhrase(sens.exemple, `autres_sens[${i}].exemple`, problemes);
  });

  // À ne pas confondre
  if (fiche.a_ne_pas_confondre) {
    const liste = phrases(fiche.a_ne_pas_confondre.difference);
    if (liste.length > 2) {
      problemes.push({ niveau: "erreur", regle: "difference", message: "a_ne_pas_confondre.difference : 2 phrases au plus" });
    }
    for (const p of liste) controlerPhrase(p, "a_ne_pas_confondre.difference", problemes);
    if (fiche.a_ne_pas_confondre.mot === fiche.slug) {
      problemes.push({ niveau: "erreur", regle: "difference", message: "a_ne_pas_confondre.mot ne peut pas être le mot lui-même" });
    }
  }

  // Liens
  const liens = [...fiche.mots_lies, ...(fiche.a_ne_pas_confondre ? [fiche.a_ne_pas_confondre.mot] : [])];
  for (const lien of liens) {
    if (lien === fiche.slug && fiche.mots_lies.includes(lien)) {
      problemes.push({ niveau: "erreur", regle: "lien", message: "mots_lies ne peut pas contenir le mot lui-même" });
    } else if (!ctx.slugsFiches.has(lien) && !ctx.slugsListe.has(lien)) {
      problemes.push({
        niveau: "erreur",
        regle: "lien-inconnu",
        message: `« ${lien} » n'est ni une fiche ni un mot de content/liste-v1.csv`,
      });
    }
  }
  if (new Set(fiche.mots_lies).size !== fiche.mots_lies.length) {
    problemes.push({ niveau: "erreur", regle: "lien", message: "mots_lies contient un doublon" });
  }

  // Source
  if (THEMES_ADMINISTRATIFS.has(fiche.theme) && !fiche.source_de_reference?.url) {
    problemes.push({
      niveau: "avertissement",
      regle: "source",
      message: "pas de source de référence ouverte pour un mot administratif ou de santé",
    });
  }

  return problemes;
}

function lireListe(racine: string): Pick<Contexte, "slugsListe" | "themeParSlug"> {
  const chemin = join(racine, "content", "liste-v1.csv");
  const slugsListe = new Set<string>();
  const themeParSlug = new Map<string, string>();
  if (!existsSync(chemin)) return { slugsListe, themeParSlug };
  const lignes = readFileSync(chemin, "utf8").trim().split(/\r?\n/).slice(1);
  for (const ligne of lignes) {
    // Colonnes : mot,slug,theme,lot,source. Aucun mot de la liste ne contient de virgule.
    const [, slug, theme] = ligne.split(",");
    if (slug) {
      slugsListe.add(slug);
      if (theme) themeParSlug.set(slug, theme);
    }
  }
  return { slugsListe, themeParSlug };
}

export function controlerDossier(racine: string): { fichier: string; problemes: Probleme[] }[] {
  const dossier = join(racine, "content", "mots");
  const fichiers = readdirSync(dossier).filter((f) => f.endsWith(".yaml") || f.endsWith(".yml")).sort();
  const ctx: Contexte = {
    ...lireListe(racine),
    slugsFiches: new Set(fichiers.map((f) => basename(f).replace(/\.ya?ml$/, ""))),
  };
  return fichiers.map((fichier) => {
    let donnees: unknown;
    try {
      donnees = parse(readFileSync(join(dossier, fichier), "utf8"));
    } catch (e) {
      return { fichier, problemes: [{ niveau: "erreur" as const, regle: "yaml", message: `YAML illisible : ${(e as Error).message}` }] };
    }
    return { fichier, problemes: controlerFiche(donnees, fichier, ctx) };
  });
}

function main(): void {
  const args = process.argv.slice(2);
  const strict = args.includes("--strict");
  const racine = resolve(args.find((a) => !a.startsWith("--")) ?? ".");
  const resultats = controlerDossier(racine);
  let erreurs = 0;
  let avertissements = 0;
  for (const { fichier, problemes } of resultats) {
    for (const p of problemes) {
      if (p.niveau === "erreur") erreurs++;
      else avertissements++;
      console.log(`${p.niveau === "erreur" ? "ERREUR" : "AVERT."}  ${fichier}  [${p.regle}]  ${p.message}`);
    }
  }
  console.log(
    `\n${resultats.length} fiche(s) contrôlée(s) : ${erreurs} erreur(s), ${avertissements} avertissement(s).`,
  );
  if (erreurs > 0 || (strict && avertissements > 0)) process.exit(1);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
