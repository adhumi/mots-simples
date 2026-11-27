import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { cpSync, mkdtempSync, readFileSync, writeFileSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { construirePaquet, genererPaquet, lireFiches, serialiser } from "./build-content.ts";
import type { Fiche } from "./schema.ts";

const racine = new URL("..", import.meta.url).pathname;
const fiches = lireFiches(racine);

function avecStatut(statut: Fiche["statut"], slug = "facture"): Fiche[] {
  return fiches.map((f) => (f.slug === slug ? { ...f, statut, valide_le: statut === "valide" ? "2026-12-01" : null } : f));
}

test("le mode public ne garde que les fiches relues et validées", () => {
  assert.equal(construirePaquet(fiches.map((f) => ({ ...f, statut: "brouillon" as const })), { preversion: false }).fiches.length, 0);
  const paquet = construirePaquet(avecStatut("relu"), { preversion: false });
  assert.ok(paquet.fiches.some((f) => f.slug === "facture"));
  assert.ok(paquet.fiches.every((f) => f.statut !== "brouillon"));
  assert.equal(paquet.preversion, false);
});

test("le mode préversion garde tout et le dit", () => {
  const paquet = construirePaquet(fiches, { preversion: true });
  assert.equal(paquet.fiches.length, fiches.length);
  assert.equal(paquet.preversion, true);
});

test("les champs internes ne sortent pas", () => {
  const { paquetJson } = serialiser(construirePaquet(fiches, { preversion: true }));
  assert.ok(!paquetJson.includes("source_de_reference"));
  assert.ok(!paquetJson.includes("notes_de_relecture"));
  assert.ok(!paquetJson.includes("consulte_le"));
});

test("deux générations du même contenu donnent le même paquet", () => {
  const a = serialiser(construirePaquet(fiches, { preversion: true }));
  const b = serialiser(construirePaquet(lireFiches(racine), { preversion: true }));
  assert.equal(a.paquetJson, b.paquetJson);
  assert.equal(a.manifestJson, b.manifestJson);
});

test("la version change avec le contenu et avec le mode", () => {
  const base = construirePaquet(fiches, { preversion: true });
  const modifie = construirePaquet(
    fiches.map((f) => (f.slug === "facture" ? { ...f, exemple: "Vous recevez une facture." } : f)),
    { preversion: true },
  );
  assert.notEqual(base.version, modifie.version);
  assert.notEqual(construirePaquet(avecStatut("relu"), { preversion: false }).version, base.version);
  assert.match(base.version, /^[0-9a-f]{12}$/);
});

test("la version ne dépend pas des champs internes ni de la date", () => {
  const base = construirePaquet(fiches, { preversion: true });
  const autre = construirePaquet(
    fiches.map((f) => ({ ...f, notes_de_relecture: ["Autre note."] })),
    { preversion: true, date: "2030-01-01" },
  );
  assert.equal(base.version, autre.version);
  assert.equal(autre.genere_le, "2030-01-01");
});

test("le manifeste porte l'empreinte et la taille du paquet écrit", () => {
  const sortie = mkdtempSync(join(tmpdir(), "paquet-"));
  const manifeste = genererPaquet(racine, sortie, { preversion: true });
  const octets = readFileSync(join(sortie, "paquet.json"));
  assert.equal(manifeste.sha256, createHash("sha256").update(octets).digest("hex"));
  assert.equal(manifeste.taille, octets.length);
  const lu = JSON.parse(readFileSync(join(sortie, "manifest.json"), "utf8"));
  assert.deepEqual(lu, manifeste);
  assert.equal(JSON.parse(octets.toString("utf8")).version, manifeste.version);
});

test("une erreur du contrôle arrête la génération", () => {
  const copie = mkdtempSync(join(tmpdir(), "depot-"));
  cpSync(join(racine, "content"), join(copie, "content"), { recursive: true });
  const chemin = join(copie, "content", "mots", "facture.yaml");
  writeFileSync(chemin, readFileSync(chemin, "utf8").replace("statut: brouillon", "statut: valide"));
  const sortie = join(copie, "dist");
  assert.throws(() => genererPaquet(copie, sortie, { preversion: true }), /contrôle des fiches échoue/);
  assert.ok(!existsSync(join(sortie, "paquet.json")));
});
