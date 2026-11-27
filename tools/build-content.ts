// Génère le paquet de contenu lu par l'app et servi par le site.
// Usage : npm run build:content                    (mode public : fiches « relu » et « valide »)
//         npm run build:content -- --preversion    (toutes les fiches, brouillons compris)
//         options : --out <dossier>  --date AAAA-MM-JJ  --racine <dossier>
// Le format est décrit dans docs/paquet.md.
import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parse } from "yaml";
import { controlerDossier } from "./check-fiches.ts";
import { NOMS_DES_THEMES, SCHEMA_VERSION, THEMES, ficheSchema, type Fiche } from "./schema.ts";

/** Une fiche telle qu'elle sort du dépôt : sans les champs internes. */
export type FichePubliee = Omit<Fiche, "source_de_reference" | "notes_de_relecture" | "a_ne_pas_confondre" | "autres_sens"> & {
  autres_sens: { definition: string[]; exemple: string | null }[];
  /** `nom` est le mot tel qu'on l'écrit, pour l'afficher même s'il n'a pas encore de fiche. */
  a_ne_pas_confondre: { mot: string; nom: string; difference: string } | null;
};

/** Le nom à afficher pour chaque slug : celui de la fiche, sinon celui de content/liste-v1.csv. */
export type Noms = Map<string, string>;

export function lireNoms(racine: string, fiches: Fiche[]): Noms {
  const noms: Noms = new Map();
  const liste = join(racine, "content", "liste-v1.csv");
  if (existsSync(liste)) {
    for (const ligne of readFileSync(liste, "utf8").trim().split(/\r?\n/).slice(1)) {
      const [mot, slug] = ligne.split(",");
      if (mot && slug) noms.set(slug, mot);
    }
  }
  for (const f of fiches) noms.set(f.slug, f.mot);
  return noms;
}

export type Paquet = {
  schema: number;
  version: string;
  genere_le: string;
  preversion: boolean;
  themes: { slug: string; nom: string }[];
  fiches: FichePubliee[];
};

export type Manifeste = {
  schema: number;
  version: string;
  preversion: boolean;
  paquet: string;
  sha256: string;
  taille: number;
};

export type Options = { preversion: boolean; date?: string; noms?: Noms };

function sha256(texte: string | Buffer): string {
  return createHash("sha256").update(texte).digest("hex");
}

/** Lit toutes les fiches du dépôt. Suppose que le contrôle est déjà passé. */
export function lireFiches(racine: string): Fiche[] {
  const dossier = join(racine, "content", "mots");
  return readdirSync(dossier)
    .filter((f) => f.endsWith(".yaml") || f.endsWith(".yml"))
    .map((f) => ficheSchema.parse(parse(readFileSync(join(dossier, f), "utf8"))))
    .sort((a, b) => (a.slug < b.slug ? -1 : a.slug > b.slug ? 1 : 0));
}

/** Une fiche est publiable en public si elle est relue ou validée. En préversion, toutes le sont. */
export function estPubliable(fiche: Pick<Fiche, "statut">, preversion: boolean): boolean {
  return preversion || fiche.statut === "relu" || fiche.statut === "valide";
}

/** Retire les champs internes et fixe l'ordre des clés, pour une sortie stable. */
export function publier(fiche: Fiche, noms: Noms = new Map()): FichePubliee {
  return {
    schema: fiche.schema,
    mot: fiche.mot,
    slug: fiche.slug,
    prononciation: fiche.prononciation,
    theme: fiche.theme,
    statut: fiche.statut,
    valide_le: fiche.valide_le,
    definition: fiche.definition,
    exemple: fiche.exemple,
    autres_sens: fiche.autres_sens.map((s) => ({ definition: s.definition, exemple: s.exemple ?? null })),
    a_ne_pas_confondre: fiche.a_ne_pas_confondre
      ? {
          mot: fiche.a_ne_pas_confondre.mot,
          nom: noms.get(fiche.a_ne_pas_confondre.mot) ?? fiche.a_ne_pas_confondre.mot.replace(/-/g, " "),
          difference: fiche.a_ne_pas_confondre.difference,
        }
      : null,
    mots_lies: fiche.mots_lies,
    formes_de_recherche: fiche.formes_de_recherche,
    pictogramme: { source: fiche.pictogramme.source, id: fiche.pictogramme.id, alt: fiche.pictogramme.alt },
  };
}

/** La date la plus récente portée par les fiches. Sert de date du paquet : elle ne dépend pas de l'horloge. */
function dateDuContenu(fiches: Fiche[]): string {
  const dates = fiches.flatMap((f) => [f.valide_le, f.source_de_reference?.consulte_le ?? null]).filter((d): d is string => !!d);
  return dates.sort().at(-1) ?? "1970-01-01";
}

export function construirePaquet(toutes: Fiche[], options: Options): Paquet {
  const noms = options.noms ?? new Map(toutes.map((f) => [f.slug, f.mot]));
  const fiches = toutes.filter((f) => estPubliable(f, options.preversion)).map((f) => publier(f, noms));
  const themes = THEMES.map((slug) => ({ slug, nom: NOMS_DES_THEMES[slug] }));
  const corps = { schema: SCHEMA_VERSION, preversion: options.preversion, themes, fiches };
  return {
    schema: SCHEMA_VERSION,
    version: sha256(JSON.stringify(corps)).slice(0, 12),
    genere_le: options.date ?? dateDuContenu(toutes),
    preversion: options.preversion,
    themes,
    fiches,
  };
}

export function serialiser(paquet: Paquet): { paquetJson: string; manifestJson: string; manifeste: Manifeste } {
  const paquetJson = JSON.stringify(paquet) + "\n";
  const manifeste: Manifeste = {
    schema: paquet.schema,
    version: paquet.version,
    preversion: paquet.preversion,
    paquet: "paquet.json",
    sha256: sha256(paquetJson),
    taille: Buffer.byteLength(paquetJson, "utf8"),
  };
  return { paquetJson, manifeste, manifestJson: JSON.stringify(manifeste, null, 2) + "\n" };
}

/** Contrôle les fiches, puis écrit paquet.json et manifest.json. Lève une erreur si le contrôle échoue. */
export function genererPaquet(racine: string, sortie: string, options: Options): Manifeste {
  const erreurs = controlerDossier(racine).flatMap((r) =>
    r.problemes.filter((p) => p.niveau === "erreur").map((p) => `${r.fichier} [${p.regle}] ${p.message}`),
  );
  if (erreurs.length > 0) {
    throw new Error(`Le contrôle des fiches échoue, le paquet n'est pas généré :\n${erreurs.join("\n")}`);
  }
  const toutes = lireFiches(racine);
  const noms = options.noms ?? lireNoms(racine, toutes);
  const { paquetJson, manifestJson, manifeste } = serialiser(construirePaquet(toutes, { ...options, noms }));
  mkdirSync(sortie, { recursive: true });
  writeFileSync(join(sortie, "paquet.json"), paquetJson);
  writeFileSync(join(sortie, "manifest.json"), manifestJson);
  return manifeste;
}

function main(): void {
  const args = process.argv.slice(2);
  const valeur = (nom: string): string | undefined => {
    const i = args.indexOf(nom);
    return i >= 0 ? args[i + 1] : undefined;
  };
  if (args.includes("--public") && args.includes("--preversion")) {
    console.error("Choisir --public ou --preversion, pas les deux.");
    process.exit(1);
  }
  const preversion = args.includes("--preversion");
  const date = valeur("--date") ?? dateDepuisEpoch(process.env.SOURCE_DATE_EPOCH);
  if (date && !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    console.error("--date attend le format AAAA-MM-JJ.");
    process.exit(1);
  }
  const racine = resolve(valeur("--racine") ?? ".");
  const sortie = resolve(valeur("--out") ?? join(racine, "dist", "contenu", "v1"));
  try {
    const m = genererPaquet(racine, sortie, { preversion, date });
    const n = JSON.parse(readFileSync(join(sortie, "paquet.json"), "utf8")).fiches.length;
    console.log(
      `Paquet ${preversion ? "de préversion" : "public"} : ${n} fiche(s), version ${m.version}, ${m.taille} octets, dans ${sortie}`,
    );
  } catch (e) {
    console.error((e as Error).message);
    process.exit(1);
  }
}

function dateDepuisEpoch(epoch: string | undefined): string | undefined {
  if (!epoch || !/^\d+$/.test(epoch)) return undefined;
  return new Date(Number(epoch) * 1000).toISOString().slice(0, 10);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
