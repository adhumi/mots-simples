// Schéma d'une fiche « Mots simples ».
// Source unique de vérité : le contrôle (tools/check-fiches.ts) l'utilise,
// et le site Astro pourra l'importer pour ses collections de contenu.
import { z } from "zod";

export const SCHEMA_VERSION = 1;

export const THEMES = [
  "argent",
  "sante",
  "logement",
  "travail",
  "papiers",
  "justice",
  "transports",
  "vie-quotidienne",
] as const;

/** Nom affiché de chaque thème. Le paquet de contenu, le site et l'app l'utilisent. */
export const NOMS_DES_THEMES: Record<(typeof THEMES)[number], string> = {
  argent: "Argent",
  sante: "Santé",
  logement: "Logement",
  travail: "Travail",
  papiers: "Papiers",
  justice: "Justice",
  transports: "Transports",
  "vie-quotidienne": "Vie quotidienne",
};

export const STATUTS = ["brouillon", "relu", "valide"] as const;

const slug = z
  .string()
  .regex(/^[a-z0-9]+(-[a-z0-9]+)*$/, "slug : minuscules, chiffres et tirets seulement");

const date = z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "date au format AAAA-MM-JJ");

const texte = z.string().trim().min(1);

export const ficheSchema = z
  .object({
    schema: z.literal(SCHEMA_VERSION),
    mot: texte,
    slug,
    prononciation: texte.nullable(),
    theme: z.enum(THEMES),
    statut: z.enum(STATUTS),
    valide_le: date.nullable(),
    definition: z.array(texte).min(1).max(3),
    exemple: texte,
    autres_sens: z
      .array(
        z
          .object({
            definition: z.array(texte).min(1).max(3),
            exemple: texte.nullable().optional(),
          })
          .strict(),
      )
      .max(3),
    a_ne_pas_confondre: z
      .object({ mot: slug, difference: texte })
      .strict()
      .nullable(),
    mots_lies: z.array(slug).max(4),
    formes_de_recherche: z.array(texte).min(1),
    pictogramme: z
      .object({
        source: z.enum(["arasaac", "original"]),
        id: z.number().int().positive().nullable(),
        alt: texte,
      })
      .strict(),
    source_de_reference: z
      .object({
        titre: texte,
        url: z.string().url().startsWith("https://").nullable(),
        consulte_le: date,
      })
      .strict()
      .nullable(),
    notes_de_relecture: z.array(texte),
  })
  .strict();

export type Fiche = z.infer<typeof ficheSchema>;
