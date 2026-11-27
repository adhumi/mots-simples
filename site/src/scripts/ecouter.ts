// « Tout écouter » sur la page d'un mot, avec la voix du navigateur.
// Même comportement que l'app : toute la fiche, un simple arrêt, reprise au début. Pas de pause.
// Le bouton reste caché s'il n'y a pas de voix française.

const zone = document.querySelector<HTMLElement>("[data-ecoute]");
const bouton = zone?.querySelector<HTMLButtonElement>("[data-tout-ecouter]");
const synthese = "speechSynthesis" in window ? window.speechSynthesis : null;

if (zone && bouton && synthese) {
  const libelle = bouton.querySelector<HTMLElement>("[data-libelle]");
  const iconeEcouter = bouton.querySelector<HTMLElement>("[data-icone-ecouter]");
  const iconeArreter = bouton.querySelector<HTMLElement>("[data-icone-arreter]");
  let voix: SpeechSynthesisVoice | null = null;
  let lecture = 0; // change à chaque départ et à chaque arrêt : les événements d'une lecture arrêtée sont ignorés
  let enCours = false;

  const voixFrancaise = (): SpeechSynthesisVoice | null => {
    const voixDisponibles = synthese.getVoices().filter((v) => v.lang.toLowerCase().startsWith("fr"));
    return voixDisponibles.find((v) => v.lang.toLowerCase() === "fr-fr") ?? voixDisponibles[0] ?? null;
  };

  const montrer = (lit: boolean): void => {
    enCours = lit;
    if (libelle) libelle.textContent = lit ? (bouton.dataset.texteArreter ?? "") : (bouton.dataset.texteEcouter ?? "");
    if (iconeEcouter) iconeEcouter.hidden = lit;
    if (iconeArreter) iconeArreter.hidden = !lit;
  };

  const effacerLaMiseEnEvidence = (): void => {
    document.querySelectorAll(".lue").forEach((e) => e.classList.remove("lue"));
  };

  const arreter = (): void => {
    lecture++;
    synthese.cancel();
    effacerLaMiseEnEvidence();
    montrer(false);
  };

  const lire = (): void => {
    arreter();
    const elements = [...document.querySelectorAll<HTMLElement>("[data-fiche] [data-lire]")];
    if (elements.length === 0) return;
    const cetteLecture = ++lecture;
    montrer(true);
    elements.forEach((element, i) => {
      // data-lire="texte" remplace le texte affiché : prononciation d'un sigle, titre parlé.
      const parole = new SpeechSynthesisUtterance(element.dataset.lire || element.textContent?.trim() || "");
      parole.lang = "fr-FR";
      if (voix) parole.voice = voix;
      parole.rate = 0.9;
      parole.onstart = () => {
        if (cetteLecture !== lecture) return;
        effacerLaMiseEnEvidence();
        if (element.classList.contains("phrase")) element.classList.add("lue");
      };
      const fin = (): void => {
        if (cetteLecture !== lecture) return;
        element.classList.remove("lue");
        if (i === elements.length - 1) montrer(false);
      };
      parole.onend = fin;
      parole.onerror = fin;
      synthese.speak(parole);
    });
  };

  const preparer = (): void => {
    voix = voixFrancaise();
    if (voix) zone.hidden = false;
  };

  // Certains navigateurs chargent les voix après la page.
  preparer();
  synthese.addEventListener?.("voiceschanged", preparer);

  bouton.addEventListener("click", () => (enCours ? arreter() : lire()));
  // Quitter la page arrête la lecture.
  window.addEventListener("pagehide", () => synthese.cancel());
}
