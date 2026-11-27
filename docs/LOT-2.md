# Lot 2 : prototype de l'app

## But

À la fin de ce lot, une app iOS se lance dans le simulateur, permet de chercher un mot,
d'ouvrir sa fiche et de l'écouter, hors ligne, avec le contenu du lot 1 embarqué.

Prérequis : le lot 1 est terminé et `npm run ci` passe.
Lis `CLAUDE.md`, puis les sections « App iOS », « Standards de la plateforme » et « Architecture technique » de `docs/specs.md`.

Si Xcode n'est pas disponible sur la machine, fais tout ce qui se teste avec `swift test`
(le module `DictionaryCore`), écris le reste du code sans le compiler, et dis-le clairement dans le rapport.

## Tâches, dans l'ordre

### 1. Le paquet de contenu

Écris `tools/build-content.ts` et ses tests. Commande : `npm run build:content`.

- Entrée : `content/mots/*.yaml`. Sortie : un dossier, par défaut `dist/contenu/v1/`.
- `paquet.json` : `schema`, `version`, `genere_le`, `preversion`, et la liste des fiches.
- `manifest.json` : `schema`, `version`, l'empreinte SHA-256 de `paquet.json`, sa taille.
- `version` est déterministe : elle dérive du contenu, pas de l'heure. Deux générations du même contenu donnent le même paquet.
- Deux modes :
  - `--public` (défaut) : seulement les fiches `relu` et `valide`.
  - `--preversion` : toutes les fiches, avec `preversion: true` dans le paquet.
- Les champs internes ne sortent pas : `source_de_reference` et `notes_de_relecture` restent dans le dépôt.
- Le contrôle des fiches tourne avant la génération. Une erreur arrête tout.
- Documente le format dans `docs/paquet.md`. Ajoute `build:content` à `npm run ci`.

### 2. Le cœur : `DictionaryCore`

Paquet Swift dans `ios/Packages/DictionaryCore`, sans dépendance, testé avec Swift Testing.

- Modèle `Codable` d'une fiche et du paquet. Les champs inconnus sont ignorés. Un `schema` plus récent que celui connu est refusé proprement.
- Chargement du paquet embarqué. Vérification de l'empreinte contre le manifeste.
- Recherche en mémoire :
  - normalisation : minuscules, sans accent, apostrophes unifiées ;
  - ordre des résultats : début de mot exact, puis formes de recherche, puis une faute de distance 1 ;
  - résultats dès 2 lettres.
- Tests de recherche sur un petit corpus de requêtes avec fautes, dans un fichier de données facile à compléter.
- Derniers mots consultés : 10 au plus, du plus récent au plus ancien, stockés localement.

### 3. L'interface : `DictionaryUI` et l'app

Paquet `ios/Packages/DictionaryUI`, et une cible d'app « Mots simples » dans `ios/`. SwiftUI, Swift 6, iOS 26 au minimum, iPhone et iPad.

Écrans de ce lot :

| Écran | Contenu |
| --- | --- |
| Accueil | Titre « Chercher un mot », champ de recherche avec son libellé, « Vos derniers mots » |
| Résultats | Liste au fil de la frappe, mot et image |
| Mot absent | « Ce mot n'est pas encore dans le dictionnaire. » et les mots proches. Pas d'envoi dans ce lot |
| Fiche | Image, mot, thème, définition, exemple, autres sens, « à ne pas confondre », mots liés, statut |

Écoute, avec `AVSpeechSynthesizer` et une voix française :

- « Tout écouter » lit le mot, la définition, l'exemple, les autres sens, puis « à ne pas confondre ».
- Un bouton d'écoute à côté du mot et dans l'en-tête de chaque bloc. Un bouton d'écoute par mot dans les listes.
- La phrase en cours est mise en évidence.
- Pendant la lecture, le bouton principal devient « Arrêter ». Pas de pause : après un arrêt, on repart du début.
- Quitter la fiche arrête la lecture. La lecture fonctionne en mode silencieux.
- Si la fiche a un champ `prononciation`, la voix le lit à la place du mot.
- Deux vitesses, normale et lente. Dans ce lot, un réglage simple suffit ; l'écran « Aide et à propos » vient au lot 4.

Style : voir « Direction visuelle retenue » dans les specs et les maquettes liées.

- Jetons de style centralisés : couleurs, rayons, espacements, tailles. Pas de valeur en dur dans les vues.
- Police Lexend si sa licence permet de l'embarquer (vérifie-la et crédite-la), sinon la police système arrondie. Dis ce que tu as retenu.
- Liquid Glass réservé aux éléments flottants. Rendu opaque quand « Réduire la transparence » ou « Augmenter le contraste » est activé.
- Tout bouton a une image et un mot. Cibles de 44 points au moins.
- En préversion, un bandeau « Brouillon non relu » sur chaque fiche `brouillon`, et « Pas encore validé » sur une fiche `relu`.
- Tant que `pictogramme.id` est vide, une image neutre remplace le pictogramme, avec le texte `alt` pour VoiceOver.

Textes de l'interface : vouvoiement, phrases courtes, dans un catalogue de chaînes. Liste-les dans le rapport pour relecture.

### 4. Embarquer le contenu

- Un script copie le paquet généré en mode `--preversion` dans les ressources de l'app.
- Documente la commande dans `ios/README.md`. L'app doit se lancer sans réseau dès la première ouverture.

### 5. Accessibilité de base

- Texte lisible et utilisable à la plus grande taille d'accessibilité, sans texte coupé.
- VoiceOver : libellés, titres déclarés, ordre de lecture logique.
- Un test d'interface lance l'audit d'accessibilité automatique sur l'accueil et sur une fiche.

### 6. Rapport

`docs/rapports/lot-2.md` : ce qui tourne, ce qui n'a pas été compilé ou testé, les choix pris,
les textes d'interface à relire, et des captures d'écran si tu peux en produire.

## Choix à prendre seul et à signaler

- Identifiant de l'app : `fr.adhumi.motssimples`, décidé par Adrien. Ne configure ni équipe ni signature.
- Stockage des derniers mots : le plus simple qui tienne.

## Critères de fin

- [ ] `npm run ci` passe, génération du paquet comprise.
- [ ] `swift test` passe sur `DictionaryCore`.
- [ ] L'app se compile pour le simulateur iOS 26 et se lance sans réseau.
- [ ] Du lancement à une fiche : trois touchers au plus, hors saisie.
- [ ] L'écoute fonctionne comme décrit, arrêt compris.
- [ ] Le rapport est écrit, sur la branche `lot-2`.

## Hors périmètre de ce lot

Photo, dictée, écran Thèmes, demande de mot, mise à jour du contenu à distance, Spotlight, App Intents,
liens universels, Accès d'aide, écran « Aide et à propos ». Tout cela est au lot 4.
