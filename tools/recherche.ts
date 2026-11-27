// Recherche dans le dictionnaire. Même règle que DictionaryCore (Swift) :
// ios/Packages/DictionaryCore/Sources/DictionaryCore/Recherche.swift.
// Les deux sont rejouées sur le même corpus : tools/donnees/requetes-recherche.json.
// Ce fichier ne dépend de rien : le site l'embarque tel quel dans le navigateur.

export type FicheCherchable = { slug: string; mot: string; formes_de_recherche: string[] };

/** Minuscules, sans accent, apostrophes unifiées, ponctuation retirée, espaces simples. */
export function normaliserRequete(texte: string): string {
  return texte
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .toLowerCase()
    .replace(/œ/g, "oe")
    .replace(/æ/g, "ae")
    .replace(/[’‘`ʼ]/g, "'")
    .replace(/\./g, "")
    .replace(/[^a-z0-9']+/g, " ")
    .trim();
}

const MOTS_VIDES = new Set(["de", "du", "des", "le", "la", "les", "un", "une", "au", "aux", "et", "en", "par", "sur", "d", "l"]);

function motsUtiles(texteNormalise: string): string[] {
  return texteNormalise.split(/[ ']/).filter((m) => m.length > 2 && !MOTS_VIDES.has(m));
}

/** Vrai si les deux textes sont à une faute près : une lettre en trop, en moins, changée, ou deux lettres inversées. */
export function aUneFautePres(a: string, b: string): boolean {
  if (a === b) return true;
  const la = a.length;
  const lb = b.length;
  if (Math.abs(la - lb) > 1) return false;
  let i = 0;
  while (i < la && i < lb && a[i] === b[i]) i++;
  if (la === lb) {
    if (a.slice(i + 1) === b.slice(i + 1)) return true;
    return i + 1 < la && a[i] === b[i + 1] && a[i + 1] === b[i] && a.slice(i + 2) === b.slice(i + 2);
  }
  return la > lb ? a.slice(i + 1) === b.slice(i) : a.slice(i) === b.slice(i + 1);
}

function procheDuDebut(requete: string, cible: string): boolean {
  if (aUneFautePres(requete, cible)) return true;
  for (const n of [requete.length - 1, requete.length, requete.length + 1]) {
    if (n >= 3 && n < cible.length && aUneFautePres(requete, cible.slice(0, n))) return true;
  }
  return false;
}

export const LONGUEUR_MINIMALE = 2;
const LONGUEUR_POUR_UNE_FAUTE = 4;

type Entree<F> = { fiche: F; mot: string; motsDuMot: string[]; formes: string[]; motsDesFormes: string[] };

export class IndexDeRecherche<F extends FicheCherchable> {
  private entrees: Entree<F>[];

  constructor(fiches: F[]) {
    this.entrees = fiches.map((fiche) => {
      const mot = normaliserRequete(fiche.mot);
      const formes = fiche.formes_de_recherche.map(normaliserRequete).filter((f) => f.length > 0);
      return { fiche, mot, motsDuMot: motsUtiles(mot), formes, motsDesFormes: formes.flatMap(motsUtiles) };
    });
  }

  /** Rang d'une fiche pour une requête normalisée. Plus petit = meilleur. null = pas de résultat. */
  private rang(q: string, e: Entree<F>): number | null {
    if (e.mot === q) return 0;
    if (e.mot.startsWith(q)) return 1;
    if (e.motsDuMot.some((m) => m.startsWith(q))) return 2;
    if (e.formes.some((f) => f === q)) return 3;
    if (e.formes.some((f) => f.startsWith(q)) || e.motsDesFormes.some((m) => m.startsWith(q))) return 4;
    if (q.length >= LONGUEUR_POUR_UNE_FAUTE) {
      if (procheDuDebut(q, e.mot) || e.motsDuMot.some((m) => procheDuDebut(q, m))) return 5;
      if (e.formes.some((f) => procheDuDebut(q, f))) return 6;
    }
    return null;
  }

  /** Résultats dès 2 lettres. Ordre : début du mot, puis formes de recherche, puis une faute. */
  chercher(requete: string, limite = 20): F[] {
    const q = normaliserRequete(requete);
    if (q.length < LONGUEUR_MINIMALE) return [];
    const trouves: { rang: number; e: Entree<F> }[] = [];
    for (const e of this.entrees) {
      const rang = this.rang(q, e);
      if (rang !== null) trouves.push({ rang, e });
    }
    trouves.sort((a, b) => a.rang - b.rang || (a.e.mot < b.e.mot ? -1 : a.e.mot > b.e.mot ? 1 : 0));
    return trouves.slice(0, limite).map((t) => t.e.fiche);
  }
}
