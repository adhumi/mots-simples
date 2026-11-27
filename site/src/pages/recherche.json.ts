// Les données de la recherche instantanée : le mot, son adresse et ses formes de recherche. Rien d'autre.
import { fiches } from "../lib/contenu.ts";

export function GET(): Response {
  const donnees = fiches.map((f) => ({ slug: f.slug, mot: f.mot, formes_de_recherche: f.formes_de_recherche }));
  return new Response(JSON.stringify(donnees), { headers: { "Content-Type": "application/json; charset=utf-8" } });
}
