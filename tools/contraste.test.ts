import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import { contraste, lireLesJetons, paires } from "./contraste.ts";

const racine = new URL("..", import.meta.url).pathname;

test("le calcul de contraste suit la formule WCAG", () => {
  assert.equal(Math.round(contraste(0x000000, 0xffffff)), 21);
  assert.equal(contraste(0x777777, 0x777777), 1);
  assert.ok(Math.abs(contraste(0x767676, 0xffffff) - 4.54) < 0.01);
});

test("les jetons de l'app sont lus", () => {
  const { couleurs, themes } = lireLesJetons(racine);
  assert.ok(Object.keys(couleurs).length >= 12);
  assert.equal(Object.keys(themes).length, 8);
});

for (const p of paires(racine).filter((p) => p.minimum > 0)) {
  test(`contraste : ${p.nom}, au moins ${p.minimum} pour 1`, () => {
    for (const mode of ["clair", "sombre"] as const) {
      const rapport = contraste(p.devant[mode], p.fond[mode]);
      assert.ok(rapport >= p.minimum, `${mode} : ${rapport.toFixed(2)} pour 1`);
    }
  });
}

test("le site utilise les mêmes couleurs que l'app", () => {
  const css = readFileSync(new URL("../site/src/styles/site.css", import.meta.url), "utf8");
  const { couleurs } = lireLesJetons(racine);
  const noms: Record<string, string> = {
    fond: "fond", carte: "carte", bordure: "bordure", bordureForte: "bordure-forte", accent: "accent", surAccent: "sur-accent",
    texte: "texte", texteSecondaire: "texte-secondaire", surlignage: "surlignage", alerteFond: "alerte-fond",
    alerteTexte: "alerte-texte", imageNeutre: "image-neutre",
  };
  for (const [jeton, variable] of Object.entries(noms)) {
    const valeurs = [...css.matchAll(new RegExp(`--${variable}: #([0-9a-f]{6});`, "g"))].map((m) => parseInt(m[1], 16));
    assert.deepEqual(valeurs, [couleurs[jeton].clair, couleurs[jeton].sombre], `--${variable}`);
  }
});
