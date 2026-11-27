import { manifestJson } from "../../../lib/contenu.ts";

export function GET(): Response {
  return new Response(manifestJson, { headers: { "Content-Type": "application/json; charset=utf-8" } });
}
