// Copie le paquet de contenu dans l'app iOS et dans les tests de DictionaryCore.
// Usage : npm run embed:content              (paquet de préversion, pour TestFlight et le simulateur)
//         npm run embed:content -- --public  (paquet public, pour un build App Store)
//         npm run embed:content -- --check   (vérifie que les copies sont à jour, sans rien écrire)
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { genererPaquet } from "./build-content.ts";

const racine = resolve(".");
const args = process.argv.slice(2);
const verifier = args.includes("--check");
const preversion = !args.includes("--public");

const dossierApp = join(racine, "ios", "MotsSimples", "Contenu");
const dossierTests = join(racine, "ios", "Packages", "DictionaryCore", "Tests", "DictionaryCoreTests", "Ressources");
const corpus = join(racine, "tools", "donnees", "requetes-recherche.json");

const temporaire = mkdtempSync(join(tmpdir(), "contenu-"));
try {
  // L'app reçoit le mode demandé. Les tests gardent toujours le paquet de préversion : il contient toutes les fiches.
  genererPaquet(racine, join(temporaire, "app"), { preversion });
  genererPaquet(racine, join(temporaire, "tests"), { preversion: true });
} catch (e) {
  console.error((e as Error).message);
  process.exit(1);
}

const copies: [string, string][] = [
  [join(temporaire, "app", "paquet.json"), join(dossierApp, "paquet.json")],
  [join(temporaire, "app", "manifest.json"), join(dossierApp, "manifest.json")],
  [join(temporaire, "tests", "paquet.json"), join(dossierTests, "paquet.json")],
  [join(temporaire, "tests", "manifest.json"), join(dossierTests, "manifest.json")],
  [corpus, join(dossierTests, "requetes-recherche.json")],
];

let perimes = 0;
for (const [source, cible] of copies) {
  if (verifier) {
    const aJour = existsSync(cible) && readFileSync(cible).equals(readFileSync(source));
    if (!aJour) {
      perimes++;
      console.error(`Pas à jour : ${cible}`);
    }
  } else {
    mkdirSync(resolve(cible, ".."), { recursive: true });
    copyFileSync(source, cible);
  }
}

if (verifier) {
  if (perimes > 0) {
    console.error("\nLe contenu embarqué dans l'app n'est pas à jour. Lancer : npm run embed:content");
    process.exit(1);
  }
  console.log("Le contenu embarqué dans l'app est à jour.");
} else {
  console.log(`Contenu ${preversion ? "de préversion" : "public"} copié dans ios/MotsSimples/Contenu et dans les tests de DictionaryCore.`);
}
