// Serveur statique de motssimples.fr. Node seul, sans dépendance.
// Il sert le dossier construit par « astro build » et pose les en-têtes : noindex, cache, sécurité.
// Il ne pose aucun cookie et n'écrit aucun journal de requêtes : aucune adresse IP n'est gardée.
//
// Variables : PORT (défaut 8080), DOSSIER (défaut ./dist), ADRESSE_DES_DEMANDES (origine du point de collecte, facultatif).
import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { createServer } from "node:http";
import { extname, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { brotliCompressSync, gzipSync } from "node:zlib";

const TYPES = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".xml": "application/xml; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".webp": "image/webp",
  ".ico": "image/x-icon",
  ".woff2": "font/woff2",
};
const COMPRESSIBLES = new Set([".html", ".css", ".js", ".json", ".xml", ".txt", ".svg", ""]);
const UN_AN = "public, max-age=31536000, immutable";
const COURT = "public, max-age=300";

function lister(dossier) {
  return readdirSync(dossier).flatMap((nom) => {
    const chemin = join(dossier, nom);
    return statSync(chemin).isDirectory() ? lister(chemin) : [chemin];
  });
}

/** Charge tout le site en mémoire : quelques centaines de petits fichiers. */
function charger(dossier) {
  const fichiers = new Map();
  for (const chemin of lister(dossier)) {
    const url = "/" + relative(dossier, chemin).split(sep).join("/");
    const ext = extname(chemin);
    const corps = readFileSync(chemin);
    const compressible = COMPRESSIBLES.has(ext) && corps.length > 256;
    fichiers.set(url, {
      corps,
      gzip: compressible ? gzipSync(corps) : null,
      br: compressible ? brotliCompressSync(corps) : null,
      // Le fichier des liens universels d'Apple n'a pas d'extension : c'est du JSON.
      type: url === "/.well-known/apple-app-site-association" ? TYPES[".json"] : (TYPES[ext] ?? "application/octet-stream"),
      etag: `"${createHash("sha1").update(corps).digest("hex").slice(0, 20)}"`,
    });
  }
  return fichiers;
}

function cache(url, requete, version) {
  if (url.startsWith("/_astro/") || url.startsWith("/polices/")) return UN_AN;
  if (url === "/contenu/v1/manifest.json") return COURT;
  // Le paquet demandé avec sa version (?v=…) ne change plus jamais : cache long. Sinon, cache court.
  if (url === "/contenu/v1/paquet.json") return version && requete.get("v") === version ? UN_AN : COURT;
  if (url.endsWith(".html")) return "no-cache";
  return COURT;
}

export function creerServeur({ dossier = "./dist", adresseDesDemandes = process.env.ADRESSE_DES_DEMANDES ?? "" } = {}) {
  const racine = resolve(dossier);
  if (!existsSync(join(racine, "index.html"))) {
    throw new Error(`Site introuvable dans ${racine}. Lancer d'abord « npm run build:site ».`);
  }
  const fichiers = charger(racine);

  // reglages.json est écrit par la construction du site. C'est lui qui commande le noindex : un seul réglage.
  // Sans ce fichier, ou s'il est illisible, le site reste fermé aux moteurs de recherche.
  let noindex = true;
  let version = "";
  try {
    noindex = JSON.parse(fichiers.get("/reglages.json").corps.toString("utf8")).indexation !== "ouverte";
  } catch {
    noindex = true;
  }
  try {
    version = JSON.parse(fichiers.get("/contenu/v1/manifest.json").corps.toString("utf8")).version;
  } catch {
    version = "";
  }
  fichiers.delete("/reglages.json");

  let origineDesDemandes = "";
  try {
    origineDesDemandes = adresseDesDemandes ? new URL(adresseDesDemandes).origin : "";
  } catch {
    origineDesDemandes = "";
  }
  const securite = {
    "Content-Security-Policy": [
      "default-src 'none'",
      "script-src 'self'",
      "style-src 'self'",
      "img-src 'self' data:",
      "font-src 'self'",
      "connect-src 'self'",
      `form-action 'self'${origineDesDemandes ? ` ${origineDesDemandes}` : ""}`,
      "base-uri 'none'",
      "frame-ancestors 'none'",
    ].join("; "),
    "X-Content-Type-Options": "nosniff",
    "Referrer-Policy": "no-referrer",
    "Permissions-Policy": "camera=(), microphone=(), geolocation=(), interest-cohort=()",
    "Cross-Origin-Opener-Policy": "same-origin",
  };

  function trouver(chemin) {
    if (chemin === "/") return "/index.html";
    for (const candidat of [chemin, `${chemin}.html`, `${chemin}/index.html`]) {
      if (fichiers.has(candidat)) return candidat;
    }
    return null;
  }

  return createServer((req, res) => {
    const enTetes = { ...securite };
    if (noindex) enTetes["X-Robots-Tag"] = "noindex, nofollow";

    const repondre = (statut, plus = {}, corps = "") => {
      res.writeHead(statut, { ...enTetes, ...plus });
      res.end(req.method === "HEAD" ? undefined : corps);
    };

    if (req.method !== "GET" && req.method !== "HEAD") {
      return repondre(405, { Allow: "GET, HEAD", "Content-Type": "text/plain; charset=utf-8" }, "Méthode non autorisée.\n");
    }

    let adresse;
    let chemin;
    try {
      adresse = new URL(req.url ?? "/", "http://site.local");
      chemin = decodeURIComponent(adresse.pathname);
    } catch {
      return repondre(400, { "Content-Type": "text/plain; charset=utf-8" }, "Adresse illisible.\n");
    }

    // Une seule adresse par page : /mot/facture, sans « .html » ni barre finale.
    const propre = chemin.replace(/\/index\.html$/, "/").replace(/\.html$/, "").replace(/(.)\/+$/, "$1");
    if (propre !== chemin && trouver(propre)) {
      return repondre(301, { Location: propre + adresse.search });
    }

    const url = trouver(chemin);
    const fichier = url ? fichiers.get(url) : null;
    if (!url || !fichier) {
      const page = fichiers.get("/404.html");
      return repondre(404, { "Content-Type": TYPES[".html"], "Cache-Control": "no-cache" }, page ? page.corps : "Page introuvable.\n");
    }

    const reponse = {
      "Content-Type": fichier.type,
      "Cache-Control": cache(url, adresse.searchParams, version),
      ETag: fichier.etag,
    };
    if (req.headers["if-none-match"] === fichier.etag) return repondre(304, reponse);

    let corps = fichier.corps;
    if (fichier.br || fichier.gzip) {
      reponse.Vary = "Accept-Encoding";
      const accepte = String(req.headers["accept-encoding"] ?? "");
      if (fichier.br && /\bbr\b/.test(accepte)) {
        corps = fichier.br;
        reponse["Content-Encoding"] = "br";
      } else if (fichier.gzip && /\bgzip\b/.test(accepte)) {
        corps = fichier.gzip;
        reponse["Content-Encoding"] = "gzip";
      }
    }
    reponse["Content-Length"] = corps.length;
    return repondre(200, reponse, corps);
  });
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const port = Number(process.env.PORT ?? 8080);
  const dossier = process.env.DOSSIER ?? fileURLToPath(new URL("./dist", import.meta.url));
  creerServeur({ dossier }).listen(port, "0.0.0.0", () => {
    console.log(`Mots simples : site servi sur le port ${port}.`);
  });
}
