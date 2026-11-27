// Tous les textes de l'interface du site, au même endroit, pour les relire d'une traite.
// Vouvoiement, phrases courtes, mots de tous les jours. Les pages longues (à propos, vie privée,
// accessibilité) portent leur texte dans leur propre fichier.
export const textes = {
  nomDuSite: "Mots simples",
  slogan: "Le dictionnaire des mots compliqués, expliqués simplement.",
  allerAuContenu: "Aller au contenu",
  preversion: "Préversion. Ce site n'est pas encore public.",

  // Menu et pied de page
  accueil: "Accueil",
  tousLesMots: "Tous les mots",
  demanderUnMot: "Demander un mot",
  aPropos: "C'est quoi ce dictionnaire ?",
  viePrivee: "Vie privée",
  accessibilite: "Accessibilité",
  creditPictogrammes: "Pictogrammes : Sergio Palao, ARASAAC, Gouvernement d'Aragon. Licence Creative Commons BY-NC-SA.",
  creditContenu: "Textes sous licence Creative Commons BY-NC-SA 4.0. Code sous licence MIT.",

  // Accueil
  chercherUnMot: "Chercher un mot",
  ecrivezLeMot: "Écrivez le mot",
  exempleDeRecherche: "Par exemple : facture",
  resultats: "Résultats",
  motAbsent: "Ce mot n'est pas encore dans le dictionnaire.",
  lesThemes: "Les thèmes",
  voirTousLesMots: "Voir tous les mots",
  lApp: "L'application pour iPhone",
  lAppBientot: "L'application arrive bientôt. Elle marche sans internet.",
  dictionnaireFerme: "Le dictionnaire n'est pas encore ouvert. Les premiers mots arrivent bientôt.",

  // Listes
  aucunMotDansLeTheme: "Il n'y a pas encore de mot dans ce thème.",
  aucunMot: "Il n'y a pas encore de mot dans le dictionnaire.",
  unMot: "1 mot",
  plusieursMots: (n: number) => `${n} mots`,

  // Fiche
  definition: "Définition",
  exemple: "Exemple",
  autreSens: "Autre sens",
  autresSens: "Autres sens",
  aNePasConfondre: "À ne pas confondre",
  aNePasConfondreAvec: (mot: string) => `À ne pas confondre avec : ${mot}.`,
  motsLies: "Mots liés",
  theme: "Thème",
  toutEcouter: "Tout écouter",
  arreter: "Arrêter",
  titreDeFiche: (mot: string) => `${mot} : définition simple`,

  // Statut
  brouillonNonRelu: "Brouillon non relu",
  brouillonExplication: "Ce texte n'est pas encore vérifié.",
  pasEncoreValide: "Pas encore validé",
  pasEncoreValideExplication: "Ce texte est vérifié. Il n'est pas encore testé avec des lecteurs.",
  valide: "Validé",
  valideLe: (date: string) => `Validé le ${date}`,

  // Demander un mot
  demanderCeMot: "Demander ce mot",
  demanderExplication: "Un mot manque dans le dictionnaire ? Écrivez-le ici.",
  demanderLeMot: "Le mot que vous voulez",
  demanderRappel: "Écrivez seulement le mot. N'écrivez pas votre nom. N'écrivez rien de personnel.",
  demanderEnvoyer: "Envoyer le mot",
  demanderCeQuiPart: "Seul le mot est envoyé. Nous ne savons pas qui vous êtes.",
  demanderFerme: "On ne peut pas encore demander un mot ici. Cela arrive bientôt.",
  merciTitre: "Merci, le mot est envoyé",
  merciExplication: "Nous regardons les mots les plus demandés pour écrire les prochaines fiches.",
  merciSansReponse: "Vous ne recevrez pas de réponse, car nous ne savons pas qui vous êtes.",
  erreurTitre: "Le mot n'est pas parti",
  erreurExplication: "Écrivez un seul mot ou une expression courte, avec des lettres seulement. Pas de chiffre.",
  plusTardTitre: "Réessayez un peu plus tard",
  plusTardExplication: "Il y a trop de demandes en ce moment. Le mot n'est pas parti.",
  recommencer: "Demander un autre mot",
  reessayer: "Réessayer",

  // Pages provisoires
  texteProvisoire: "Texte provisoire. Il sera complété avant l'ouverture du site.",

  // Page introuvable
  pageIntrouvable: "Cette page n'existe pas",
  pageIntrouvableExplication: "L'adresse est peut-être mal écrite. Vous pouvez chercher un mot depuis l'accueil.",
  retourAccueil: "Retour à l'accueil",
} as const;
