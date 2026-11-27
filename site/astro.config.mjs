import { defineConfig } from "astro/config";

// Site statique, sans framework côté client.
// Les adresses n'ont pas de barre finale : /mot/facture. Le serveur (serveur.mjs) sert facture.html.
export default defineConfig({
  site: "https://motssimples.fr",
  output: "static",
  trailingSlash: "never",
  build: { format: "file" },
  outDir: process.env.DOSSIER_DE_SORTIE ?? "./dist",
  devToolbar: { enabled: false },
  vite: {
    // Le site lit ../content et ../tools : une seule définition du schéma dans le dépôt.
    server: { fs: { allow: [".."] } },
    // Aucun script dans le HTML : la politique de sécurité du serveur n'autorise que les fichiers du site.
    build: { assetsInlineLimit: 0 },
  },
});
