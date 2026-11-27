# Préparer TestFlight

Rien n'est envoyé. Ce document dit à Adrien quoi régler et quoi tester avant d'envoyer un build.

**À savoir d'abord** : le code Swift compile et ses tests passent dans GitHub Actions, voir `docs/rapports/lot-4.md`.
Il n'a pas encore été essayé à la main. La première étape est donc de le lancer, pas de l'envoyer.

## 1. Faire compiler

1. Ouvrir `ios/MotsSimples.xcodeproj` dans Xcode 26. S'il ne s'ouvre pas : `ios/README.md`, « Si le projet Xcode ne s'ouvre pas ».
2. `cd ios/Packages/DictionaryCore && swift test`. 40 tests, sans simulateur.
3. Compiler l'app pour un simulateur iOS 26. Corriger ce qui bloque. Les endroits les plus risqués sont listés dans le rapport.
4. Lancer les tests d'interface : 16 tests. L'audit d'accessibilité automatique est désactivé, voir `ios/MotsSimplesUITests/Audit.swift`.

## 2. Ce qu'il faut régler dans Xcode

| Réglage | Où | Valeur |
| --- | --- | --- |
| Équipe | Cible MotsSimples, Signing & Capabilities | L'équipe du compte développeur. Rien n'est configuré |
| Signature | Même écran | Automatique |
| Identifiant | Déjà réglé | `fr.adhumi.motssimples`. À créer dans le compte développeur : je ne l'ai pas fait |
| Domaines associés | Déjà dans `Config/MotsSimples.entitlements` | `applinks:motssimples.fr`. Xcode ajoute la capacité à l'identifiant |
| Numéro de version | `MARKETING_VERSION` | `0.1.0` aujourd'hui |
| Numéro de build | `CURRENT_PROJECT_VERSION` | `1` aujourd'hui. À augmenter à chaque envoi |
| Icône | `MotsSimples/Assets.xcassets/AppIcon` | **Absente.** Une image de 1024 pixels est obligatoire pour envoyer un build |
| Chiffrement | Déjà dans `Info.plist` | `ITSAppUsesNonExemptEncryption` à non : l'app n'utilise que le HTTPS du système |

## 3. Choisir le contenu du build

| Build | `MOTS_SIMPLES_PREVERSION` | Contenu embarqué |
| --- | --- | --- |
| TestFlight, pour la première discussion | `YES` | `npm run embed:content` : les 20 brouillons, avec leur bandeau |
| App Store, plus tard | `NO` | `npm run embed:content -- --public` : fiches relues et validées seulement |

Un brouillon n'est jamais public. TestFlight est une préversion : c'est permis, avec le bandeau « Brouillon non relu ».
Garder les testeurs à un petit groupe choisi, pas un lien public.

L'app télécharge son contenu sur `MOTS_SIMPLES_SITE`. Un build de préversion accepte le paquet de préversion du site.
Un build public le refuse, même s'il est déjà sur le téléphone.

## 4. Avant d'envoyer

- Le site doit être en ligne pour tester la mise à jour du contenu. Sinon l'app marche, sans cette fonction.
- Le point de collecte doit être en ligne pour tester « Demander ce mot ». Sinon, vider `MOTS_SIMPLES_DEMANDES` : le bouton disparaît.
- Remplacer `EQUIPE_A_REMPLACER` dans `site/public/.well-known/apple-app-site-association`, puis redéployer le site. Sans cela, pas de liens universels.
- Dans App Store Connect, questionnaire de confidentialité : « Aucune donnée collectée ».
  Le mot demandé part seul, sans identifiant, et n'est relié à personne.
- Déclarer les étiquettes d'accessibilité de la fiche de l'app seulement après les avoir vérifiées sur un vrai téléphone.

## 5. Textes des autorisations à relire

Ils sont dans `ios/Config/Info.plist`. Le système les affiche au premier usage de la fonction, jamais au lancement.

| Autorisation | Texte |
| --- | --- |
| Caméra | La caméra sert à lire un mot sur un papier. Aucune photo n'est gardée. |
| Micro | Le micro sert à écouter le mot que vous dites, pour le chercher. |
| Reconnaissance vocale | L'app change votre voix en texte pour chercher le mot. Rien n'est gardé. |

Et dans l'app, quand l'autorisation a été refusée :

| Cas | Texte |
| --- | --- |
| Micro refusé | Le micro est coupé pour cette app. Pour dire un mot, ouvrez les réglages et activez le micro et la reconnaissance vocale. |
| Caméra refusée | La caméra est coupée pour cette app. Pour prendre un mot en photo, ouvrez les réglages et activez la caméra. |
| Dictée impossible | Votre téléphone ne peut pas écouter pour le moment. Vous pouvez écrire le mot. |

## 6. À tester à la main, sur un vrai téléphone

Le simulateur ne suffit pas pour ces points.

**Hors ligne**

- [ ] Mode avion, première ouverture après installation : la recherche et les fiches marchent.
- [ ] Mode avion : « Demander ce mot » dit que le mot partira plus tard. Réseau revenu, rouvrir l'app : le mot part.

**Écoute**

- [ ] Interrupteur sur silencieux : « Tout écouter » s'entend.
- [ ] La phrase lue est mise en évidence, et la suivante prend le relais.
- [ ] « Arrêter » coupe tout de suite. Un nouveau toucher repart du début.
- [ ] Quitter la fiche coupe la voix.
- [ ] Les quatre sigles sont bien dits : RIB, AAH, ESAT, MDPH. Le mot « bail » aussi.
- [ ] Vitesse lente dans « Aide et à propos » : elle est gardée après avoir fermé l'app.

**Chercher en parlant**

- [ ] Premier toucher sur « Dire le mot » : deux demandes d'autorisation, avec les textes ci-dessus.
- [ ] Dire « facture » : le mot arrive dans le champ, les résultats s'affichent.
- [ ] Refuser l'autorisation : le bouton reste, le message explique, « Ouvrir les réglages » marche. Le reste de l'app marche.
- [ ] En mode avion : la dictée marche encore si le téléphone a la reconnaissance sur l'appareil.

**Photographier un mot**

- [ ] Premier toucher sur « Prendre en photo » : la demande d'autorisation.
- [ ] Viser un vrai courrier : les textes sont mis en évidence. Toucher une ligne propose ses mots.
- [ ] Toucher un mot connu ouvre sa fiche. Un mot inconnu mène à « Mot absent ».
- [ ] Vérifier dans Photos qu'aucune image n'a été enregistrée.

**Système**

- [ ] Chercher « facture » dans Spotlight : le mot apparaît et ouvre sa fiche.
- [ ] « Dis Siri, expliquer un mot avec Mots simples » : Siri demande le mot, dit la définition, l'app s'ouvre.
- [ ] Le raccourci « Expliquer un mot » est dans l'app Raccourcis, et peut aller sur le bouton Action.
- [ ] Toucher un lien `https://motssimples.fr/mot/facture` dans Messages : l'app s'ouvre sur la fiche.
- [ ] Accès d'aide : ajouter Mots simples aux apps, entrer en Accès d'aide. L'app montre seulement Chercher et Fiche.

**Accessibilité**

- [ ] VoiceOver : parcourir l'accueil et une fiche. Chaque bouton a un nom, les titres sont annoncés, l'ordre suit l'écran.
- [ ] Plus grande taille de texte : rien n'est coupé, pas de défilement horizontal.
- [ ] Texte en gras, contraste accru, transparence réduite, formes de boutons, mode sombre : tout reste lisible.
- [ ] Avec « Réduire la transparence » : les boutons flottants sont opaques.
- [ ] Contrôle vocal : « Toucher Tout écouter » marche.
- [ ] iPad, en portrait et en paysage, et en écran partagé.

**Performance**, sur le plus ancien iPhone pris en charge

- [ ] Du lancement au champ utilisable : moins de 1 seconde.
- [ ] Début de la lecture audio : moins d'une demi-seconde.
- [ ] Taille de l'app : moins de 30 Mo.
