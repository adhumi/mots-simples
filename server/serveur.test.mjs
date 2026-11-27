import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { Compteurs, LimiteDeDebit, normaliserLeMot } from "./demandes.mjs";
import { StockageEnMemoire, StockageFichier, creerServeur } from "./serveur.mjs";

async function avecServeur(options, essai) {
  const serveur = creerServeur({ delaiDEcritureMs: 0, aujourdhui: () => "2026-11-27", ...options });
  await new Promise((pret) => serveur.listen(0, "127.0.0.1", pret));
  const base = `http://127.0.0.1:${serveur.address().port}`;
  try {
    await essai(base);
  } finally {
    await serveur.arreter();
  }
}

const envoyer = (base, mot, enTetes = {}) =>
  fetch(`${base}/demandes`, { method: "POST", headers: { "Content-Type": "application/json", ...enTetes }, body: JSON.stringify({ mot }) });

test("normalise et valide le mot", () => {
  assert.equal(normaliserLeMot("  Hypothèque "), "hypothèque");
  assert.equal(normaliserLeMot("Mise  en   demeure"), "mise en demeure");
  assert.equal(normaliserLeMot("Aujourd’hui"), "aujourd'hui");
  assert.equal(normaliserLeMot("Rendez-vous"), "rendez-vous");
  assert.equal(normaliserLeMot("a"), null, "trop court");
  assert.equal(normaliserLeMot("x".repeat(41)), null, "trop long");
  assert.equal(normaliserLeMot("marie@exemple.fr"), null, "pas d'adresse");
  assert.equal(normaliserLeMot("06 12 34 56 78"), null, "pas de numéro");
  assert.equal(normaliserLeMot("mot2"), null, "pas de chiffre");
  assert.equal(normaliserLeMot("<script>"), null);
  assert.equal(normaliserLeMot("-mot"), null, "commence par une lettre");
  assert.equal(normaliserLeMot("mot--mot"), null);
  assert.equal(normaliserLeMot(42), null);
  assert.equal(normaliserLeMot(undefined), null);
});

test("les compteurs comptent par mot et trient", () => {
  const c = new Compteurs();
  c.ajouter("bail", "2026-11-27");
  c.ajouter("hypothèque", "2026-11-27");
  c.ajouter("hypothèque", "2026-11-28");
  assert.deepEqual(c.liste(), [
    { mot: "hypothèque", nombre: 2, premier_jour: "2026-11-27", dernier_jour: "2026-11-28" },
    { mot: "bail", nombre: 1, premier_jour: "2026-11-27", dernier_jour: "2026-11-27" },
  ]);
  const plein = new Compteurs({}, { maximumDeMots: 1 });
  assert.equal(plein.ajouter("un", "2026-11-27"), true);
  assert.equal(plein.ajouter("deux", "2026-11-27"), false);
  assert.equal(plein.ajouter("un", "2026-11-27"), true, "un mot déjà connu compte toujours");
});

test("la limite de débit compte par origine, au total, et repart à chaque fenêtre", () => {
  let t = 0;
  const limite = new LimiteDeDebit({ parOrigine: 2, auTotal: 3, fenetreMs: 1000, maintenant: () => t });
  assert.equal(limite.accepter("a"), true);
  assert.equal(limite.accepter("a"), true);
  assert.equal(limite.accepter("a"), false, "troisième demande de la même origine");
  assert.equal(limite.accepter("b"), true);
  assert.equal(limite.accepter("c"), false, "limite totale atteinte");
  const selAvant = limite.sel;
  t = 1000;
  assert.equal(limite.accepter("a"), true, "nouvelle fenêtre");
  assert.notDeepEqual(limite.sel, selAvant, "le sel change à chaque fenêtre");
  assert.ok(![...limite.compteurs.keys()].some((cle) => cle.includes("a") && cle.length < 10), "l'origine n'est pas gardée en clair");
});

test("POST /demandes compte le mot, normalisé", async () => {
  const stockage = new StockageEnMemoire();
  await avecServeur({ stockage, jeton: "secret-de-test" }, async (base) => {
    assert.equal((await envoyer(base, "Hypothèque")).status, 201);
    assert.equal((await envoyer(base, " hypothèque ")).status, 201);
    assert.equal((await envoyer(base, "Caution")).status, 201);
    const lecture = await fetch(`${base}/demandes`, { headers: { Authorization: "Bearer secret-de-test" } });
    assert.equal(lecture.status, 200);
    const { total, mots } = await lecture.json();
    assert.equal(total, 3);
    assert.deepEqual(mots.map((m) => [m.mot, m.nombre]), [["hypothèque", 2], ["caution", 1]]);
  });
  assert.deepEqual(Object.keys(stockage.mots).sort(), ["caution", "hypothèque"]);
  assert.deepEqual(Object.keys(stockage.mots["caution"]).sort(), ["dernier_jour", "nombre", "premier_jour"], "rien d'autre n'est gardé");
});

test("refuse ce qui n'est pas un mot, sans rien compter", async () => {
  const stockage = new StockageEnMemoire();
  await avecServeur({ stockage }, async (base) => {
    assert.equal((await envoyer(base, "marie@exemple.fr")).status, 422);
    assert.equal((await envoyer(base, "")).status, 422);
    assert.equal((await envoyer(base, "x".repeat(60))).status, 422);
    const illisible = await fetch(`${base}/demandes`, { method: "POST", headers: { "Content-Type": "application/json" }, body: "{mot" });
    assert.equal(illisible.status, 400);
    const autreType = await fetch(`${base}/demandes`, { method: "POST", headers: { "Content-Type": "text/plain" }, body: "bail" });
    assert.equal(autreType.status, 415);
    const tropLong = await fetch(`${base}/demandes`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ mot: "bail", reste: "x".repeat(5000) }) }).catch(() => ({ status: 400 }));
    assert.equal(tropLong.status, 400);
  });
  assert.deepEqual(stockage.mots, {});
});

test("la lecture des compteurs demande le bon jeton", async () => {
  await avecServeur({ jeton: "secret-de-test" }, async (base) => {
    assert.equal((await fetch(`${base}/demandes`)).status, 401);
    assert.equal((await fetch(`${base}/demandes`, { headers: { Authorization: "Bearer mauvais" } })).status, 401);
    assert.equal((await fetch(`${base}/demandes`, { headers: { Authorization: "Bearer secret-de-test" } })).status, 200);
  });
  await avecServeur({ jeton: "" }, async (base) => {
    assert.equal((await fetch(`${base}/demandes`, { headers: { Authorization: "Bearer " } })).status, 401, "sans jeton configuré, la lecture est fermée");
  });
});

test("export CSV", async () => {
  await avecServeur({ jeton: "j" }, async (base) => {
    await envoyer(base, "caution");
    const csv = await (await fetch(`${base}/demandes?format=csv`, { headers: { Authorization: "Bearer j" } })).text();
    assert.equal(csv, "mot,nombre,premier_jour,dernier_jour\ncaution,1,2026-11-27,2026-11-27\n");
  });
});

test("un formulaire du site reçoit une redirection vers une page du site", async () => {
  await avecServeur({ adresseDuSite: "https://motssimples.fr/" }, async (base) => {
    const poster = (corps) =>
      fetch(`${base}/demandes`, { method: "POST", redirect: "manual", headers: { "Content-Type": "application/x-www-form-urlencoded" }, body: corps });
    const bon = await poster("mot=Hypoth%C3%A8que");
    assert.equal(bon.status, 303);
    assert.equal(bon.headers.get("location"), "https://motssimples.fr/demander/merci");
    const mauvais = await poster("mot=123");
    assert.equal(mauvais.headers.get("location"), "https://motssimples.fr/demander/erreur");
  });
});

test("limite de débit : 429, et aucune trace de l'origine", async () => {
  const stockage = new StockageEnMemoire();
  await avecServeur({ stockage, limite: new LimiteDeDebit({ parOrigine: 2 }) }, async (base) => {
    const origine = { "X-Forwarded-For": "203.0.113.7" };
    assert.equal((await envoyer(base, "bail", origine)).status, 201);
    assert.equal((await envoyer(base, "bail", origine)).status, 201);
    assert.equal((await envoyer(base, "bail", origine)).status, 429);
    assert.equal((await envoyer(base, "bail", { "X-Forwarded-For": "203.0.113.8" })).status, 201, "une autre origine passe");
  });
  assert.ok(!JSON.stringify(stockage.mots).includes("203.0.113"), "aucune adresse dans le stockage");
});

test("aucun cookie, aucun cache, autres adresses fermées", async () => {
  await avecServeur({}, async (base) => {
    const r = await envoyer(base, "bail");
    assert.equal(r.headers.get("set-cookie"), null);
    assert.equal(r.headers.get("cache-control"), "no-store");
    assert.equal((await fetch(`${base}/sante`)).status, 200);
    assert.equal((await fetch(`${base}/`)).status, 404);
    assert.equal((await fetch(`${base}/demandes`, { method: "DELETE" })).status, 405);
  });
});

test("le stockage en fichier survit à un redémarrage, et à un fichier abîmé", async () => {
  const dossier = mkdtempSync(join(tmpdir(), "demandes-"));
  await avecServeur({ stockage: new StockageFichier(dossier) }, async (base) => {
    await envoyer(base, "caution");
    await envoyer(base, "caution");
  });
  const ecrit = JSON.parse(readFileSync(join(dossier, "demandes.json"), "utf8"));
  assert.equal(ecrit.mots.caution.nombre, 2);
  await avecServeur({ stockage: new StockageFichier(dossier), jeton: "j" }, async (base) => {
    await envoyer(base, "caution");
    const { mots } = await (await fetch(`${base}/demandes`, { headers: { Authorization: "Bearer j" } })).json();
    assert.equal(mots[0].nombre, 3);
  });
  writeFileSync(join(dossier, "demandes.json"), "{abîmé");
  assert.deepEqual(new StockageFichier(dossier).lire(), {});
});
