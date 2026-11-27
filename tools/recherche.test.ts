import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import { lireFiches } from "./build-content.ts";
import { IndexDeRecherche, aUneFautePres, normaliserRequete } from "./recherche.ts";

const racine = new URL("..", import.meta.url).pathname;
const index = new IndexDeRecherche(lireFiches(racine));
const corpus: { requete: string; attendu: string | null; note?: string }[] = JSON.parse(
  readFileSync(new URL("./donnees/requetes-recherche.json", import.meta.url), "utf8"),
);

test("normalise la requête", () => {
  assert.equal(normaliserRequete("  Échéance "), "echeance");
  assert.equal(normaliserRequete("R.I.B."), "rib");
  assert.equal(normaliserRequete("Rendez-vous"), "rendez vous");
  assert.equal(normaliserRequete("l’AAH"), "l'aah");
});

test("reconnaît une faute de distance 1, pas plus", () => {
  assert.ok(aUneFautePres("facture", "factre"));
  assert.ok(aUneFautePres("facture", "factrue"));
  assert.ok(aUneFautePres("facture", "fakture"));
  assert.ok(aUneFautePres("facture", "facturee"));
  assert.ok(!aUneFautePres("facture", "fakturre"));
  assert.ok(!aUneFautePres("facture", "futcare"));
});

test("le début exact du mot passe avant les formes et les fautes", () => {
  const fiches = [
    { slug: "contrat", mot: "Contrat", formes_de_recherche: [] },
    { slug: "bail", mot: "Bail", formes_de_recherche: ["contrat de location"] },
    { slug: "contact", mot: "Contact", formes_de_recherche: [] },
  ];
  const resultats = new IndexDeRecherche(fiches).chercher("contra").map((f) => f.slug);
  assert.deepEqual(resultats, ["contrat", "bail", "contact"]);
});

for (const { requete, attendu } of corpus) {
  test(`corpus : « ${requete} » donne ${attendu ?? "aucun résultat"}`, () => {
    const resultats = index.chercher(requete).map((f) => f.slug);
    if (attendu === null) assert.deepEqual(resultats, []);
    else assert.equal(resultats[0], attendu, `résultats : ${resultats.join(", ") || "aucun"}`);
  });
}
