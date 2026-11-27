# App iOS « Mots simples »

Swift 6, SwiftUI, iOS 26 au minimum, iPhone et iPad. Aucune dépendance tierce.

**Important : ce code a été écrit sans Xcode ni compilateur Swift.**
Il n'a jamais été compilé. Voir `docs/rapports/lot-2.md` et `docs/rapports/lot-4.md` pour ce que cela implique. La marche vers TestFlight est dans `docs/testflight.md`.

## Structure

| Dossier | Contenu |
| --- | --- |
| `Packages/DictionaryCore` | Modèle, chargement vérifié du paquet, recherche, derniers mots. Testé avec Swift Testing |
| `Packages/DictionaryUI` | Écrans SwiftUI, écoute, jetons de style, police Lexend, catalogue de chaînes |
| `MotsSimples/` | La cible d'app : point d'entrée, « Expliquer un mot » pour Siri, manifeste de confidentialité, contenu embarqué |
| `MotsSimplesUITests/` | Tests d'interface : audit d'accessibilité sur chaque écran, captures, mesures de performance |
| `Config/` | `Info.plist`, droits de l'app et réglages de compilation |

## Embarquer le contenu

L'app lit un paquet de contenu rangé dans `MotsSimples/Contenu/`. Il est commité, pour que l'app se compile tout de suite.
Après toute modification d'une fiche, à la racine du dépôt :

```
npm run embed:content               # paquet de préversion : toutes les fiches, brouillons compris
npm run embed:content -- --public   # paquet public : fiches relues et validées seulement
npm run embed:content -- --check    # vérifie que la copie est à jour (lancé par npm run ci)
```

La commande copie aussi le paquet et le corpus de recherche dans les tests de `DictionaryCore`.

L'app se lance sans réseau dès la première ouverture : le paquet est dans l'app.

## Réglages de compilation

Tous dans `Config/MotsSimples.xcconfig`. Aucun secret.

| Réglage | Sens |
| --- | --- |
| `MOTS_SIMPLES_PREVERSION` | `YES` : brouillons visibles. `NO` : build public, tout paquet de préversion est refusé |
| `MOTS_SIMPLES_SITE` | Adresse du site : pages à partager et paquet de contenu sous `/contenu/v1/` |
| `MOTS_SIMPLES_DEMANDES` | Adresse du point de collecte. Vide : pas de bouton « Demander ce mot » |

## Préversion ou public

Le réglage `MOTS_SIMPLES_PREVERSION` est dans `Config/MotsSimples.xcconfig`.

- `YES` : simulateur et TestFlight. Les brouillons sont visibles, avec le bandeau « Brouillon non relu ».
- `NO` : build public. L'app refuse un paquet de préversion. Lancer d'abord `npm run embed:content -- --public`.

## Tester

```
cd ios/Packages/DictionaryCore && swift test
```

Pour l'app et les tests d'interface, ouvrir `MotsSimples.xcodeproj` dans Xcode 26, choisir un simulateur iOS 26, puis Produit > Tester.
En ligne de commande :

```
xcodebuild test -project ios/MotsSimples.xcodeproj -scheme MotsSimples \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Ni équipe ni signature ne sont configurées. Pour un vrai téléphone, choisir son équipe dans Xcode.

## Si le projet Xcode ne s'ouvre pas

`MotsSimples.xcodeproj` a été écrit à la main. S'il est refusé par Xcode, le plus court est d'en recréer un :

1. Nouveau projet, modèle App, nom `MotsSimples`, identifiant `fr.adhumi.motssimples`, dans `ios/`.
2. Remplacer le dossier `MotsSimples/` créé par celui du dépôt.
3. Ajouter les deux paquets locaux `Packages/DictionaryCore` et `Packages/DictionaryUI`, et lier `DictionaryUI` à l'app.
4. Régler `INFOPLIST_FILE` sur `Config/Info.plist` et le fichier de configuration sur `Config/MotsSimples.xcconfig`.
5. Ajouter une cible de tests d'interface avec `MotsSimplesUITests/`.

## Police

Lexend est embarquée dans `DictionaryUI`. Licence SIL Open Font License 1.1 : voir `Packages/DictionaryUI/Sources/DictionaryUI/Ressources/Polices/LICENCE-Lexend.txt`.
