import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import { parse } from "yaml";
import { compterMots, controlerDossier, controlerFiche, phrases, slugifier, type Contexte } from "./check-fiches.ts";

const ctx: Contexte = {
  slugsListe: new Set(["facture", "echeance", "prelevement", "devis", "aah"]),
  slugsFiches: new Set(["facture"]),
  themeParSlug: new Map([["facture", "argent"]]),
};

function modele(): Record<string, any> {
  return parse(readFileSync(new URL("../content/mots/facture.yaml", import.meta.url), "utf8"));
}

function regles(donnees: unknown, fichier = "facture.yaml"): string[] {
  return controlerFiche(donnees, fichier, ctx)
    .filter((p) => p.niveau === "erreur")
    .map((p) => p.regle);
}

test("la fiche modèle passe sans erreur", () => {
  assert.deepEqual(regles(modele()), []);
});

test("tout le dossier content/mots passe sans erreur", () => {
  const erreurs = controlerDossier(new URL("..", import.meta.url).pathname).flatMap((r) =>
    r.problemes.filter((p) => p.niveau === "erreur").map((p) => `${r.fichier} : ${p.message}`),
  );
  assert.deepEqual(erreurs, []);
});

test("compte les mots comme prévu", () => {
  assert.equal(compterMots("Le devis annonce le prix avant l'achat."), 7);
  assert.equal(compterMots("Est-ce compris ?"), 2);
});

test("coupe en phrases", () => {
  assert.equal(phrases("Le devis arrive avant. La facture arrive après.").length, 2);
});

test("slugifie les accents et les apostrophes", () => {
  assert.equal(slugifier("Avis d'imposition"), "avis-d-imposition");
  assert.equal(slugifier("À jeun"), "a-jeun");
  assert.equal(slugifier("Trop-perçu"), "trop-percu");
});

test("refuse une phrase de plus de 15 mots", () => {
  const f = modele();
  f.definition[1] =
    "Elle dit ce que vous avez acheté dans le magasin et aussi combien ça coûte au total.";
  assert.ok(regles(f).includes("phrase-trop-longue"));
});

test("refuse deux phrases dans une même ligne de définition", () => {
  const f = modele();
  f.definition[1] = "Elle dit ce que vous avez acheté. Elle dit le prix.";
  assert.ok(regles(f).includes("une-phrase"));
});

test("refuse le mot répété dans la définition", () => {
  const f = modele();
  f.definition[2] = "La facture dit aussi avant quelle date il faut payer.";
  assert.ok(regles(f).includes("mot-repete"));
});

test("refuse une définition qui ne commence pas par le mot", () => {
  const f = modele();
  f.definition[0] = "Après un achat, vous recevez un document appelé facture.";
  assert.ok(regles(f).includes("definition-commence-par-le-mot"));
});

test("refuse les parenthèses", () => {
  const f = modele();
  f.exemple = "Chaque mois, vous recevez la facture (papier) de votre téléphone.";
  assert.ok(regles(f).includes("signe-interdit"));
});

test("refuse un exemple sans le mot", () => {
  const f = modele();
  f.exemple = "Chaque mois, vous payez votre téléphone.";
  assert.ok(regles(f).includes("exemple-sans-le-mot"));
});

test("refuse un sigle sans prononciation", () => {
  const f = modele();
  Object.assign(f, {
    mot: "AAH",
    slug: "aah",
    definition: ["L'AAH est une aide en argent pour les adultes avec un handicap."],
    exemple: "Vous recevez l'AAH chaque mois sur votre compte.",
    formes_de_recherche: ["allocation aux adultes handicapés"],
  });
  assert.ok(regles(f, "aah.yaml").includes("prononciation-sigle"));
  f.prononciation = "a-a-hache";
  assert.ok(!regles(f, "aah.yaml").includes("prononciation-sigle"));
});

test("refuse un lien vers un mot inconnu", () => {
  const f = modele();
  f.mots_lies = ["mot-qui-n-existe-pas"];
  assert.ok(regles(f).includes("lien-inconnu"));
});

test("refuse un champ inconnu et un statut incohérent", () => {
  const f = modele();
  f.champ_en_trop = true;
  assert.ok(regles(f).includes("schema"));
  const g = modele();
  g.statut = "valide";
  assert.ok(regles(g).includes("statut"));
});

test("refuse un fichier mal nommé", () => {
  assert.ok(regles(modele(), "factures.yaml").includes("nom-de-fichier"));
});

test("refuse une source sans adresse quand aucune note ne l'explique", () => {
  const f = modele();
  f.source_de_reference = { titre: "service-public.fr", url: null, consulte_le: "2026-11-27" };
  assert.ok(regles(f).includes("source-sans-note"));
  f.notes_de_relecture = ["Source non ouverte, faute d'accès au web."];
  assert.ok(!regles(f).includes("source-sans-note"));
});
