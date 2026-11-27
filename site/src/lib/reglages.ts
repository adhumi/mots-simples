// Les deux réglages du site, lus dans l'environnement au moment de la construction.
//
// MODE_CONTENU : « preversion » (défaut) montre toutes les fiches, brouillons compris.
//                « public » ne montre que les fiches relues et validées.
// INDEXATION   : « fermee » (défaut) pose le noindex partout : balise dans chaque page, et en-tête HTTP par le serveur.
//                « ouverte » le retire. C'est une décision d'Adrien, au lot 5.

export type Mode = "preversion" | "public";
export type Indexation = "fermee" | "ouverte";

function lire<T extends string>(nom: string, valeurs: readonly T[], defaut: T): T {
  const brut = process.env[nom];
  if (brut === undefined || brut === "") return defaut;
  if (!(valeurs as readonly string[]).includes(brut)) {
    throw new Error(`${nom} doit valoir ${valeurs.join(" ou ")}, pas « ${brut} ».`);
  }
  return brut as T;
}

export const mode: Mode = lire("MODE_CONTENU", ["preversion", "public"] as const, "preversion");
export const indexation: Indexation = lire("INDEXATION", ["fermee", "ouverte"] as const, "fermee");

// Règle éditoriale : un brouillon n'est jamais public. Une préversion indexable est donc refusée.
if (mode === "preversion" && indexation === "ouverte") {
  throw new Error("INDEXATION=ouverte est interdit avec MODE_CONTENU=preversion : un brouillon n'est jamais public.");
}

export const preversion = mode === "preversion";
export const noindex = indexation === "fermee";

/** Identifiant de l'app sur l'App Store, pour le bandeau d'ouverture sur iPhone. Vide tant que l'app n'est pas publiée. */
export const identifiantAppStore: string = process.env.APP_STORE_ID ?? "";

/** Adresse du point de collecte des mots demandés. Vide : la page « Demander un mot » dit que ce n'est pas encore ouvert. */
export const adresseDesDemandes: string = process.env.ADRESSE_DES_DEMANDES ?? "";
