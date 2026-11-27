# Rapport du lot 4 : app complète

27 novembre 2026. Branche `lot-4`, partie de `lot-3`.

## À lire d'abord

**Le code Swift de ce lot, comme celui du lot 2, n'a jamais été compilé.** Pas de Xcode, pas de compilateur Swift, pas de simulateur.
Tout ce qui touche à l'app est donc **écrit, pas vérifié**. Le site et le point de collecte, eux, sont construits et testés.

**Les API d'Apple n'ont pas pu être vérifiées dans la documentation.** Le brief le demandait.
Le site de documentation d'Apple est bloqué par la politique réseau du conteneur. J'ai écrit de mémoire.
La liste des API à vérifier est plus bas : c'est la première chose à faire à la compilation.

Aucun build n'est envoyé, aucun identifiant n'est créé, rien n'est déployé.

## Critères de fin

| Critère | État |
| --- | --- |
| Chaque critère d'acceptation de la section « App iOS » est tenu, ou son écart est expliqué | Code écrit pour chacun. Écarts dans le tableau suivant. Rien n'est vérifié sur appareil |
| L'app fonctionne en mode avion, sauf la demande de mot et la mise à jour | Par construction : seuls ces deux appels touchent le réseau. Non vérifié |
| Les tests et les audits automatiques passent | `npm run ci` passe : 115 tests, plus les contrôles du site. Les tests Swift ne sont pas lancés |
| Le point de collecte a ses tests et sa marche de déploiement | **Tenu.** 11 tests passent. Marche dans `docs/deploiement.md` |
| `docs/testflight.md` et le rapport sont écrits | **Tenu** |

## État de chaque fonction

| Fonction | État | Où |
| --- | --- | --- |
| Écran Thèmes | Écrit, non compilé | `Vues/ThemesView.swift` |
| Chercher en parlant | Écrit, non compilé | `Saisie/DicteeVocale.swift` |
| Photographier un mot | Écrit, non compilé | `Saisie/CameraDeTexte.swift`, `DictionaryCore/MotsReconnus.swift` |
| Point de collecte | **Fait et testé** | `server/` |
| Page `/demander` du site | **Faite et testée** | `site/src/pages/demander.astro` |
| « Demander ce mot » dans l'app | Écrit, non compilé | `Services/ServiceDeDemandes.swift`, `DictionaryCore/Demandes.swift` |
| Mise à jour du contenu | Écrit, non compilé. Le côté site est testé | `DictionaryCore/MiseAJour.swift`, `Services/Contenu.swift` |
| Spotlight | Écrit, non compilé | `Services/IndexSpotlight.swift` |
| App Intents, « Expliquer un mot » | Écrit, non compilé | `ios/MotsSimples/Integrations/ExpliquerUnMot.swift` |
| Liens universels et partage | Écrit, non compilé. Il manque l'identifiant d'équipe côté site | `RacineView.swift`, `Config/MotsSimples.entitlements` |
| Accès d'aide | Écrit, non compilé | `MotsSimplesApp.swift`, `Info.plist` |
| Aide et à propos | Écrit, non compilé | `Vues/AideView.swift` |
| Manifeste de confidentialité | Écrit | `ios/MotsSimples/PrivacyInfo.xcprivacy` |
| Contrôle des contrastes | **Fait et testé** | `tools/contraste.ts` |

## Critères d'acceptation des specs, un par un

| Critère | État ou écart |
| --- | --- |
| Résultats dès la deuxième lettre | Tenu dans la recherche, testée dans sa version de référence |
| Ignore majuscules et accents, accepte pluriel et féminin, tolère une faute | Tenu. Pluriel et féminin passent par les formes déclarées et par la tolérance à une faute |
| Trouve les sigles et les fautes déclarées | Tenu |
| Du lancement à la fiche : trois touchers au plus | Deux touchers |
| Bouton micro visible dans le champ | **Écart.** Le bouton « Dire le mot » est sous le champ, avec une image et un mot, comme le demande le brief du lot 4. Une icône seule dans le champ irait contre le principe 4 |
| Lance la dictée du système | **Écart.** L'app utilise la reconnaissance vocale d'Apple, pas le bouton du clavier. La dictée du clavier reste disponible dans le champ |
| Autorisation au premier usage, avec une phrase simple | Écrit |
| En cas de refus, le bouton reste et explique | Écrit |
| La caméra reconnaît le texte sur l'appareil et met les mots en évidence | **Écart partiel.** VisionKit met en évidence des blocs de texte, souvent une ligne, pas chaque mot. Toucher un bloc propose ses mots, ceux du dictionnaire en premier. Un bloc d'un seul mot ouvre tout de suite |
| Toucher un mot ouvre sa fiche, ou « Mot absent » | Écrit |
| Aucune image enregistrée ni envoyée | Tenu par construction : le code ne garde aucune image |
| « Tout écouter » lit toute la fiche dans l'ordre | Écrit au lot 2 |
| Phrase en cours mise en évidence | Écrit au lot 2 |
| Lecture en mode silencieux | Écrit. À vérifier sur un vrai téléphone |
| Deux vitesses, choix mémorisé | Écrit. Le réglage est maintenant dans « Aide et à propos » seulement |
| Bouton d'écoute par bloc et par mot dans les listes | Écrit, y compris dans la liste d'un thème |
| Arrêt simple, reprise au début, quitter la fiche arrête | Écrit |
| Prononciation lue à la place du mot | Écrit |
| Un seul bouton « Demander ce mot », seul le mot part | Écrit. Un texte avec un chiffre ou une arobase ne peut pas partir |
| Sans réseau, la demande part plus tard et l'app le dit | Écrit. 20 mots en attente au plus |
| Le partage envoie le lien de la page web | Écrit |
| Tout fonctionne en mode avion, sauf demande et mise à jour | Par construction |
| Contenu embarqué | Tenu : 20 fiches de préversion dans l'app |
| « Retrouver ses derniers mots » | Écrit au lot 2 |

## Résultats des audits

**Site** : `npm run check:site` passe. axe ne trouve aucun défaut sur 8 pages, en clair et en sombre.
La page `/demander` et ses pages de retour sont dans l'audit. Poids de l'accueil : 58,2 Ko hors image.

**App** : 17 tests d'interface écrits. Ils lancent l'audit d'accessibilité d'Apple sur l'accueil, une fiche, les thèmes,
la liste d'un thème, le mot absent, l'aide, en paysage, et à la plus grande taille de texte en clair et en sombre,
avec des captures jointes. **Aucun n'a été lancé.**

**Contrastes**, calculés ici à partir des jetons de style de l'app. Formule WCAG.

| Paire | Clair | Sombre | Minimum |
| --- | --- | --- | --- |
| Texte sur le fond | 14,81 | 16,41 | 4,5 pour 1 |
| Texte sur une carte | 16,30 | 13,80 | 4,5 pour 1 |
| Texte secondaire sur le fond | 6,95 | 10,57 | 4,5 pour 1 |
| Texte secondaire sur une carte | 7,65 | 8,89 | 4,5 pour 1 |
| Texte de bouton, vert sur une carte | 6,47 | 8,61 | 4,5 pour 1 |
| Texte de bouton, vert sur le fond | 5,87 | 10,23 | 4,5 pour 1 |
| Texte sur un bouton plein | 6,47 | 9,88 | 4,5 pour 1 |
| Phrase en cours de lecture | 13,56 | 7,94 | 4,5 pour 1 |
| Bandeau « Brouillon non relu » | 8,90 | 9,35 | 4,5 pour 1 |
| Image neutre, symbole sur son fond | 6,29 | 7,29 | 3 pour 1 |
| Bordure forte du champ de recherche, sur le fond | 5,32 | 9,54 | 3 pour 1 |
| Bordure forte, sur une carte | 5,86 | 8,02 | 3 pour 1 |
| Trait de la phrase en cours, sur le surlignage | 5,38 | 4,95 | 3 pour 1 |
| Image du thème argent, sur une carte | 6,47 | 8,61 | 3 pour 1 |
| Image du thème sante, sur une carte | 6,75 | 7,64 | 3 pour 1 |
| Image du thème logement, sur une carte | 6,79 | 8,56 | 3 pour 1 |
| Image du thème travail, sur une carte | 6,95 | 8,54 | 3 pour 1 |
| Image du thème papiers, sur une carte | 7,20 | 8,21 | 3 pour 1 |
| Image du thème justice, sur une carte | 6,78 | 9,79 | 3 pour 1 |
| Image du thème transports, sur une carte | 6,33 | 8,96 | 3 pour 1 |
| Image du thème vie-quotidienne, sur une carte | 7,00 | 8,02 | 3 pour 1 |
| Bordure légère d'une carte, sur le fond | 1,29 | 1,85 | aucun, décor |
| Bordure légère d'une carte, sur la carte | 1,42 | 1,55 | aucun, décor |
| Carte sur le fond, sans bordure | 1,10 | 1,19 | aucun, décor |

Tous les textes passent 4,5 pour 1, dans les deux modes. Les images et les bordures fortes passent 3 pour 1.
Un test bloque maintenant si un texte passe sous le seuil. Un autre vérifie que le site garde les mêmes couleurs que l'app.

**La bordure légère des cartes ne passe pas 3 pour 1** : 1,29 sur le fond en clair, 1,85 en sombre.
Sans bordure, une carte blanche ne se détache du fond qu'à 1,10.
Ce n'est pas un défaut au sens strict : le texte reste lisible, et la carte ne porte pas d'information à elle seule.
Mais une personne malvoyante peut ne pas voir où une carte finit.

- Ce que j'ai fait, comme le brief le permet : en mode « Augmenter le contraste », les cartes prennent la bordure forte,
  plus épaisse, à 5,32 pour 1. Les boutons flottants deviennent opaques.
- Ce que je propose, sans l'avoir fait : foncer la bordure légère vers `#7C9A88` en clair, environ 3 pour 1 sur le fond.
  Le style reste doux. C'est à décider avec les maquettes.

**Verre** : le contraste des éléments en verre dépend de ce qui défile dessous. Il ne se calcule pas, il se regarde.
Les deux boutons flottants ont un texte blanc sur vert, à 6,47 pour 1 quand le rendu est opaque.

## Chiffres de performance

**Aucune mesure.** Sans simulateur, je n'ai aucun chiffre réel pour l'app, et je n'en invente pas.

Ce qui est prêt pour mesurer : `PerformanceTests` mesure le lancement et la recherche dans Xcode.
Un test de `DictionaryCore` vérifie qu'une recherche dans 2 000 fiches prend moins de 50 millisecondes.

Ce qui est mesuré ici, à titre indicatif seulement : le paquet de 20 fiches pèse 17 Ko.
Les trois fichiers de police pèsent 240 Ko. L'app devrait rester très loin des 30 Mo.

## API d'Apple utilisées, à vérifier dans la documentation

Écrites de mémoire. Aucune n'a été vérifiée.

| API | Usage | Risque |
| --- | --- | --- |
| `AssistiveAccess { }`, scène SwiftUI | Scène d'Accès d'aide | **Élevé.** API d'iOS 26, forme exacte à confirmer |
| `UISupportsAssistiveAccess` dans `Info.plist` | Déclare la prise en charge | Moyen |
| `.buttonStyle(.glassProminent)` | Boutons flottants en verre | **Élevé.** API d'iOS 26 |
| `DataScannerViewController`, VisionKit | Lecture du texte par la caméra | Moyen. Les paramètres du constructeur sont à confirmer |
| `SFSpeechRecognizer`, `SFSpeechAudioBufferRecognitionRequest` | Reconnaissance vocale | Moyen. iOS 26 a peut-être une API plus récente, à préférer si elle existe |
| `AVAudioApplication.requestRecordPermission()` | Autorisation du micro | Faible |
| `AVSpeechSynthesizer` et son délégué | Lecture des fiches | Faible. Le passage au fil principal en Swift 6 est à vérifier |
| `AppIntent`, `AppShortcutsProvider`, `openAppWhenRun` | « Expliquer un mot » | Moyen. `openAppWhenRun` a peut-être un remplaçant en iOS 26 |
| `CSSearchableIndex`, `CSSearchableItemAttributeSet` | Spotlight | Faible |
| `onContinueUserActivity`, `onOpenURL` | Spotlight et liens universels | Faible |
| `ShareLink` | Partage | Faible |
| `@Entry` sur `EnvironmentValues` | Réglages dans l'environnement | Faible |
| `@Observable` sur une classe `NSObject` | Lecteur vocal | Moyen |
| `XCUIApplication.performAccessibilityAudit()` | Audits automatiques | Faible |
| `PBXFileSystemSynchronizedRootGroup` | Projet Xcode écrit à la main | **Élevé.** Voir `ios/README.md` |

## Choix pris

- **Ordre des tâches** : j'ai commencé par le point de collecte et la page du site, qui se testent ici. Les commits suivent cet ordre.
- **« Retour » ramène toujours à l'accueil** : choisir un thème remplace la grille par la liste. Depuis la liste, « Retour » va donc à l'accueil.
  Pour changer de thème, on retouche « Voir les thèmes ». C'est la lecture la plus littérale du brief. À confirmer en séance.
- **Thèmes** : chaque thème a une couleur et un symbole SF. Le nom est toujours écrit à côté.
- **« Dire le mot »** : l'écoute s'arrête seule après 2 secondes de silence, ou 8 secondes au plus. La personne dit un mot, pas une phrase.
- **Photo** : voir l'écart plus haut. Les expressions passent avant les mots : dans « justificatif de domicile », on propose l'expression.
- **Demande de mot** : le mot est nettoyé avant l'envoi, avec la même règle dans l'app et sur le serveur.
  Si le serveur refuse un mot, l'app remercie quand même. Pas de message d'erreur culpabilisant.
- **Point de collecte** : Node sans dépendance. Stockage dans un fichier JSON sur un volume Railway.
  Coût : un petit service allumé et un volume minimal. Je n'ai pas pu lire les prix. Détail dans `docs/deploiement.md`.
- **Limite de débit** : 10 demandes par minute et par origine, 300 au total. L'origine n'est jamais gardée :
  seulement une empreinte en mémoire, avec un sel qui change chaque minute.
- **Lecture des compteurs** : un jeton dans l'en-tête `Authorization`. Sans jeton réglé, la lecture est fermée.
- **Mise à jour du contenu** : à l'ouverture et au retour dans l'app, au plus une fois par jour.
  Le paquet est demandé avec sa version dans l'adresse, pour le cache du site.
  Après une mise à jour de l'app, le paquet téléchargé est effacé : le paquet embarqué est alors le plus récent.
- **Build public** : il refuse un paquet de préversion à trois endroits. Dans le manifeste, dans le paquet, et pour un paquet déjà sur le téléphone.
- **Siri** : Siri dit la définition, puis l'app s'ouvre sur la fiche. Siri demande le mot : une phrase ne peut pas contenir un mot libre.
- **Accès d'aide** : la même interface, réduite. Pas de thèmes, de micro, de photo, de demande, de partage, ni d'aide.
- **Vitesse de la voix** : seulement dans « Aide et à propos », comme le disent les specs. Elle a quitté la fiche. Un bouton fait entendre un essai.
- **Réseau** : une session sans cookie, sans cache sur disque, sans identifiant.

## Textes d'interface nouveaux

Tous dans `Textes.swift`. Les textes des autorisations sont dans `docs/testflight.md`.

| Écran | Texte |
| --- | --- |
| Chercher en parlant | Dire le mot |
| Chercher en parlant | Je vous écoute. Dites le mot. |
| Chercher en parlant | Le micro est coupé pour cette app. Pour dire un mot, ouvrez les réglages et activez le micro et la reconnaissance vocale. |
| Chercher en parlant | Votre téléphone ne peut pas écouter pour le moment. Vous pouvez écrire le mot. |
| Chercher en parlant | Ouvrir les réglages |
| Photographier un mot | Prendre en photo |
| Photographier un mot | Montrez le texte, puis touchez un mot. |
| Photographier un mot | Quel mot voulez-vous ? |
| Photographier un mot | Choisir un autre texte |
| Photographier un mot | Fermer |
| Photographier un mot | La caméra est coupée pour cette app. Pour prendre un mot en photo, ouvrez les réglages et activez la caméra. |
| Thèmes | Voir les thèmes |
| Thèmes | Les thèmes |
| Thèmes | Choisissez un thème. |
| Thèmes | Il n'y a pas encore de mot dans ce thème. |
| Thèmes | 1 mot |
| Thèmes | … mots |
| Partager | Partager |
| Aide et à propos | Aide et à propos |
| Aide et à propos | Comment ça marche ? |
| Aide et à propos | Écrivez un mot que vous ne comprenez pas. |
| Aide et à propos | Vous pouvez aussi dire le mot, ou le prendre en photo. |
| Aide et à propos | Touchez le mot pour lire son explication. |
| Aide et à propos | Touchez « Tout écouter » pour entendre l'explication. |
| Aide et à propos | Écouter un essai de la voix |
| Aide et à propos | Voici la voix à cette vitesse. |
| Aide et à propos | Attention |
| Aide et à propos | Le dictionnaire explique des mots. |
| Aide et à propos | Il ne remplace pas un médecin. Il ne remplace pas un conseiller. |
| Aide et à propos | Votre vie privée |
| Aide et à propos | L'app ne garde aucune information sur vous. |
| Aide et à propos | Vos derniers mots restent sur votre téléphone. |
| Aide et à propos | La caméra et le micro servent seulement à trouver un mot. Rien n'est enregistré. |
| Aide et à propos | Si vous demandez un mot, seul le mot est envoyé. |
| Aide et à propos | D'où viennent les explications ? |
| Aide et à propos | Un ordinateur écrit un premier texte. C'est un brouillon. |
| Aide et à propos | Une personne vérifie le texte avec une source officielle. |
| Aide et à propos | Des personnes concernées lisent le texte. Si elles le comprennent, il est validé. |
| Aide et à propos | Qui a fait l'app ? |
| Aide et à propos | Adrien Humilière fait ce dictionnaire. |
| Aide et à propos | L'app est gratuite. Il n'y a pas de publicité et pas de compte. |
| Aide et à propos | Merci |
| Aide et à propos | Pictogrammes : Sergio Palao, ARASAAC, Gouvernement d'Aragon. Licence Creative Commons BY-NC-SA. |
| Aide et à propos | Police Lexend. Licence SIL Open Font License. |
| Aide et à propos | Textes sous licence Creative Commons BY-NC-SA 4.0. Code sous licence MIT. |
| Aide et à propos | Version de l'app : …. Contenu du …. |
| Demander un mot | Demander ce mot |
| Demander un mot | Seul le mot « … » est envoyé. Nous ne savons pas qui vous êtes. |
| Demander un mot | N'envoyez pas votre nom. N'envoyez rien de personnel. |
| Demander un mot | Merci. Le mot est envoyé. |
| Demander un mot | Il n'y a pas d'internet. Le mot partira plus tard, tout seul. |
| Demander un mot | Le mot part… |
| Siri | Expliquer un mot |
| Siri | Quel mot voulez-vous comprendre ? |
| Siri | Expliquer un mot avec Mots simples · Explique un mot avec Mots simples · Chercher un mot dans Mots simples |

Textes nouveaux du site, dans `site/src/lib/textes.ts` :

| Page | Texte |
| --- | --- |
| Demander | Demander un mot · Demander ce mot |
| Demander | Un mot manque dans le dictionnaire ? Écrivez-le ici. |
| Demander | Le mot que vous voulez |
| Demander | Écrivez seulement le mot. N'écrivez pas votre nom. N'écrivez rien de personnel. |
| Demander | Envoyer le mot |
| Demander | Seul le mot est envoyé. Nous ne savons pas qui vous êtes. |
| Demander, fermé | On ne peut pas encore demander un mot ici. Cela arrive bientôt. |
| Merci | Merci, le mot est envoyé |
| Merci | Nous regardons les mots les plus demandés pour écrire les prochaines fiches. |
| Merci | Vous ne recevrez pas de réponse, car nous ne savons pas qui vous êtes. |
| Erreur | Le mot n'est pas parti |
| Erreur | Écrivez un seul mot ou une expression courte, avec des lettres seulement. Pas de chiffre. |
| Trop de demandes | Réessayez un peu plus tard |
| Trop de demandes | Il y a trop de demandes en ce moment. Le mot n'est pas parti. |
| Retour | Demander un autre mot · Réessayer |

## Ce qui demande un vrai appareil

La liste complète, à cocher, est dans `docs/testflight.md`, section 6. En bref :
la voix en mode silencieux, la dictée, la caméra, Siri, Spotlight, les liens universels, l'Accès d'aide, VoiceOver, et toutes les mesures.

## Ce qui n'est pas fait

- **Compiler, lancer, mesurer** : voir plus haut.
- **Captures d'écran de l'app** : le test qui les produit est écrit, il faut le lancer.
- **Icône de l'app** : absente, et obligatoire pour TestFlight.
- **Pictogrammes** : toujours l'image neutre. Le choix dans ARASAAC est hors des lots 1 à 4.
- **Xcode Cloud** : pas configuré. Cela demande le compte développeur.
- **Extension d'action et widget** : prévus en V1.1 par les specs.

## Doutes

- Le point le plus fragile est le projet Xcode écrit à la main. S'il ne s'ouvre pas, le recréer prend cinq étapes.
- Les deux fichiers Swift les plus exposés aux erreurs de concurrence Swift 6 sont `LecteurVocal.swift` et `DicteeVocale.swift`.
- La scène d'Accès d'aide et le style en verre sont des API d'iOS 26 que je connais mal.
- Le crédit ARASAAC s'affiche alors qu'aucun pictogramme n'est encore là.
- « Adrien Humilière fait ce dictionnaire. » figure dans l'app et sur le site. À confirmer.

## Ce qu'Adrien doit faire, dans l'ordre

1. Suivre `docs/testflight.md`, section 1 : faire compiler, lancer les tests.
2. Vérifier les API du tableau ci-dessus, en commençant par les risques élevés.
3. Relire les textes nouveaux.
4. Décider pour la bordure légère des cartes.
5. Fournir une icône.
6. Déployer le site et le point de collecte quand il le décide, avec `docs/deploiement.md`.
7. Régler équipe et signature, puis envoyer le build quand il le décide.

Je m'arrête ici. Le lot 5 n'est pas commencé.
