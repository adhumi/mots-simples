// Le paquet de contenu que l'app télécharge. Mêmes octets que « npm run build:content » dans le même mode.
import { paquetJson } from "../../../lib/contenu.ts";

export function GET(): Response {
  return new Response(paquetJson, { headers: { "Content-Type": "application/json; charset=utf-8" } });
}
