// Recherche instantanée sur l'accueil. C'est un plus : sans JavaScript, la liste et les thèmes suffisent.
// Même règle que l'app : tools/recherche.ts. Tout se passe dans le navigateur, le mot cherché n'est envoyé nulle part.
import { IndexDeRecherche, type FicheCherchable } from "../../../tools/recherche.ts";

const formulaire = document.querySelector<HTMLFormElement>("[data-recherche]");
const zone = document.querySelector<HTMLElement>("[data-resultats]");
const liste = zone?.querySelector<HTMLUListElement>("[data-liste]");
const absent = zone?.querySelector<HTMLElement>("[data-absent]");
const champ = formulaire?.querySelector<HTMLInputElement>("input");

if (formulaire && zone && liste && absent && champ) {
  let index: IndexDeRecherche<FicheCherchable> | null = null;

  const afficher = (): void => {
    if (!index) return;
    const requete = champ.value;
    if (requete.trim().length < 2) {
      zone.hidden = true;
      return;
    }
    const resultats = index.chercher(requete);
    liste.replaceChildren(
      ...resultats.map((fiche) => {
        const li = document.createElement("li");
        const lien = document.createElement("a");
        lien.className = "carte mot";
        lien.href = `/mot/${fiche.slug}`;
        const nom = document.createElement("span");
        nom.className = "mot-nom";
        nom.textContent = fiche.mot;
        lien.append(nom);
        li.append(lien);
        return li;
      }),
    );
    // « Demander ce mot » emmène le mot cherché vers la page de demande. Il reste dans le navigateur.
    const demander = absent.querySelector<HTMLAnchorElement>("[data-demander]");
    if (demander) demander.href = `/demander?mot=${encodeURIComponent(requete.trim())}`;
    liste.hidden = resultats.length === 0;
    absent.hidden = resultats.length > 0;
    zone.hidden = false;
  };

  fetch("/recherche.json")
    .then((reponse) => (reponse.ok ? reponse.json() : Promise.reject(new Error("recherche indisponible"))))
    .then((fiches: FicheCherchable[]) => {
      if (fiches.length === 0) return;
      index = new IndexDeRecherche(fiches);
      // Le champ n'apparaît que lorsque la recherche est prête.
      formulaire.hidden = false;
      champ.addEventListener("input", afficher);
      formulaire.addEventListener("submit", (evenement) => {
        evenement.preventDefault();
        afficher();
        zone.querySelector<HTMLAnchorElement>("a")?.focus();
      });
      afficher();
    })
    .catch(() => {
      // Sans les données, pas de champ de recherche. La liste et les thèmes restent.
    });
}
