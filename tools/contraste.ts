// Contraste des couleurs de l'app, lues dans les jetons de style Swift.
// Usage : npx tsx tools/contraste.ts   (affiche le tableau des rapports de contraste)
// Les tests (tools/contraste.test.ts) bloquent si un texte passe sous 4,5 pour 1.
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

export type Couleur = { clair: number; sombre: number };

const JETONS = "ios/Packages/DictionaryUI/Sources/DictionaryUI/Style/Jetons.swift";

/** Lit « public static let nom = dynamique(clair: 0x…, sombre: 0x…) » et les couleurs des thèmes. */
export function lireLesJetons(racine: string): { couleurs: Record<string, Couleur>; themes: Record<string, Couleur> } {
  const source = readFileSync(resolve(racine, JETONS), "utf8");
  const couleurs: Record<string, Couleur> = {};
  for (const m of source.matchAll(/static let (\w+) = dynamique\(clair: 0x([0-9A-Fa-f]{6}), sombre: 0x([0-9A-Fa-f]{6})\)/g)) {
    couleurs[m[1]] = { clair: parseInt(m[2], 16), sombre: parseInt(m[3], 16) };
  }
  const themes: Record<string, Couleur> = {};
  for (const m of source.matchAll(/case "([a-z-]+)": Couleur\.dynamique\(clair: 0x([0-9A-Fa-f]{6}), sombre: 0x([0-9A-Fa-f]{6})\)/g)) {
    themes[m[1]] = { clair: parseInt(m[2], 16), sombre: parseInt(m[3], 16) };
  }
  return { couleurs, themes };
}

function luminance(hex: number): number {
  const canal = (v: number): number => {
    const c = v / 255;
    return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
  };
  return 0.2126 * canal((hex >> 16) & 0xff) + 0.7152 * canal((hex >> 8) & 0xff) + 0.0722 * canal(hex & 0xff);
}

/** Rapport de contraste WCAG entre deux couleurs, de 1 à 21. */
export function contraste(a: number, b: number): number {
  const [haut, bas] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (haut + 0.05) / (bas + 0.05);
}

export type Paire = { nom: string; devant: Couleur; fond: Couleur; minimum: number; nature: "texte" | "element" | "decor" };

/** Les paires réellement utilisées dans l'app. « decor » : bordure légère, validée en l'état, sans minimum imposé. */
export function paires(racine: string): Paire[] {
  const { couleurs: c, themes } = lireLesJetons(racine);
  const texte = (nom: string, devant: Couleur, fond: Couleur): Paire => ({ nom, devant, fond, minimum: 4.5, nature: "texte" });
  const element = (nom: string, devant: Couleur, fond: Couleur): Paire => ({ nom, devant, fond, minimum: 3, nature: "element" });
  return [
    texte("Texte sur le fond", c.texte, c.fond),
    texte("Texte sur une carte", c.texte, c.carte),
    texte("Texte secondaire sur le fond", c.texteSecondaire, c.fond),
    texte("Texte secondaire sur une carte", c.texteSecondaire, c.carte),
    texte("Texte de bouton, vert sur une carte", c.accent, c.carte),
    texte("Texte de bouton, vert sur le fond", c.accent, c.fond),
    texte("Texte sur un bouton plein", c.surAccent, c.accent),
    texte("Phrase en cours de lecture", c.texte, c.surlignage),
    texte("Bandeau « Brouillon non relu »", c.alerteTexte, c.alerteFond),
    element("Image neutre, symbole sur son fond", c.texteSecondaire, c.imageNeutre),
    element("Bordure forte du champ de recherche, sur le fond", c.bordureForte, c.fond),
    element("Bordure forte, sur une carte", c.bordureForte, c.carte),
    element("Trait de la phrase en cours, sur le surlignage", c.accent, c.surlignage),
    ...Object.entries(themes).map(([slug, couleur]) => element(`Image du thème ${slug}, sur une carte`, couleur, c.carte)),
    { nom: "Bordure légère d'une carte, sur le fond", devant: c.bordure, fond: c.fond, minimum: 0, nature: "decor" },
    { nom: "Bordure légère d'une carte, sur la carte", devant: c.bordure, fond: c.carte, minimum: 0, nature: "decor" },
    { nom: "Carte sur le fond, sans bordure", devant: c.carte, fond: c.fond, minimum: 0, nature: "decor" },
  ];
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const fr = (n: number): string => n.toFixed(2).replace(".", ",");
  console.log("| Paire | Clair | Sombre | Minimum |");
  console.log("| --- | --- | --- | --- |");
  for (const p of paires(".")) {
    const minimum = p.minimum > 0 ? `${String(p.minimum).replace(".", ",")} pour 1` : "aucun, décor";
    console.log(`| ${p.nom} | ${fr(contraste(p.devant.clair, p.fond.clair))} | ${fr(contraste(p.devant.sombre, p.fond.sombre))} | ${minimum} |`);
  }
}
