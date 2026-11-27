# Rapport du lot 3 : site

27 novembre 2026. Branche `lot-3`, partie de `lot-2`.

## Résumé

Le site se construit en statique à partir de `content/`, dans les deux modes. Chaque fiche a sa page.
Le paquet de contenu est servi à côté. Tout est en noindex. Rien n'est déployé.
Contrairement à l'app, **le site a été construit, lancé et testé ici**, dans un vrai navigateur.

## Critères de fin

| Critère | État |
| --- | --- |
| Le site se construit dans les deux modes, sans erreur | Tenu. Vérifié à chaque `npm run ci` |
| Toutes les fiches du mode choisi ont leur page | Tenu. Préversion : 20 fiches, 20 pages. Public : 0 fiche, 0 page, l'accueil le dit |
| L'audit automatisé ne remonte aucun défaut bloquant | Tenu. axe : 0 défaut sur 6 pages, en clair et en sombre |
| Chaque page porte le noindex, et la configuration serveur pose l'en-tête | Tenu. Balise sur les 34 pages, en-tête sur toutes les réponses, erreurs et redirections comprises |
| Aucun cookie, aucun script tiers | Tenu. Vérifié dans les fichiers et dans le navigateur |
| `docs/deploiement.md` et le rapport sont écrits | Tenu |

## Résultats des contrôles

`npm run check:site`, lancé par `npm run ci` :

| Contrôle | Résultat |
| --- | --- |
| Construction en mode public et en mode préversion | Passe |
| Préversion indexable refusée à la construction | Passe |
| Balise noindex, langue, titre, description sur chaque page | Passe |
| Un seul `h1`, titres dans l'ordre | Passe |
| Liens internes et ancres | Passe, aucun lien cassé |
| Aucune ressource d'un autre site, aucun script ni style écrit dans la page | Passe |
| Poids par page hors image, moins de 100 Ko | Passe, voir plus bas |
| En-tête `X-Robots-Tag` sur 16 adresses, aucun cookie, politique de sécurité | Passe |
| Cache court pour le manifeste, long pour le paquet demandé avec sa version | Passe |
| Audit axe : WCAG 2.0, 2.1 et 2.2 niveaux A et AA, plus bonnes pratiques | Passe, 0 défaut |
| Écran de 320 pixels sans défilement horizontal | Passe. C'est l'équivalent d'un zoom à 400 % |
| Sans JavaScript : accueil, liste, fiche | Passe |
| Recherche avec une faute, navigation au clavier, focus visible | Passe |

Un audit automatique ne remplace pas l'audit RGAA humain prévu au lot 5. Il ne voit qu'une partie des critères.

## Poids des pages

Sans compression, hors image, page et tout ce qu'elle charge :

| Page | Poids total | Dont HTML |
| --- | --- | --- |
| Accueil | 57,5 Ko | 8,3 Ko |
| Mot « facture » | 56,0 Ko | 8,0 Ko |
| Thème « Argent » | 53,7 Ko | 7,1 Ko |
| Tous les mots | 65,2 Ko | 18,6 Ko |

La police Lexend pèse 39,7 Ko à elle seule. Le serveur compresse le texte en Brotli ou en gzip.
À cent fiches, la page « Tous les mots » passera vers 110 Ko sans compression. Voir « Doutes ».

## Captures

Dans `docs/rapports/captures/` : accueil, fiche en clair, fiche en sombre, liste. Largeur d'un téléphone.

## Choix pris

- **Astro 7**, sortie statique, aucun framework côté client. Un espace de travail npm : un seul `npm ci` pour tout le dépôt.
- **Pas de collection de contenu Astro.** Le site lit les fiches avec `tools/build-content.ts` et `tools/schema.ts`.
  Il affiche donc exactement le paquet que l'app reçoit, avec la même règle de publication. Une seule définition du schéma.
- **Adresses sans extension ni barre finale** : `/mot/facture`. Le serveur redirige `/mot/facture.html` et `/mots/`.
- **Serveur en Node, sans dépendance**, plutôt qu'un serveur web classique. Raison : je peux le tester ici, en-têtes compris.
  Il charge le site en mémoire, compresse, et ne journalise aucune requête. Si Adrien préfère Caddy ou nginx, les règles sont dans `site/serveur.mjs`.
- **Un seul réglage pour le noindex** : `INDEXATION`. La construction l'écrit dans un fichier que le serveur lit.
- **Paquet servi sous `/contenu/v1/`**, par deux pages Astro. Mêmes octets que `npm run build:content`, c'est vérifié.
  Le paquet a un cache long seulement quand il est demandé avec sa version, `paquet.json?v=<version>`. Sinon 5 minutes.
  L'app du lot 4 le demande ainsi.
- **Police** : Lexend, retenue au lot 2, servie par le site lui-même. Fichier variable, sous-ensemble latin, licence à côté.
  Source : paquet npm `@fontsource-variable/lexend`, copié une fois. Pas de dépendance.
- **Recherche** : le champ n'apparaît que si JavaScript fonctionne. Le mot cherché ne quitte pas le navigateur.
  C'est le même code que la référence testée au lot 2, `tools/recherche.ts`.
- **Écoute** : le bouton n'apparaît que si le navigateur a une voix française. Il lit la prononciation des sigles.
  Il dit « Exemple. » et « Autres sens. » avant ces blocs, comme l'app.
- **Statut** : même place que dans l'app. En haut pour un brouillon, en bas sinon.
- **Bandeau de préversion** sur toutes les pages en mode préversion.
- **Thèmes** : les huit pages existent toujours, même vides. Une page vide le dit.
- **Images** : petits dessins au trait écrits à la main, dans le HTML. Aucune bibliothèque d'icônes.
- **Politique de sécurité stricte** : aucun script ni style dans le HTML, rien d'un autre site.
- **Dépendances ajoutées**, avec leur raison :
  - `astro` : le générateur décidé dans les specs.
  - `axe-core` : l'audit d'accessibilité automatisé demandé par le brief.
  - `playwright`, version fixée : ouvrir les pages dans un navigateur pour l'audit et les tests sans JavaScript.
    Sur un autre poste, lancer une fois `npx playwright install chromium`.

## Ce qui n'est pas fait

- **Image de partage** avec le mot et son pictogramme. Elle demande de fabriquer des images, donc une dépendance de plus,
  et les pictogrammes ne sont pas choisis. Je propose de la faire au lot 5, avec les pictogrammes.
- **Page « Demander un mot »** : prévue au lot 4, comme le dit le brief.
- **Bandeau « ouvrir dans l'app »** : prêt, mais éteint tant que `APP_STORE_ID` est vide.
- **Lien vers l'app** sur l'accueil : une phrase dit que l'app arrive. Pas de lien, l'app n'a pas d'adresse.
- **Construction Docker** : non jouée, pas de Docker utilisable ici. Les commandes du Dockerfile ont été rejouées à la main.

## Textes d'interface à relire

Les textes courts sont dans `site/src/lib/textes.ts`. Les trois pages de texte sont dans `site/src/pages/`.

| Endroit | Texte |
| --- | --- |
| Partout | Mots simples |
| Partout | Le dictionnaire des mots compliqués, expliqués simplement. |
| Partout | Aller au contenu |
| Préversion | Préversion. Ce site n'est pas encore public. |
| Menu | Accueil · Tous les mots |
| Pied de page | C'est quoi ce dictionnaire ? · Vie privée · Accessibilité |
| Pied de page | Pictogrammes : Sergio Palao, ARASAAC, Gouvernement d'Aragon. Licence Creative Commons BY-NC-SA. |
| Pied de page | Textes sous licence Creative Commons BY-NC-SA 4.0. Code sous licence MIT. |
| Accueil | Chercher un mot |
| Accueil | Écrivez le mot |
| Accueil | Par exemple : facture |
| Accueil | Résultats |
| Accueil | Ce mot n'est pas encore dans le dictionnaire. |
| Accueil | Les thèmes |
| Accueil | 1 mot · … mots |
| Accueil | Voir tous les mots |
| Accueil | L'application pour iPhone |
| Accueil | L'application arrive bientôt. Elle marche sans internet. |
| Accueil, mode public vide | Le dictionnaire n'est pas encore ouvert. Les premiers mots arrivent bientôt. |
| Thème vide | Il n'y a pas encore de mot dans ce thème. |
| Liste vide | Il n'y a pas encore de mot dans le dictionnaire. |
| Fiche | Définition · Exemple · Autre sens · Autres sens · À ne pas confondre · Mots liés · Thème |
| Fiche | Tout écouter · Arrêter |
| Statut | Brouillon non relu. Ce texte n'est pas encore vérifié. |
| Statut | Pas encore validé. Ce texte est vérifié. Il n'est pas encore testé avec des lecteurs. |
| Statut | Validé le … |
| Pages provisoires | Texte provisoire. Il sera complété avant l'ouverture du site. |
| Page introuvable | Cette page n'existe pas |
| Page introuvable | L'adresse est peut-être mal écrite. Vous pouvez chercher un mot depuis l'accueil. |
| Page introuvable | Retour à l'accueil |

Les pages « C'est quoi ce dictionnaire ? », « Vie privée » et « Accessibilité » sont à relire en entier.
Dans « C'est quoi ce dictionnaire ? », j'ai écrit : « Adrien Humilière fait ce dictionnaire. C'est un projet personnel, pour aider. »
et « Un ordinateur écrit un premier texte. » À confirmer ou à réécrire.

## Doutes

- **Le mot « FALC »** n'apparaît nulle part sur le site, aucune fiche n'étant validée. Il faudra décider où il apparaît au lot 5.
- **Le crédit ARASAAC** est dans le pied de page alors qu'aucun pictogramme n'est encore affiché. Je l'ai laissé : la licence le demande dès qu'ils arrivent.
- **Poids de la liste** à cent fiches : la page « Tous les mots » dépassera 100 Ko sans compression.
  Deux sorties possibles : compter le poids compressé, ou retirer les petites images de cette page.
- **La voix du navigateur** n'a pas pu être écoutée : le navigateur de test n'a pas de voix. Le code est écrit, à vérifier à l'oreille.
- **Le thème d'une fiche** est un lien dans la page du mot. Sur l'app, c'est un simple texte jusqu'au lot 4.

## Ce qu'Adrien doit faire

1. Lire `docs/deploiement.md` et déployer quand il le décide.
2. Remplacer `EQUIPE_A_REMPLACER` dans le fichier des liens universels.
3. Relire les textes d'interface et les trois pages de texte.
4. Écouter une fiche dans Safari et dans Chrome.
5. Décider du sort de l'image de partage.
