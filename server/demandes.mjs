// Règles du point de collecte, sans réseau ni disque : validation, normalisation, compteurs, limite de débit.
import { createHmac, randomBytes } from "node:crypto";

export const LONGUEUR_MINIMALE = 2;
export const LONGUEUR_MAXIMALE = 40;

/**
 * Valide et normalise un mot demandé.
 * Accepté : un texte court fait de lettres, d'espaces, de tirets et d'apostrophes.
 * Refusé : chiffres, arobase, points… Cela écarte les adresses, les numéros et la plupart des données personnelles.
 * Renvoie le mot normalisé, ou null.
 */
export function normaliserLeMot(brut) {
  if (typeof brut !== "string") return null;
  const mot = brut
    .normalize("NFC")
    .replace(/[’‘`ʼ]/g, "'")
    .replace(/\s+/g, " ")
    .trim()
    .toLocaleLowerCase("fr");
  if (mot.length < LONGUEUR_MINIMALE || mot.length > LONGUEUR_MAXIMALE) return null;
  if (!/^\p{L}[\p{L} '-]*$/u.test(mot)) return null;
  if (/[ '-]{2,}/.test(mot)) return null;
  return mot;
}

/** Les compteurs : un nombre par mot, et le jour de la première et de la dernière demande. Jamais d'heure, jamais d'origine. */
export class Compteurs {
  constructor(initial = {}, { maximumDeMots = 20000 } = {}) {
    this.mots = new Map(Object.entries(initial));
    this.maximumDeMots = maximumDeMots;
  }

  /** Renvoie false si le stockage est plein et que le mot est nouveau. */
  ajouter(mot, jour) {
    const existant = this.mots.get(mot);
    if (existant) {
      existant.nombre += 1;
      existant.dernier_jour = jour;
      return true;
    }
    if (this.mots.size >= this.maximumDeMots) return false;
    this.mots.set(mot, { nombre: 1, premier_jour: jour, dernier_jour: jour });
    return true;
  }

  /** Du plus demandé au moins demandé, puis par ordre alphabétique. */
  liste() {
    return [...this.mots.entries()]
      .map(([mot, c]) => ({ mot, ...c }))
      .sort((a, b) => b.nombre - a.nombre || a.mot.localeCompare(b.mot, "fr"));
  }

  versObjet() {
    return Object.fromEntries(this.mots);
  }
}

/**
 * Limite de débit sans identifiant durable.
 * L'adresse du demandeur n'est jamais gardée : on garde une empreinte calculée avec un sel tiré au hasard,
 * qui vit en mémoire seulement et change à chaque fenêtre. Rien n'est écrit sur disque ni dans un journal.
 */
export class LimiteDeDebit {
  constructor({ parOrigine = 10, auTotal = 300, fenetreMs = 60_000, maintenant = () => Date.now() } = {}) {
    this.parOrigine = parOrigine;
    this.auTotal = auTotal;
    this.fenetreMs = fenetreMs;
    this.maintenant = maintenant;
    this.debut = maintenant();
    this.renouveler();
  }

  renouveler() {
    this.sel = randomBytes(32);
    this.compteurs = new Map();
    this.total = 0;
  }

  /** Vrai si la demande est acceptée. */
  accepter(origine) {
    const t = this.maintenant();
    if (t - this.debut >= this.fenetreMs) {
      this.debut = t;
      this.renouveler();
    }
    if (this.total >= this.auTotal) return false;
    const cle = createHmac("sha256", this.sel).update(String(origine)).digest("base64");
    const n = this.compteurs.get(cle) ?? 0;
    if (n >= this.parOrigine) return false;
    this.compteurs.set(cle, n + 1);
    this.total += 1;
    return true;
  }
}
