// Contrôles automatiques du site. Usage : npm run check:site (lancé aussi par npm run ci).
// 1. Construit le site dans les deux modes, public et préversion.
// 2. Contrôle chaque page : noindex, titres, liens internes, poids, aucune ressource d'un autre site.
// 3. Lance le serveur et contrôle ses en-têtes : X-Robots-Tag, cache, aucun cookie.
// 4. Ouvre les pages dans un navigateur : audit d'accessibilité axe, clair et sombre, écran étroit, sans JavaScript, recherche.
// Code de sortie : 0 si tout passe, 1 sinon.
import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { parse } from "yaml";
import { creerServeur } from "../serveur.mjs";

const require = createRequire(import.meta.url);
const site = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const depot = resolve(site, "..");
const POIDS_MAXIMAL = 100 * 1024;

const problemes = [];
const mesures = [];
function erreur(message) {
  problemes.push(message);
  console.error(`ERREUR  ${message}`);
}
function ok(message) {
  console.log(`ok      ${message}`);
}

// ---------- 1. Construction ----------

function construire(mode, sortie) {
  execFileSync("npx", ["astro", "build", "--silent"], {
    cwd: site,
    stdio: ["ignore", "ignore", "inherit"],
    // Le mode public est construit sans point de collecte, la préversion avec : les deux formes de /demander sont contrôlées.
    env: {
      ...process.env,
      MODE_CONTENU: mode,
      INDEXATION: "fermee",
      DOSSIER_DE_SORTIE: sortie,
      ADRESSE_DES_DEMANDES: mode === "preversion" ? "https://demandes.exemple.test" : "",
    },
  });
}

function refuseLaPreversionIndexable() {
  try {
    execFileSync("npx", ["astro", "build", "--silent"], {
      cwd: site,
      stdio: "ignore",
      env: { ...process.env, MODE_CONTENU: "preversion", INDEXATION: "ouverte", DOSSIER_DE_SORTIE: "./dist-interdit" },
    });
    return false;
  } catch {
    return true;
  }
}

// ---------- 2. Contrôle des fichiers ----------

function lister(dossier) {
  return readdirSync(dossier).flatMap((nom) => {
    const chemin = join(dossier, nom);
    return statSync(chemin).isDirectory() ? lister(chemin) : [chemin];
  });
}

function resoudre(dossier, chemin) {
  const propre = decodeURIComponent(chemin.split("#")[0].split("?")[0]);
  const candidats = propre === "/" ? ["/index.html"] : [propre, `${propre}.html`, `${propre}/index.html`];
  return candidats.map((c) => join(dossier, c)).find((c) => existsSync(c) && statSync(c).isFile()) ?? null;
}

function attributs(html, balise, attribut) {
  const valeurs = [];
  const re = new RegExp(`<${balise}\\b[^>]*?\\s${attribut}="([^"]*)"`, "gi");
  for (const m of html.matchAll(re)) valeurs.push(m[1]);
  return valeurs;
}

function controlerLesPages(mode, dossier) {
  const pages = lister(dossier).filter((f) => f.endsWith(".html"));
  let pire = { page: "", poids: 0 };
  for (const fichier of pages) {
    const page = "/" + relative(dossier, fichier).split(sep).join("/");
    const html = readFileSync(fichier, "utf8");
    const ici = (message) => erreur(`[${mode}] ${page} : ${message}`);

    if (!/<meta name="robots" content="noindex, nofollow">/.test(html)) ici("balise noindex absente");
    if (!/<html lang="fr">/.test(html)) ici("langue de la page absente");
    if (!/<title>[^<]+<\/title>/.test(html)) ici("titre de page absent");
    if (!/<meta name="description" content="[^"]+">/.test(html)) ici("description absente");

    // Un seul h1, et des titres dans l'ordre : pas de saut de niveau.
    const niveaux = [...html.matchAll(/<h([1-6])\b/g)].map((m) => Number(m[1]));
    if (niveaux.filter((n) => n === 1).length !== 1) ici(`${niveaux.filter((n) => n === 1).length} h1, un seul attendu`);
    if (niveaux[0] !== 1) ici("le premier titre n'est pas un h1");
    niveaux.forEach((n, i) => {
      if (i > 0 && n > niveaux[i - 1] + 1) ici(`saut de titre : h${niveaux[i - 1]} puis h${n}`);
    });

    // Liens internes et ancres.
    const identifiants = new Set(attributs(html, "[a-z0-9]+", "id"));
    for (const href of [...attributs(html, "a", "href"), ...attributs(html, "form", "action")]) {
      if (href.startsWith("#")) {
        if (!identifiants.has(href.slice(1))) ici(`ancre sans cible : ${href}`);
      } else if (href.startsWith("/")) {
        if (!resoudre(dossier, href)) ici(`lien interne cassé : ${href}`);
      } else if (!/^https:\/\//.test(href)) {
        ici(`lien de forme inattendue : ${href}`);
      }
    }

    // Aucune ressource chargée depuis un autre site, aucun script dans la page.
    const ressources = [
      ...attributs(html, "script", "src"),
      ...attributs(html, "img", "src"),
      ...attributs(html, "iframe", "src"),
      ...attributs(html, "source", "src"),
      ...[...html.matchAll(/<link\b[^>]*>/gi)]
        .filter((m) => /rel="(stylesheet|preload|icon|modulepreload)"/.test(m[0]))
        .flatMap((m) => attributs(m[0], "link", "href")),
    ];
    for (const src of ressources) {
      if (!src.startsWith("/") || src.startsWith("//")) ici(`ressource d'un autre site : ${src}`);
      else if (!resoudre(dossier, src)) ici(`ressource introuvable : ${src}`);
    }
    if (/<script(?![^>]*\b(src=|type="application\/ld\+json"))[^>]*>/.test(html)) ici("script écrit dans la page");
    if (/\sstyle="/.test(html)) ici("style écrit dans la page");
    if (/document\.cookie/.test(html)) ici("la page touche aux cookies");

    // Poids : la page et tout ce qu'elle charge, hors images.
    const pesees = ressources.filter((r) => !/\.(svg|png|jpe?g|webp|ico)$/.test(r)).map((r) => resoudre(dossier, r)).filter(Boolean);
    const poids = statSync(fichier).size + [...new Set(pesees)].reduce((somme, f) => somme + statSync(f).size, 0);
    if (poids > POIDS_MAXIMAL) ici(`${poids} octets hors image, le maximum est ${POIDS_MAXIMAL}`);
    if (poids > pire.poids) pire = { page, poids };
    if (mode === "preversion" && ["/index.html", "/mot/facture.html", "/theme/argent.html", "/mots.html"].includes(page)) {
      mesures.push(`${page} : ${poids} octets hors image, dont ${statSync(fichier).size} de HTML`);
    }
  }

  // Les feuilles de style et les scripts ne chargent rien d'ailleurs.
  for (const fichier of lister(dossier).filter((f) => /\.(css|js)$/.test(f))) {
    const texte = readFileSync(fichier, "utf8");
    const externes = [...texte.matchAll(/https?:\/\/[^\s"'`)]+/g)].map((m) => m[0]).filter((u) => !/^https?:\/\/(www\.w3\.org|motssimples\.fr)/.test(u));
    if (externes.length > 0) erreur(`[${mode}] ${relative(dossier, fichier)} cite une adresse externe : ${externes[0]}`);
    if (/document\.cookie|localStorage|sessionStorage|sendBeacon/.test(texte)) erreur(`[${mode}] ${relative(dossier, fichier)} garde ou envoie des données`);
  }
  ok(`[${mode}] ${pages.length} pages contrôlées. La plus lourde : ${pire.page}, ${pire.poids} octets hors image.`);
  return pages;
}

function controlerLesFiches(mode, dossier) {
  const fiches = readdirSync(join(depot, "content", "mots"))
    .filter((f) => f.endsWith(".yaml"))
    .map((f) => parse(readFileSync(join(depot, "content", "mots", f), "utf8")));
  const attendues = fiches.filter((f) => mode === "preversion" || f.statut === "relu" || f.statut === "valide");
  const dossierDesMots = join(dossier, "mot");
  const presentes = existsSync(dossierDesMots) ? readdirSync(dossierDesMots).map((f) => f.replace(/\.html$/, "")) : [];
  for (const f of attendues) if (!presentes.includes(f.slug)) erreur(`[${mode}] la fiche ${f.slug} n'a pas sa page`);
  for (const slug of presentes) if (!attendues.some((f) => f.slug === slug)) erreur(`[${mode}] page de mot en trop : ${slug}`);
  const paquet = JSON.parse(readFileSync(join(dossier, "contenu", "v1", "paquet.json"), "utf8"));
  if (paquet.preversion !== (mode === "preversion")) erreur(`[${mode}] le paquet servi n'est pas dans le bon mode`);
  if (paquet.fiches.length !== attendues.length) erreur(`[${mode}] le paquet servi a ${paquet.fiches.length} fiches, ${attendues.length} attendues`);
  if (mode === "public" && paquet.fiches.some((f) => f.statut === "brouillon")) erreur("[public] un brouillon est dans le paquet public");
  if (mode === "public") {
    for (const fichier of lister(dossier).filter((f) => f.endsWith(".html"))) {
      if (/Brouillon non relu|Préversion\./.test(readFileSync(fichier, "utf8"))) erreur(`[public] ${relative(dossier, fichier)} parle de brouillon ou de préversion`);
    }
  }
  ok(`[${mode}] ${attendues.length} fiche(s) attendue(s), ${presentes.length} page(s) de mot, paquet de ${paquet.fiches.length} fiche(s).`);
}

// ---------- 3. Serveur ----------

async function controlerLeServeur(base) {
  const lire = (chemin, options = {}) => fetch(base + chemin, { redirect: "manual", ...options });
  const cas = [
    ["/", 200],
    ["/mot/facture", 200],
    ["/mots", 200],
    ["/theme/argent", 200],
    ["/contenu/v1/manifest.json", 200],
    ["/contenu/v1/paquet.json", 200],
    ["/recherche.json", 200],
    ["/sitemap.xml", 200],
    ["/robots.txt", 200],
    ["/.well-known/apple-app-site-association", 200],
    ["/polices/lexend-latin.woff2", 200],
    ["/demander", 200],
    ["/demander/merci", 200],
    ["/demander/erreur", 200],
    ["/demander/plus-tard", 200],
    ["/mot/facture.html", 301],
    ["/mots/", 301],
    ["/mot/mot-qui-n-existe-pas", 404],
    ["/reglages.json", 404],
    ["/../package.json", 404],
  ];
  for (const [chemin, attendu] of cas) {
    const r = await lire(chemin);
    if (r.status !== attendu) erreur(`serveur : ${chemin} répond ${r.status}, ${attendu} attendu`);
    if (r.headers.get("x-robots-tag") !== "noindex, nofollow") erreur(`serveur : ${chemin} sans en-tête X-Robots-Tag`);
    if (r.headers.has("set-cookie")) erreur(`serveur : ${chemin} pose un cookie`);
    if (!r.headers.get("content-security-policy")) erreur(`serveur : ${chemin} sans politique de sécurité`);
    await r.arrayBuffer();
  }
  const manifeste = await lire("/contenu/v1/manifest.json");
  if (manifeste.headers.get("cache-control") !== "public, max-age=300") erreur("serveur : le manifeste doit avoir un cache court");
  const { version } = await manifeste.json();
  const paquet = await lire(`/contenu/v1/paquet.json?v=${version}`);
  if (!/immutable/.test(paquet.headers.get("cache-control") ?? "")) erreur("serveur : le paquet demandé avec sa version doit avoir un cache long");
  await paquet.arrayBuffer();
  const ancien = await lire("/contenu/v1/paquet.json?v=autre");
  if (/immutable/.test(ancien.headers.get("cache-control") ?? "")) erreur("serveur : un paquet d'une autre version ne doit pas avoir de cache long");
  await ancien.arrayBuffer();
  const aasa = await lire("/.well-known/apple-app-site-association");
  if (!/^application\/json/.test(aasa.headers.get("content-type") ?? "")) erreur("serveur : le fichier des liens universels doit être servi en JSON");
  await aasa.arrayBuffer();
  const post = await lire("/", { method: "POST" });
  if (post.status !== 405) erreur(`serveur : POST / répond ${post.status}, 405 attendu`);
  ok(`serveur : ${cas.length} adresses contrôlées, en-tête X-Robots-Tag partout, aucun cookie.`);
}

// ---------- 4. Navigateur ----------

async function controlerDansLeNavigateur(base) {
  const { chromium } = require("playwright");
  const axe = readFileSync(require.resolve("axe-core/axe.min.js"), "utf8");
  const navigateur = await chromium.launch();
  const pages = ["/", "/mot/facture", "/mot/preavis", "/theme/argent", "/mots", "/a-propos", "/demander", "/demander/merci"];
  try {
    for (const theme of ["light", "dark"]) {
      // bypassCSP : la politique de sécurité du site bloque, à raison, le script d'audit injecté.
      const contexte = await navigateur.newContext({ colorScheme: theme, viewport: { width: 390, height: 844 }, bypassCSP: true });
      const page = await contexte.newPage();
      const externes = [];
      page.on("request", (r) => {
        if (!r.url().startsWith(base) && !r.url().startsWith("data:")) externes.push(r.url());
      });
      for (const chemin of pages) {
        await page.goto(base + chemin, { waitUntil: "networkidle" });
        await page.addScriptTag({ content: axe });
        const resultat = await page.evaluate(() =>
          // @ts-ignore : axe est injecté juste au-dessus.
          axe.run(document, { runOnly: { type: "tag", values: ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa", "best-practice"] } }),
        );
        for (const v of resultat.violations) {
          erreur(`axe [${theme}] ${chemin} : ${v.id} (${v.impact}) ${v.help}. ${v.nodes.length} élément(s), par exemple ${v.nodes[0].target.join(" ")}`);
        }
      }
      if (externes.length > 0) erreur(`navigateur [${theme}] : requête vers un autre site : ${externes[0]}`);
      if ((await contexte.cookies()).length > 0) erreur(`navigateur [${theme}] : un cookie a été posé`);
      await contexte.close();
    }
    ok(`axe : ${pages.length} pages auditées en clair et en sombre.`);

    // Écran étroit de 320 pixels : c'est aussi un zoom de 400 % sur un écran de 1280. Pas de défilement horizontal.
    const etroit = await navigateur.newContext({ viewport: { width: 320, height: 640 } });
    const pageEtroite = await etroit.newPage();
    for (const chemin of pages) {
      await pageEtroite.goto(base + chemin);
      const deborde = await pageEtroite.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
      if (deborde) erreur(`écran étroit : ${chemin} défile horizontalement à 320 pixels`);
    }
    await etroit.close();
    ok("écran étroit : pas de défilement horizontal à 320 pixels.");

    // Sans JavaScript : tout se lit, la liste et les thèmes mènent aux mots, le champ de recherche reste caché.
    const sansJs = await navigateur.newContext({ javaScriptEnabled: false });
    const pageSansJs = await sansJs.newPage();
    await pageSansJs.goto(base + "/");
    if (await pageSansJs.locator("[data-recherche]").isVisible()) erreur("sans JavaScript : le champ de recherche ne doit pas apparaître");
    if ((await pageSansJs.locator('a[href^="/theme/"]').count()) !== 8) erreur("sans JavaScript : les huit thèmes doivent être sur l'accueil");
    await pageSansJs.locator('a[href="/mots"]').first().click();
    await pageSansJs.locator('a[href="/mot/facture"]').click();
    const definition = await pageSansJs.locator("h1").innerText();
    if (definition !== "Facture") erreur("sans JavaScript : la fiche « facture » n'est pas atteinte par la liste");
    if (await pageSansJs.locator("[data-ecoute]").isVisible()) erreur("sans JavaScript : le bouton d'écoute ne doit pas apparaître");
    await sansJs.close();
    ok("sans JavaScript : accueil, liste et fiche se lisent.");

    // Avec JavaScript : la recherche trouve un mot malgré une faute, et le clavier suffit.
    const contexte = await navigateur.newContext();
    const page = await contexte.newPage();
    await page.goto(base + "/");
    await page.keyboard.press("Tab");
    const premier = await page.evaluate(() => document.activeElement?.className);
    if (premier !== "evitement") erreur("clavier : le premier arrêt doit être le lien « Aller au contenu »");
    const champ = page.locator("#champ-recherche");
    await champ.waitFor({ state: "visible" });
    await champ.fill("factrue");
    const resultat = page.locator('[data-liste] a[href="/mot/facture"]');
    await resultat.waitFor({ state: "visible" });
    await champ.fill("girafe");
    await page.locator("[data-absent]").waitFor({ state: "visible" });
    // « Demander ce mot » emmène le mot vers la page de demande, qui le recopie dans son champ.
    await page.locator("[data-demander]").click();
    await page.waitForURL(base + "/demander?mot=girafe");
    if ((await page.locator("#mot").inputValue()) !== "girafe") erreur("demander : le mot cherché n'est pas recopié dans le champ");
    if ((await page.locator("form.formulaire").getAttribute("action")) !== "https://demandes.exemple.test/demandes") erreur("demander : le formulaire ne vise pas le point de collecte");
    await page.goto(base + "/");
    await champ.waitFor({ state: "visible" });
    await champ.fill("rdv");
    await champ.press("Enter");
    await page.keyboard.press("Enter");
    await page.waitForURL(base + "/mot/rendez-vous");
    const contour = await page.evaluate(() => {
      const lien = document.querySelector("a.bouton");
      lien.focus();
      return getComputedStyle(lien).outlineStyle;
    });
    if (contour === "none") erreur("clavier : le focus n'est pas visible sur un bouton");
    await contexte.close();
    ok("recherche et clavier : « factrue » trouve facture, « rdv » puis Entrée ouvre rendez-vous.");
  } finally {
    await navigateur.close();
  }
}

// ---------- Déroulé ----------

console.log("Construction du site dans les deux modes…");
construire("public", "./dist-public");
construire("preversion", "./dist");
ok("le site se construit en mode public et en mode préversion.");
if (refuseLaPreversionIndexable()) ok("une préversion indexable est refusée à la construction.");
else erreur("une préversion indexable devrait être refusée à la construction");

for (const [mode, dossier] of [["public", join(site, "dist-public")], ["preversion", join(site, "dist")]]) {
  controlerLesPages(mode, dossier);
  controlerLesFiches(mode, dossier);
}

const serveur = creerServeur({ dossier: join(site, "dist") });
await new Promise((pret) => serveur.listen(0, "127.0.0.1", pret));
const base = `http://127.0.0.1:${serveur.address().port}`;
try {
  await controlerLeServeur(base);
  await controlerDansLeNavigateur(base);
} catch (e) {
  erreur(`contrôle interrompu : ${e.stack ?? e}`);
} finally {
  serveur.close();
}

console.log("\nPoids des pages (préversion) :");
for (const m of mesures) console.log(`  ${m}`);
console.log(`\nContrôle du site : ${problemes.length} erreur(s).`);
process.exit(problemes.length > 0 ? 1 : 0);
