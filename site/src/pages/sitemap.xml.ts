// Plan du site. Écrit à la main : pas de dépendance de plus pour quelques lignes.
import { fiches, themes } from "../lib/contenu.ts";

export function GET({ site }: { site: URL | undefined }): Response {
  const base = site ?? new URL("https://motssimples.fr");
  const chemins = [
    "/",
    "/mots",
    ...themes.map((t) => `/theme/${t.slug}`),
    ...fiches.map((f) => `/mot/${f.slug}`),
    "/a-propos",
    "/vie-privee",
    "/accessibilite",
  ];
  const corps =
    `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n` +
    chemins.map((c) => `  <url><loc>${new URL(c, base).href}</loc></url>`).join("\n") +
    `\n</urlset>\n`;
  return new Response(corps, { headers: { "Content-Type": "application/xml; charset=utf-8" } });
}
