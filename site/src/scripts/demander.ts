// Recopie dans le champ le mot cherché sur l'accueil : /demander?mot=girafe. Un plus, sans lequel la page marche.
const champ = document.querySelector<HTMLInputElement>("#mot");
const mot = new URLSearchParams(window.location.search).get("mot");
if (champ && mot) champ.value = mot.slice(0, 40);
