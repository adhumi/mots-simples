# Rapport du lot 2 : prototype de l'app

27 novembre 2026. Branche `lot-2`, partie de `lot-1`.

## À lire d'abord

**Aucune ligne de Swift n'a été compilée.** Le conteneur de travail est sous Linux, sans Xcode et sans compilateur Swift.
Je n'ai pas pu en installer un : le site de téléchargement de Swift est bloqué par la politique réseau.
Le brief prévoyait ce cas. J'ai donc écrit tout le code, mais trois critères de fin ne sont pas vérifiés :

| Critère | État |
| --- | --- |
| `npm run ci` passe, génération du paquet comprise | **Tenu.** 80 tests passent |
| `swift test` passe sur `DictionaryCore` | **Non vérifié.** Tests écrits, jamais lancés |
| L'app se compile pour le simulateur iOS 26 et se lance sans réseau | **Non vérifié.** Code écrit, jamais compilé |
| Du lancement à une fiche : trois touchers au plus | Deux touchers par construction. Un test d'interface le rejoue. Non lancé |
| L'écoute fonctionne comme décrit, arrêt compris | Code écrit. À vérifier à l'oreille |
| Le rapport est écrit, sur la branche `lot-2` | **Tenu** |

Il faut s'attendre à des erreurs de compilation à la première ouverture dans Xcode. Elles devraient être petites.
Pour réduire le risque sur la partie la plus délicate, la recherche, j'en ai écrit une version de référence en TypeScript.
Elle est testée ici, sur le même corpus de requêtes que la version Swift.

## Ce qui tourne et qui est testé

- **`tools/build-content.ts`** : le paquet de contenu, en mode public ou préversion. 9 tests. Format dans `docs/paquet.md`.
- **`tools/recherche.ts`** : la recherche de référence. 52 requêtes de corpus rejouées, plus des tests d'ordre et de faute.
  Le site du lot 3 l'utilisera tel quel.
- **`tools/embed-content.ts`** : copie le paquet dans l'app et dans les tests Swift. `--check` tourne dans `npm run ci`.

## Ce qui est écrit sans être compilé

- **`ios/Packages/DictionaryCore`** : modèle `Codable`, chargement avec contrôle du schéma, de la taille et de l'empreinte SHA-256,
  recherche, derniers mots. 25 tests Swift Testing, dont le corpus de requêtes.
- **`ios/Packages/DictionaryUI`** : accueil, résultats, mot absent, fiche, écoute, jetons de style, police, catalogue de chaînes.
- **`ios/MotsSimples`** : la cible d'app. **`ios/MotsSimplesUITests`** : 6 tests d'interface, dont l'audit d'accessibilité
  sur l'accueil, sur une fiche, et à la plus grande taille de texte.
- **`ios/MotsSimples.xcodeproj`** : écrit à la main, au format des dossiers synchronisés de Xcode 16 et suivants.
  C'est le fichier le plus risqué. `ios/README.md` dit comment recréer le projet en cinq étapes s'il ne s'ouvre pas.

Pas de capture d'écran : il n'y a pas de simulateur.

## Choix pris

- **Version du paquet** : les 12 premiers caractères du SHA-256 du contenu. Elle ne dit pas quel paquet est le plus récent,
  seulement s'il est différent. C'est ce que demande le lot 4 : « si la version diffère ».
- **`genere_le`** : la date la plus récente portée par les fiches, pour rester déterministe. `--date` la remplace.
- **Thèmes dans le paquet** : les huit thèmes et leurs noms sont dans `paquet.json`. Une seule liste pour le site et l'app.
- **`a_ne_pas_confondre.nom`** : champ ajouté au paquet. Il donne le mot tel qu'on l'écrit, même s'il n'a pas encore de fiche.
  Sans lui, « à ne pas confondre avec devis » ne pouvait pas s'afficher proprement.
- **Recherche** : sept rangs, du meilleur au moins bon. Mot exact, début du mot, début d'un mot de l'expression,
  forme déclarée exacte, début d'une forme, une faute sur le mot, une faute sur une forme.
  La tolérance à une faute commence à 4 lettres, pour éviter le bruit. Les petits mots comme « de » ne comptent pas.
- **Pluriel et féminin** : par les formes déclarées, et par la tolérance à une faute. Pas de règle de grammaire.
- **Derniers mots** : `UserDefaults`, une liste de 10 slugs. Le plus simple qui tienne.
- **Police** : **Lexend est retenue.** Licence SIL Open Font License 1.1, qui permet de l'embarquer.
  Trois graisses dans l'app : Regular, SemiBold, Bold. Fichiers pris dans le paquet npm `@expo-google-fonts/lexend`,
  faute d'accès à Google Fonts. La licence est copiée à côté. À créditer dans « Aide et à propos » au lot 4.
  Avec « Texte en gras », chaque style monte d'une graisse.
- **Navigation** : `NavigationStack` standard. Le bouton « Retour » est celui du système, donc en verre sur iOS 26.
- **Liquid Glass** : un seul élément en verre dans ce lot, la barre « Tout écouter ».
  Elle devient opaque avec « Réduire la transparence » ou « Augmenter le contraste ».
- **Bandeau de statut** : en haut de la fiche pour un brouillon, car c'est un avertissement. En bas pour « relu » et « validé ».
- **Titres parlés** : « Tout écouter » dit « Exemple. » et « Autres sens. » avant ces blocs. Sans cela, on ne sait pas où on en est à l'oreille. À confirmer en séance.
- **Phrase en cours** : fond coloré et trait vert à gauche. Jamais la couleur seule.
- **Vitesse de la voix** : deux boutons en bas de chaque fiche. Ils iront dans « Aide et à propos » au lot 4.
- **Mode préversion** : réglage `MOTS_SIMPLES_PREVERSION` dans `ios/Config/MotsSimples.xcconfig`. Il vaut `YES`.
- **Icône de l'app** : absente. L'emplacement est prêt dans `Assets.xcassets`.
- **Image neutre** : un carré vert pâle avec un symbole d'image, tant que `pictogramme.id` est vide. VoiceOver lit le texte `alt` sur la fiche.

## Textes de l'interface à relire

Ils sont tous dans `ios/Packages/DictionaryUI/Sources/DictionaryUI/Textes.swift`.

| Écran | Texte |
| --- | --- |
| Accueil | Mots simples |
| Accueil | Chercher un mot |
| Accueil | Écrivez le mot |
| Accueil | Par exemple : facture |
| Accueil | Effacer |
| Accueil | Vos derniers mots |
| Accueil | Les mots que vous ouvrez s'affichent ici. |
| Accueil | Résultats |
| Accueil | Le dictionnaire est vide pour le moment. |
| Mot absent | Ce mot n'est pas encore dans le dictionnaire. |
| Mot absent | Mots proches |
| Écoute | Écouter |
| Écoute | Arrêter |
| Écoute | Tout écouter |
| Écoute, VoiceOver | Écouter le mot … |
| Écoute, VoiceOver | Écouter : … |
| Écoute | Vitesse de la voix |
| Écoute | Normale |
| Écoute | Lente |
| Fiche | Définition |
| Fiche | Exemple |
| Fiche | Autre sens / Autres sens |
| Fiche | À ne pas confondre |
| Fiche, voix | À ne pas confondre avec : … |
| Fiche | Mots liés |
| Fiche | Thème : … |
| Fiche | Cette fiche n'existe plus. |
| Statut | Brouillon non relu |
| Statut | Ce texte n'est pas encore vérifié. |
| Statut | Pas encore validé |
| Statut | Ce texte est vérifié. Il n'est pas encore testé avec des lecteurs. |
| Statut | Validé / Validé le … |

## Doutes

- `.buttonStyle(.glassProminent)` : écrit de mémoire pour iOS 26. À vérifier à la compilation.
- La classe `LecteurVocal` mêle `@Observable`, `NSObject` et un délégué appelé hors du fil principal. C'est l'endroit le plus probable d'une erreur Swift 6.
- Les polices sont enregistrées à la main depuis le paquet Swift. Si Lexend ne s'affiche pas, c'est là qu'il faut regarder.
- L'audit d'accessibilité automatique peut signaler le contraste du texte d'exemple du champ de recherche.

## Ce qu'Adrien doit vérifier

1. Ouvrir `ios/MotsSimples.xcodeproj` dans Xcode 26. Noter ce qui ne compile pas.
2. `cd ios/Packages/DictionaryCore && swift test`.
3. Lancer l'app dans le simulateur en mode avion. Chercher « facture », ouvrir, écouter, arrêter.
4. Vérifier que la lecture s'entend, interrupteur du téléphone sur silencieux. Cela demande un vrai téléphone.
5. Écouter les quatre sigles.
6. Relire les textes du tableau ci-dessus.
