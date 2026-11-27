// Point de collecte des mots demandés. Node seul, sans dépendance.
//
//   POST /demandes   un seul champ, « mot ». JSON ou formulaire. Incrémente un compteur par mot.
//   GET  /demandes   lecture des compteurs, protégée par un jeton. Ajouter ?format=csv pour un tableur.
//   GET  /sante      pour la surveillance de Railway.
//
// Ce service ne pose aucun cookie, n'écrit aucun journal de requêtes et ne garde aucune adresse IP.
//
// Variables : PORT, DOSSIER_DES_DONNEES (défaut ./donnees), JETON_DE_LECTURE, ADRESSE_DU_SITE (défaut https://motssimples.fr).
import { timingSafeEqual } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, renameSync, writeFileSync } from "node:fs";
import { createServer } from "node:http";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { Compteurs, LimiteDeDebit, normaliserLeMot } from "./demandes.mjs";

const TAILLE_MAXIMALE = 1024;

/** Stockage : un fichier JSON, réécrit d'un seul coup. Sur Railway, le dossier est un volume. */
export class StockageFichier {
  constructor(dossier) {
    this.chemin = join(resolve(dossier), "demandes.json");
    mkdirSync(resolve(dossier), { recursive: true });
  }

  lire() {
    if (!existsSync(this.chemin)) return {};
    try {
      return JSON.parse(readFileSync(this.chemin, "utf8")).mots ?? {};
    } catch {
      // Un fichier abîmé ne doit pas empêcher le service de démarrer. On le met de côté.
      renameSync(this.chemin, `${this.chemin}.illisible`);
      return {};
    }
  }

  ecrire(mots) {
    const temporaire = `${this.chemin}.tmp`;
    writeFileSync(temporaire, JSON.stringify({ schema: 1, mots }) + "\n");
    renameSync(temporaire, this.chemin);
  }
}

export class StockageEnMemoire {
  constructor(initial = {}) {
    this.mots = initial;
  }
  lire() {
    return this.mots;
  }
  ecrire(mots) {
    this.mots = structuredClone(mots);
  }
}

function jetonValide(enTete, jeton) {
  if (!jeton || typeof enTete !== "string" || !enTete.startsWith("Bearer ")) return false;
  const recu = Buffer.from(enTete.slice(7));
  const attendu = Buffer.from(jeton);
  return recu.length === attendu.length && timingSafeEqual(recu, attendu);
}

function lireLeCorps(req) {
  return new Promise((resoudre, rejeter) => {
    const morceaux = [];
    let taille = 0;
    req.on("data", (morceau) => {
      taille += morceau.length;
      if (taille > TAILLE_MAXIMALE) {
        rejeter(new Error("trop long"));
        req.destroy();
        return;
      }
      morceaux.push(morceau);
    });
    req.on("end", () => resoudre(Buffer.concat(morceaux).toString("utf8")));
    req.on("error", rejeter);
  });
}

/** L'origine sert seulement à la limite de débit, en mémoire. Elle n'est jamais écrite. */
function origine(req) {
  const transmise = String(req.headers["x-forwarded-for"] ?? "").split(",")[0].trim();
  return String(req.headers["x-real-ip"] ?? "") || transmise || req.socket.remoteAddress || "inconnue";
}

export function creerServeur({
  stockage = new StockageEnMemoire(),
  jeton = "",
  adresseDuSite = "https://motssimples.fr",
  limite = new LimiteDeDebit(),
  delaiDEcritureMs = 2000,
  aujourdhui = () => new Date().toISOString().slice(0, 10),
} = {}) {
  const compteurs = new Compteurs(stockage.lire());
  const site = adresseDuSite.replace(/\/+$/, "");
  let ecritureEnAttente = null;

  const ecrire = () => {
    ecritureEnAttente = null;
    stockage.ecrire(compteurs.versObjet());
  };
  const planifierLEcriture = () => {
    if (delaiDEcritureMs <= 0) return ecrire();
    if (!ecritureEnAttente) ecritureEnAttente = setTimeout(ecrire, delaiDEcritureMs);
  };

  const serveur = createServer(async (req, res) => {
    const base = {
      "X-Content-Type-Options": "nosniff",
      "Referrer-Policy": "no-referrer",
      "Cache-Control": "no-store",
      "X-Robots-Tag": "noindex, nofollow",
    };
    const json = (statut, corps, plus = {}) => {
      res.writeHead(statut, { ...base, "Content-Type": "application/json; charset=utf-8", ...plus });
      res.end(JSON.stringify(corps) + "\n");
    };
    const adresse = new URL(req.url ?? "/", "http://collecte.local");

    if (adresse.pathname === "/sante" && req.method === "GET") return json(200, { etat: "ok" });

    if (adresse.pathname !== "/demandes") return json(404, { erreur: "introuvable" });

    if (req.method === "GET") {
      if (!jetonValide(req.headers.authorization, jeton)) {
        return json(401, { erreur: "jeton attendu" }, { "WWW-Authenticate": "Bearer" });
      }
      const liste = compteurs.liste();
      if (adresse.searchParams.get("format") === "csv") {
        res.writeHead(200, { ...base, "Content-Type": "text/csv; charset=utf-8" });
        return res.end(["mot,nombre,premier_jour,dernier_jour", ...liste.map((l) => `${l.mot},${l.nombre},${l.premier_jour},${l.dernier_jour}`)].join("\n") + "\n");
      }
      return json(200, { total: liste.reduce((s, l) => s + l.nombre, 0), mots: liste });
    }

    if (req.method !== "POST") return json(405, { erreur: "méthode non autorisée" }, { Allow: "GET, POST" });

    // Un formulaire du site, sans JavaScript, attend une page en retour. L'app attend du JSON.
    const type = String(req.headers["content-type"] ?? "").split(";")[0].trim().toLowerCase();
    const formulaire = type === "application/x-www-form-urlencoded";
    const repondre = (statut, corps, page) => {
      if (formulaire) {
        res.writeHead(303, { ...base, Location: `${site}/demander/${page}` });
        return res.end();
      }
      return json(statut, corps);
    };

    if (!limite.accepter(origine(req))) return repondre(429, { erreur: "trop de demandes, réessayez plus tard" }, "plus-tard");

    let brut;
    try {
      const corps = await lireLeCorps(req);
      if (formulaire) brut = new URLSearchParams(corps).get("mot");
      else if (type === "application/json") brut = JSON.parse(corps)?.mot;
      else return json(415, { erreur: "envoyer du JSON ou un formulaire" });
    } catch {
      return repondre(400, { erreur: "demande illisible" }, "erreur");
    }

    const mot = normaliserLeMot(brut);
    if (!mot) return repondre(422, { erreur: "mot refusé : lettres, espaces, tirets et apostrophes seulement, 40 caractères au plus" }, "erreur");
    if (!compteurs.ajouter(mot, aujourdhui())) return repondre(507, { erreur: "stockage plein" }, "plus-tard");

    planifierLEcriture();
    return repondre(201, { recu: true }, "merci");
  });

  /** Écrit ce qui attend, puis ferme. À appeler à l'arrêt du service. */
  serveur.arreter = () =>
    new Promise((fini) => {
      if (ecritureEnAttente) {
        clearTimeout(ecritureEnAttente);
        ecrire();
      }
      serveur.close(() => fini());
    });

  return serveur;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const port = Number(process.env.PORT ?? 8081);
  const jeton = process.env.JETON_DE_LECTURE ?? "";
  const serveur = creerServeur({
    stockage: new StockageFichier(process.env.DOSSIER_DES_DONNEES ?? "./donnees"),
    jeton,
    adresseDuSite: process.env.ADRESSE_DU_SITE ?? "https://motssimples.fr",
  });
  serveur.listen(port, "0.0.0.0", () => {
    console.log(`Mots simples : point de collecte sur le port ${port}.${jeton ? "" : " Aucun jeton : la lecture des compteurs est fermée."}`);
  });
  for (const signal of ["SIGTERM", "SIGINT"]) {
    process.on(signal, () => serveur.arreter().then(() => process.exit(0)));
  }
}
