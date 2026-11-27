# Lot 3 : site

## But

À la fin de ce lot, le site se construit en statique à partir de `content/`, chaque mot a sa page,
le paquet de contenu est servi à côté, et tout est prêt à être déployé sur Railway en noindex.
Tu prépares le déploiement, tu ne le fais pas.

Prérequis : `tools/build-content.ts` existe (lot 2). S'il manque, écris-le d'abord en suivant le brief du lot 2, tâche 1.
Lis `CLAUDE.md`, puis la section « Site web » de `docs/specs.md`.

## Tâches, dans l'ordre

### 1. Le socle Astro

- Projet Astro dans `site/`, sortie statique, sans framework d'interface côté client.
- Les fiches sont lues depuis `../content/mots` avec le schéma de `tools/schema.ts`. Une seule définition du schéma dans le dépôt.
- Une variable d'environnement choisit le mode, `preversion` ou `public`, avec la même règle que le paquet :
  `public` ne contient que `relu` et `valide`. Le mode par défaut en local est `preversion`.
- En mode `public` sans aucune fiche publiable, le site se construit quand même et l'accueil le dit simplement.

### 2. Les pages

| Page | Adresse | Contenu |
| --- | --- | --- |
| Accueil | `/` | Champ de recherche, les huit thèmes, lien vers l'app |
| Mot | `/mot/<slug>` | La même fiche que dans l'app, dans le même ordre |
| Thème | `/theme/<slug>` | Les mots du thème |
| Tous les mots | `/mots` | Liste alphabétique complète |
| À propos | `/a-propos` | Pour qui, par qui, comment les définitions sont écrites et validées |
| Vie privée | `/vie-privee` | Version simple en premier. Texte provisoire, marqué comme tel |
| Accessibilité | `/accessibilite` | Texte provisoire, marqué comme tel |

La page « Demander un mot » figure dans les specs et fait bien partie de la V1. Elle est seulement livrée au lot 4, avec le point de collecte : ne la crée pas ici.

Sur la page d'un mot :

- Statut affiché : « Brouillon non relu » en préversion, « Pas encore validé » pour `relu`, « Validé » avec la date pour `valide`.
- Bouton « Tout écouter » avec la synthèse vocale du navigateur, affiché seulement si une voix française existe.
  Même comportement que l'app : toute la fiche, arrêt simple, reprise au début.
- Mots liés et « à ne pas confondre » en liens. Un lien vers un mot sans page n'est pas affiché comme lien.

### 3. Exigences

- **Sans JavaScript**, chaque page reste lisible et on trouve un mot par la liste et les thèmes. La recherche instantanée est un plus.
- **Accessibilité** : RGAA 4 et WCAG 2.2 AA visés. Zoom à 200 %, navigation au clavier, focus toujours visible,
  thème clair et sombre, animations coupées si le système le demande. Un seul `h1` par page, des titres dans l'ordre.
- **Interface écrite simplement** : vouvoiement, phrases courtes, un texte et une image sur chaque bouton, aucune fenêtre surgissante.
- **Sobriété** : moins de 100 Ko par page hors image, aucun cookie, aucun traceur, aucun script tiers, aucune mesure d'audience.
- **Polices** : celles du système, sauf si Lexend a été retenue au lot 2 ; dans ce cas elle est servie par le site lui-même, pas par un service tiers.
- **Adresses stables** : `/mot/<slug>` ne change jamais.
- **Référencement prêt mais fermé** : titre « Mot : définition simple », description tirée de la première phrase,
  données structurées `DefinedTerm`, plan du site. Et le noindex ci-dessous.

### 4. Noindex

Tant que la V1 n'est pas publiée, tout le site est en noindex :

- balise `<meta name="robots" content="noindex, nofollow">` sur chaque page ;
- en-tête HTTP `X-Robots-Tag: noindex, nofollow` posé par le serveur ;
- pas de blocage dans `robots.txt` : un robot bloqué ne lit pas la consigne.

Un seul réglage commande les deux. Il vaut « noindex » par défaut. Le retirer est une décision d'Adrien, au lot 5.

### 5. Le paquet de contenu

- La construction du site génère aussi le paquet, dans le même mode, et le sert sous `/contenu/v1/`.
- `manifest.json` et `paquet.json` sont servis avec des en-têtes de cache adaptés : court pour le manifeste, long pour le paquet.

### 6. Contrôles automatiques

Ajoute à `npm run ci`, ou à une commande voisine documentée :

- construction du site dans les deux modes ;
- audit d'accessibilité automatisé sur l'accueil, une page de mot, une page de thème et la liste ;
- vérification des liens internes ;
- vérification du poids des pages et de l'absence de script tiers ;
- vérification que chaque page porte bien le noindex.

### 7. Préparer le déploiement, sans le faire

- De quoi servir le site statique sur Railway avec l'en-tête `X-Robots-Tag` : fichier de conteneur ou configuration équivalente.
- `docs/deploiement.md` : les étapes exactes pour Adrien, les variables à définir, comment brancher motssimples.fr, comment vérifier le noindex une fois en ligne.
- Le fichier des liens universels pour iOS a besoin de l'identifiant d'équipe Apple : prépare-le avec une valeur à remplacer, signalée dans le rapport.

### 8. Rapport

`docs/rapports/lot-3.md` : résultats des contrôles, poids des pages, textes d'interface à relire, choix pris, ce qui reste à faire par Adrien.

## Critères de fin

- [ ] Le site se construit dans les deux modes, sans erreur.
- [ ] Toutes les fiches du mode choisi ont leur page.
- [ ] L'audit automatisé ne remonte aucun défaut bloquant.
- [ ] Chaque page porte le noindex, et la configuration serveur pose l'en-tête.
- [ ] Aucun cookie, aucun script tiers.
- [ ] `docs/deploiement.md` et le rapport sont écrits, sur la branche `lot-3`.

## Tu ne fais pas

- Déployer, créer un service Railway, toucher aux DNS.
- Retirer le noindex.
- Écrire des mentions légales définitives : elles restent provisoires jusqu'au lot 5.
