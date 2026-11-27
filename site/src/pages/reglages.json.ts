// Dit au serveur (serveur.mjs) comment le site a été construit.
// C'est ce fichier qui commande l'en-tête X-Robots-Tag : un seul réglage, INDEXATION, pour la balise et pour l'en-tête.
// Le serveur ne sert pas ce fichier au public.
import { indexation, mode } from "../lib/reglages.ts";

export function GET(): Response {
  return new Response(JSON.stringify({ indexation, mode }) + "\n", { headers: { "Content-Type": "application/json" } });
}
