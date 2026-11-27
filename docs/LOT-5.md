# Lot 5 : finition et publication

## But

À la fin de ce lot, la V1 est publiée : app sur l'App Store, site indexé, une centaine de fiches dont une part validée en séance.

Ce lot est différent des autres : l'essentiel est fait par des personnes.
Les séances, la relecture, la validation et la publication ne sont pas ton travail.
Ton rôle est de préparer, d'outiller et de vérifier. Chaque point marqué **Adrien** est un arrêt : prépare ce qu'il faut, puis passe à la suite.

Prérequis : les lots 1 à 4 sont terminés. Lis `CLAUDE.md` et la section « Vie privée, licences et qualité » de `docs/specs.md`.

## Ce que tu peux faire seul

### 1. Les 86 fiches restantes, en brouillon

- Les lignes `lot` = 2 de `content/liste-v1.csv`, avec `prompts/generer-fiche.md`, par groupes d'un thème.
- Mêmes règles qu'au lot 1 : source ouverte ou `url: null`, un commit par fiche, `npm run check` sans erreur.
- À la fin de chaque thème, relis le thème entier pour la cohérence.
- Tiens compte des corrections qu'Adrien a faites sur les 20 fiches pilotes : regarde l'historique de ces fichiers avant d'écrire.

### 2. Outiller la relecture et les séances

- Une commande qui produit une feuille de relecture par thème : la fiche, sa source, ses notes, une case « relu ».
- Une commande qui produit le support de séance : une fiche par page, gros caractères, sans rien d'autre, imprimable.
- Une commande qui passe une fiche à `relu` ou à `valide` avec la date, à lancer par Adrien. Elle refuse de valider une fiche non relue.
- Un tableau d'avancement : nombre de fiches par statut et par thème.

### 3. Pictogrammes

- Pour chaque fiche, propose 1 à 3 pictogrammes ARASAAC candidats, avec leur identifiant, dans un fichier de propositions.
  Ne remplis pas `pictogramme.id` : le choix se fait en regardant les images.
- Prépare le script qui récupère les pictogrammes choisis et les range dans `content/pictogrammes/`.
- Vérifie que le crédit ARASAAC apparaît dans l'app, sur le site et dans `LICENSE-CONTENT.md`.

### 4. Audits

- Audit d'accessibilité complet du site contre le RGAA : une grille, critère par critère, avec le résultat et la preuve.
- Même travail pour l'app, à partir des tests du lot 4.
- Corrige ce qui est bloquant. Liste le reste par ordre de gravité.
- Rédige la déclaration d'accessibilité à partir des résultats réels, sans rien embellir.

### 5. Textes à préparer

Des projets, tous écrits simplement, à faire relire :

- La fiche App Store : nom, sous-titre, description, mots-clés, nouveautés. Aucune promesse que le contenu ne tient pas.
- Les étiquettes d'accessibilité de l'App Store, d'après ce qui est réellement pris en charge.
- La page « Vie privée et mentions légales » : version simple en premier, version complète en dessous.
  Laisse en évidence ce qui demande l'identité de l'éditeur et de l'hébergeur.
- La page « À propos », avec le nombre réel de fiches validées.

### 6. Liste de publication

`docs/publication.md` : tout ce qui doit être vrai avant de publier, dans l'ordre, avec qui fait quoi.

## Ce qui attend Adrien

| Étape | Qui | Ce que tu prépares |
| --- | --- | --- |
| Relire les fiches contre leur source | **Adrien** | Les feuilles de relecture |
| Séances avec des personnes concernées | **Adrien**, avec Sophia si elle le souhaite | Le support de séance et une grille d'observation |
| Passer les fiches à `relu` puis `valide` | **Adrien** | La commande |
| Choisir les pictogrammes | **Adrien**, puis test en séance | Les propositions |
| Valider les textes légaux | **Adrien** | Les projets |
| Déployer le site et le point de collecte | **Adrien** | `docs/deploiement.md` à jour |
| Envoyer sur TestFlight, puis soumettre | **Adrien** | `docs/testflight.md` à jour |
| Retirer le noindex | **Adrien** | La procédure, et la vérification à faire après |

## Critères de sortie de la V1

Repris des specs. Coche ce que tu peux vérifier, laisse le reste à Adrien.

- [ ] Toutes les fiches publiées sont au moins relues, et le nombre de fiches validées est affiché honnêtement.
- [ ] Les trois tâches de séance sont réussies sans aide : trouver un mot, l'écouter, le retrouver dans ses derniers mots.
- [ ] Tous les critères d'acceptation de l'app sont tenus sur le plus ancien iPhone pris en charge.
- [ ] Les audits d'accessibilité de l'app et du site ne laissent aucun défaut bloquant.
- [ ] L'app fonctionne en Accès d'aide.
- [ ] La fiche App Store et le site sont écrits simplement et relus en séance.
- [ ] Le paquet public ne contient aucun brouillon.
- [ ] Le noindex est retiré, et vérifié en ligne.

## Rapport

`docs/rapports/lot-5.md` : avancement par statut, résultats des audits, ce qui est prêt, ce qui attend Adrien, dans l'ordre où il doit le faire.

## Tu ne fais pas

- Passer une fiche à `relu` ou `valide`.
- Publier, soumettre, déployer, retirer le noindex.
- Écrire « facile à lire et à comprendre » ou « FALC » pour un contenu qui n'est pas validé.
