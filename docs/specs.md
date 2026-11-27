# Mots simples : spécifications de l'app iOS et du site web

Nov 26, 2026 · @Adrien Humilière

## Résumé

Un dictionnaire gratuit qui explique les mots compliqués avec des phrases simples, une image et une voix. Il existe sous deux formes alimentées par le même contenu : une app iOS native qui fonctionne hors ligne, et un site web où chaque mot a sa page.

**Décisions déjà prises**

| Sujet | Décision |
| --- | --- |
| Public prioritaire | Personnes avec handicap intellectuel |
| Périmètre de la V1 | Dictionnaire seul, architecture prête pour le lecteur plus tard |
| Plateforme | iOS natif d'abord, le site web sert les autres téléphones |
| Site web | Dictionnaire en ligne, une page par mot, plus la présentation de l'app |
| Contenu | Brouillons par IA, relecture par Adrien, validation avec Sophia, statut affiché par mot |
| Modèle | Gratuit, sans publicité, sans compte, open source avec dépôt public dès le début |

**Dans la V1**

- Chercher un mot en le tapant, en le disant ou en le photographiant.
- Lire et écouter sa fiche : définition simple, image, exemple.
- Retrouver ses derniers mots consultés.
- Demander un mot qui manque.
- Consulter le même dictionnaire sur le web.

**Hors périmètre de la V1**

- La simplification de textes entiers (c'est le lecteur, projet suivant).
- Toute IA à l'exécution : l'app n'appelle aucun modèle, le contenu est rédigé et relu en amont.
- Comptes, synchronisation entre appareils, contribution ouverte au public. La fonction de mots gardés est reportée à une version suivante.
- Android natif.

## Utilisateurs et principes de conception

L'app est conçue pour une personne avec handicap intellectuel qui l'utilise seule. Si elle convient à cette personne, elle conviendra aux autres.

| Utilisateur | Situation type | Ce qu'il attend |
| --- | --- | --- |
| Personne concernée (cible de conception) | Lit un courrier, un panneau, un formulaire et bute sur un mot | Comprendre le mot tout de suite, sans demander à quelqu'un |
| Proche ou accompagnant | Explique un mot à quelqu'un | Une explication fiable à montrer ou à faire écouter |
| Autres lecteurs en difficulté | Apprend le français, lit peu | La même chose, souvent via le site web |

**Principes d'interface.** Ils priment sur toute autre considération de design.

1. **Un écran, une chose à faire.** Pas de menu caché, pas de geste à deviner, pas de réglage obligatoire.
2. **L'interface est elle-même en FALC.** Phrases courtes, mots courants, vouvoiement partout, jamais de jargon (« historique » devient « Vos derniers mots »).
3. **Tout texte peut être écouté.** Un bouton d'écoute visible sur chaque fiche, sans passer par les réglages du téléphone.
4. **Tout bouton a une image et un mot.** Jamais d'icône seule.
5. **Rien n'est irréversible.** Pas de suppression sans retour possible, pas de message d'erreur culpabilisant.
6. **Aucune barrière à l'entrée.** Pas de compte, pas d'écran d'accueil en plusieurs pages, pas de demande d'autorisation au lancement. L'app s'ouvre sur la recherche.
7. **Prévisible.** Même mise en page pour toutes les fiches, mêmes emplacements pour les mêmes boutons.
8. **Calme.** Pas d'animation décorative, pas de notification, pas de compteur ni de récompense.

Chaque principe est vérifié en séance avec Sophia avant d'être considéré comme tenu.

## Contenu

Le contenu est le produit. L'app et le site ne font que l'afficher.

### Modèle d'une fiche

| Champ | Obligatoire | Règle |
| --- | --- | --- |
| Mot | Oui | Forme courante, au singulier. Les expressions sont acceptées (« mise en demeure ») |
| Définition | Oui | 1 à 3 phrases, 15 mots au plus par phrase, une idée par phrase, voix active, présent |
| Exemple | Oui | Une phrase qui met le mot dans une situation de la vie courante |
| Image | Oui | Un pictogramme qui aide à comprendre, jamais décoratif, avec son texte alternatif |
| Thème | Oui | Un seul parmi une liste courte : Argent, Santé, Logement, Travail, Papiers, Justice, Transports, Vie quotidienne |
| Autres sens | Non | Un sens par bloc, le plus courant en premier, trois au plus |
| À ne pas confondre | Non | Un mot proche et la différence en une phrase |
| Mots liés | Non | Liens vers d'autres fiches, quatre au plus |
| Formes de recherche | Oui | Pluriels, féminins, sigles, fautes fréquentes. Jamais affichées |
| Source de référence | Oui pour l'administratif et la santé | Page officielle qui a servi à vérifier l'exactitude. Interne, non affichée dans l'app |
| Statut et date | Oui | Voir ci-dessous |
| Prononciation | Non | Comment la voix doit dire le mot quand elle le lit mal, surtout pour les sigles (« a-a-hache » pour AAH). Jamais affichée |

Une définition n'emploie aucun mot plus difficile que le mot défini. Si un mot difficile est inévitable, il a sa propre fiche et il est lié.

### Statuts

| Statut | Signification | Visible par le public |
| --- | --- | --- |
| Brouillon | Généré par IA, non relu | Jamais en public. Visible seulement en préversion (site en noindex, TestFlight), avec un bandeau « Brouillon non relu » |
| Relu | Vérifié par Adrien : exactitude et règles d'écriture | Oui, avec la mention « Pas encore validé » |
| Validé | Compris en séance par une ou plusieurs personnes concernées | Oui, avec la mention « Validé » et la date |

Le mot « FALC » et le logo européen ne s'appliquent qu'aux fiches validées.

### Chaîne éditoriale

1. **Choisir les mots.** À partir de vrais courriers et formulaires, des mots cités par Sophia, puis des demandes des utilisateurs.
2. **Générer le brouillon.** Dans Claude Code, par lots, à la main. Une consigne versionnée dans le dépôt produit la fiche complète à partir du mot et de sa source de référence.
3. **Contrôler automatiquement.** Un script refuse une fiche si une phrase dépasse 15 mots, si un champ obligatoire manque, ou si le mot défini revient dans la définition après le début de la première phrase.
4. **Relire.** Adrien vérifie l'exactitude contre la source et corrige. La fiche passe à « Relu ».
5. **Valider.** En séance, chaque fiche est lue ou écoutée. « Compris » la valide, « pas compris » la renvoie en réécriture avec la raison notée.
6. **Publier.** La fusion dans la branche principale met à jour le site et le paquet de contenu de l'app.

Volume visé au lancement : une centaine de mots, chiffre indicatif à ajuster au rythme des séances de validation.

### Pictogrammes

Décision : ARASAAC pour lancer, puis remplacement progressif par des illustrations originales. Ce que chaque option implique :

- **ARASAAC.** Des milliers de pictogrammes prêts, sous licence Creative Commons BY-NC-SA : usage non commercial, attribution obligatoire (auteur Sergio Palao, propriété du Gouvernement d'Aragon), et les contenus dérivés doivent reprendre la même licence ([conditions ARASAAC](https://aulaabierta.arasaac.org/en/terms-of-use)).
- **Illustrations originales.** Liberté totale de licence et de style, mais un coût de production par mot.

Dans les deux cas, l'image est testée en séance comme le texte : une image mal comprise est retirée.

## App iOS

L'app n'a pas de barre d'onglets en V1 : un écran d'accueil (Chercher), un bouton « Voir les thèmes » et une fiche. Ce choix reste à confirmer en séance. Elle s'ouvre directement sur la recherche.

**Direction visuelle retenue.** Style doux et coloré : formes très arrondies, vert calme, police Lexend, cartes blanches sur fond teinté, avec des bordures légères pour mieux détacher chaque élément. Le Liquid Glass est réservé aux éléments flottants (bouton « Voir les thèmes », « Retour », barre « Écouter ») ; le contenu à lire reste opaque. Un rendu opaque remplace le verre quand « Réduire la transparence » ou « Augmenter le contraste » est activé. Les bordures légères et les éléments en verre sont validés en l'état ; leur contraste est à vérifier par un audit d'accessibilité pendant le développement, sans attendre l'audit final. Maquettes : [Mots simples, trois directions de style](https://claude.ai/artifact/XVnuEFJBS35rZWTdrB4cWK).

### Écrans

| Écran | Contenu | Actions |
| --- | --- | --- |
| Chercher (accueil) | Grand champ de recherche, derniers mots consultés en dessous | Taper, dicter, photographier un mot |
| Résultats | Liste au fil de la frappe, chaque ligne avec le mot et son image | Ouvrir une fiche |
| Mot absent | « Ce mot n'est pas encore dans le dictionnaire. » Mots proches proposés | Demander ce mot |
| Fiche | Mot en grand, image, définition, exemple, autres sens, mots liés, statut | Écouter, partager |
| Photographier | Caméra avec les mots reconnus mis en évidence | Toucher un mot pour ouvrir sa fiche |
| Thèmes | Grille des huit thèmes, puis liste des mots du thème | Parcourir sans savoir écrire le mot |
| Aide et à propos | Comment ça marche, qui a fait l'app, vie privée, crédits, vitesse de la voix | Aucune action obligatoire |

### Fonctions et critères d'acceptation

**Chercher en tapant**

- Les résultats apparaissent dès la deuxième lettre.
- La recherche ignore majuscules et accents, accepte le pluriel et le féminin, et tolère une faute de frappe.
- Elle trouve aussi les sigles et les fautes fréquentes déclarées dans la fiche.
- Du lancement à la fiche : trois touchers au plus, hors saisie.

**Chercher en parlant**

- Un bouton micro visible dans le champ lance la dictée du système.
- L'autorisation est demandée au premier usage seulement, avec une phrase simple qui explique pourquoi.
- En cas de refus, le bouton reste et explique comment réactiver, sans bloquer le reste.

**Photographier un mot**

- La caméra reconnaît le texte sur l'appareil et met les mots en évidence.
- Toucher un mot ouvre sa fiche, ou l'écran « Mot absent ».
- Aucune image n'est enregistrée ni envoyée.

**Lire et écouter une fiche**

- Le bouton « Tout écouter » lit toute la fiche dans l'ordre, avec une voix française du système : le mot, la définition, l'exemple, les autres sens, puis « à ne pas confondre ».
- La phrase en cours de lecture est mise en évidence.
- La lecture fonctionne même téléphone en mode silencieux, puisque la personne l'a demandée.
- Deux vitesses : normale et lente. Le choix est mémorisé.

* Le mot et chaque bloc de la fiche ont aussi leur petit bouton d'écoute, qui lit ce seul élément.
* Pendant la lecture, le bouton principal devient « Arrêter ». Il n'y a ni pause ni reprise : après un arrêt, la lecture repart du début.
* Quitter la fiche arrête la lecture.
* Dans les listes (derniers mots, résultats, mots d'un thème), chaque mot a un bouton d'écoute qui le prononce sans ouvrir la fiche.
* Si la fiche a un champ « prononciation », la voix lit ce champ à la place du mot écrit. Il sert surtout aux sigles.

**Demander un mot**

- Un seul bouton « Demander ce mot ». Seul le mot est envoyé, sans identifiant.
- Sans réseau, la demande part plus tard, et l'app le dit simplement.

**Partager**

- Le partage envoie le lien de la page web du mot, lisible par quelqu'un qui n'a pas l'app.

**Fonctionner hors ligne**

- Tout fonctionne en mode avion, sauf la demande de mot et la mise à jour du contenu.
- Le contenu de lancement est embarqué dans l'app : elle est utile dès la première ouverture, sans téléchargement.

### Prévu pour plus tard

- « J'ai compris » et « Je n'ai pas compris » sur chaque fiche, pour repérer les définitions à réécrire.
- Voix humaine enregistrée à la place de la voix de synthèse.
- Le lecteur de textes, qui réutilisera le dictionnaire pour expliquer les mots difficiles.

* « Mes mots » : garder un mot pour le retrouver plus tard. Retiré de la V1, prévu pour une version suivante.

## Standards de la plateforme

L'objectif est une app qui se comporte comme une app Apple : composants natifs, aucune navigation maison, et toutes les aides du système prises en charge.

### Accessibilité

| Exigence | Critère de validation |
| --- | --- |
| Accès d'aide (Assistive Access) | L'app déclare `UISupportsAssistiveAccess` et fournit une scène dédiée, réduite à Chercher et Fiche. Elle apparaît dans les apps optimisées des réglages d'Accès d'aide ([documentation Apple](https://developer.apple.com/documentation/accessibility/assistive-access), [session WWDC25](https://developer.apple.com/videos/play/wwdc2025/238/)) |
| Taille du texte | Tout l'écran reste lisible et utilisable à la plus grande taille d'accessibilité, sans texte coupé ni défilement horizontal |
| VoiceOver | Chaque élément a un libellé, les titres sont déclarés, l'ordre de lecture suit l'ordre visuel, les images ont leur description |
| Contrôle vocal, contrôle de sélection, clavier | Toutes les actions sont atteignables, ce que garantissent les contrôles standards |
| Réglages d'affichage | Respect de : contraste accru, texte en gras, réduction des animations, réduction de la transparence, formes de boutons, mode sombre |
| Couleur | Aucune information portée par la couleur seule. Contraste de 4,5 pour 1 au minimum |
| Cibles tactiles | 44 points au minimum, 60 visés pour les actions principales |
| Étiquettes d'accessibilité de l'App Store | Les fonctions prises en charge sont déclarées sur la fiche de l'app |

### Intégrations système

| Intégration | Usage | Version |
| --- | --- | --- |
| App Intents | « Explique le mot … » depuis Siri, Raccourcis et le bouton Action | V1 |
| Spotlight | Chaque mot est indexé : on le trouve depuis la recherche du téléphone | V1 |
| Liens universels | Un lien vers la page web d'un mot ouvre la fiche dans l'app si elle est installée | V1 |
| Reconnaissance de texte (VisionKit) | Photographier un mot, traitement sur l'appareil | V1 |
| Dictée | Recherche vocale par le clavier et le bouton micro | V1 |
| Synthèse vocale (AVSpeechSynthesizer) | Lecture des fiches, voix françaises du système | V1 |
| Extension d'action | Sélectionner un mot dans une autre app, puis « Expliquer ce mot » | V1.1 |
| Widget | Accès direct à la recherche depuis l'écran d'accueil | V1.1 |

### Socle technique

- Swift 6 et SwiftUI, sans dépendance tierce. Identifiant de l'app : fr.adhumi.motssimples.
- iPhone et iPad, toutes orientations, multitâche iPad.
- Composants et matériaux standards du système, SF Symbols pour l'interface, pictogrammes réservés au contenu.
- Chaînes dans un catalogue de traduction, français seul en V1.
- Manifeste de confidentialité renseigné. Cible : « Aucune donnée collectée » sur l'App Store.
- Tests avec Swift Testing, audits d'accessibilité automatisés dans les tests d'interface, intégration continue Xcode Cloud.

### Version minimale d'iOS

iOS 27 est la version courante et tourne sur l'iPhone 11 et suivants ainsi que l'iPhone SE de 2e génération ([AppleVis](https://applevis.com/comment/215310)). La scène dédiée à l'Accès d'aide existe depuis iOS 26. Décision : iOS 26 au minimum. Une partie du public visé peut avoir un téléphone plus ancien : c'est le site web qui la sert.

## Architecture technique

Une seule source de contenu alimente le site et l'app. Il n'y a pas de serveur applicatif : le site est statique et l'app lit un paquet de contenu.

### Dépôt unique

| Dossier | Contenu |
| --- | --- |
| `content/` | Un fichier YAML par mot, la liste des mots de la V1, plus les pictogrammes |
| `prompts/` | Les consignes de génération des brouillons, versionnées |
| `tools/` | Schéma et contrôle des fiches, génération du paquet de contenu, en Node et TypeScript |
| `site/` | Site statique généré avec Astro |
| `ios/` | Projet Xcode et modules Swift |

### Du contenu à l'écran

1. Une fiche est modifiée dans `content/` et proposée en fusion.
2. L'intégration continue contrôle toutes les fiches. Une erreur bloque la fusion.
3. Après fusion, elle génère le site et un paquet de contenu : toutes les fiches publiables, les images, un numéro de version et une empreinte.
4. Le site et le paquet sont publiés au même endroit.
5. L'app vérifie au plus une fois par jour si un paquet plus récent existe, le télécharge, contrôle son empreinte et remplace l'ancien d'un seul coup.

### Dans l'app

| Brique | Choix | Raison |
| --- | --- | --- |
| Contenu | Paquet en lecture seule, chargé en mémoire au lancement | Quelques centaines ou milliers de fiches : pas besoin de base de données |
| Contenu de départ | Paquet embarqué dans l'app à chaque version | Utile hors ligne dès la première ouverture |
| Données personnelles | Stockage local léger : derniers mots consultés, vitesse de la voix | Rien ne quitte l'appareil |
| Recherche | Index en mémoire sur les formes normalisées. Ordre : début de mot exact, puis formes déclarées, puis une faute de distance 1 | Réponse instantanée, comportement testable |
| Modules | `DictionaryCore` (modèle, chargement, recherche), `DictionaryUI`, puis l'app | `DictionaryCore` sera réutilisé par le lecteur |
| Compatibilité du paquet | Numéro de schéma. L'app ignore les champs inconnus et garde son contenu si le schéma est trop récent | Une vieille version de l'app ne casse jamais |

### La seule pièce côté serveur

« Demander un mot » a besoin d'un point de collecte. Il reçoit le mot et rien d'autre, ne journalise pas les adresses IP, limite le débit, et tient un simple compteur par mot. Il est hébergé sur Railway, comme le site.

### Budgets de performance

Valeurs indicatives, à mesurer sur le plus ancien iPhone pris en charge.

| Mesure | Cible |
| --- | --- |
| Du lancement au champ de recherche utilisable | Moins de 1 seconde |
| Affichage des résultats après une lettre tapée | Moins de 50 millisecondes |
| Début de la lecture audio | Moins de 0,5 seconde |
| Taille de l'app | Moins de 30 Mo |

### Tests

- Recherche : un corpus de requêtes réelles avec fautes, issu des séances, rejoué à chaque modification.
- Contenu : le contrôle des fiches tourne aussi dans les tests de l'app sur le paquet embarqué.
- Interface : audit d'accessibilité automatisé et captures aux plus grandes tailles de texte, en clair et en sombre, sur iPhone et iPad.

## Site web

Le site est le dictionnaire complet, consultable sans rien installer. Il sert les téléphones Android, les ordinateurs, les personnes qui arrivent par un moteur de recherche, et les liens partagés depuis l'app.

### Pages

| Page | Adresse | Contenu |
| --- | --- | --- |
| Accueil | `/` | Champ de recherche, les huit thèmes, lien vers l'app |
| Mot | `/mot/<mot>` | La même fiche que dans l'app, dans le même ordre |
| Thème | `/theme/<theme>` | Les mots du thème, avec leur image |
| Tous les mots | `/mots` | Liste alphabétique complète |
| Demander un mot | `/demander` | Un champ, un bouton |
| C'est quoi ce dictionnaire ? | `/a-propos` | Pour qui, par qui, comment les définitions sont écrites et validées |
| Vie privée et mentions légales | `/vie-privee` | Version FALC en premier, version complète en dessous |
| Accessibilité | `/accessibilite` | Déclaration d'accessibilité et moyen de signaler un problème |

### Exigences

**Fonctionnement**

- Site statique, généré depuis `content/`. Chaque page est lisible sans JavaScript.
- La recherche instantanée est une amélioration : sans JavaScript, la liste alphabétique et les thèmes suffisent pour trouver un mot.
- Bouton « Écouter » avec la synthèse vocale du navigateur. Il n'apparaît que si une voix française est disponible. Même comportement que dans l'app : toute la fiche, un simple arrêt, reprise au début.
- Sur iPhone, un bandeau discret propose d'ouvrir la fiche dans l'app. Les liens universels sont déclarés.
- Le site héberge aussi le paquet de contenu que l'app télécharge.

**Accessibilité**

- Conformité visée : RGAA 4 et WCAG 2.2 niveau AA, vérifiée par un audit avant la mise en ligne.
- Au-delà de la norme, les mêmes principes d'interface que l'app : une chose par page, texte et image sur chaque bouton, aucune fenêtre surgissante.
- Lisible avec un zoom de 200 %, utilisable au clavier, focus toujours visible, thème clair et sombre, animations désactivées si le système le demande.
- L'interface du site est rédigée en FALC et relue en séance comme les fiches.

**Performance et sobriété**

- Moins de 100 Ko par page hors image, polices du système, images en format vectoriel quand c'est possible.
- Aucun cookie, aucun traceur, donc aucun bandeau de consentement.
- Aucune mesure d'audience.

**Référencement**

- Une adresse stable par mot, qui ne change jamais même si la fiche est réécrite.
- Titre de page au format « Mot : définition simple ». Description reprise de la première phrase de la définition.
- Données structurées `DefinedTerm`, plan du site, image de partage avec le mot et son pictogramme. Tant que la V1 n'est pas publiée, tout le site est servi en noindex, par la balise et par l'en-tête HTTP ; l'indexation est ouverte à la publication.

### Prévu pour plus tard

- Installation sur l'écran d'accueil et consultation hors ligne sur Android (application web progressive).
- Page d'impression d'une fiche ou d'un thème, pour les accompagnants et les ateliers.

## Vie privée, licences et qualité

### Données

L'app et le site ne collectent aucune donnée personnelle.

| Donnée | Où elle vit | Quitte l'appareil |
| --- | --- | --- |
| Derniers mots consultés, vitesse de la voix | Sur l'appareil | Non |
| Image de la caméra | En mémoire, le temps de la reconnaissance | Non |
| Recherche dictée | Dictée du système, sur l'appareil quand il le permet | Selon les réglages du téléphone |
| Mot demandé | Point de collecte | Oui : le mot seul, sans identifiant ni adresse IP conservée |

- Les autorisations (caméra, micro) sont demandées au premier usage de la fonction, jamais au lancement.
- L'écran « Demander un mot » rappelle de ne pas écrire son nom ni d'information personnelle.
- Un avertissement en FALC figure dans « Aide et à propos » : le dictionnaire explique des mots, il ne remplace ni un médecin ni un conseiller.

### Licences

| Objet | Proposition | État |
| --- | --- | --- |
| Code de l'app et du site | Licence MIT | Décidé |
| Définitions | Creative Commons avec partage à l'identique | Décidé : BY-NC-SA tant que des pictogrammes ARASAAC sont intégrés |
| Pictogrammes | ARASAAC (BY-NC-SA), puis illustrations originales | Décidé |

Si les pictogrammes ARASAAC sont retenus, les fiches qui les intègrent doivent être diffusées en BY-NC-SA et créditer leur auteur, dans l'app comme sur le site.

### Séances de co-conception

Les séances avec Sophia servent à la fois à valider les fiches et à tester l'interface. La première discussion avec elle se fera sur la base de la V1 en TestFlight et du site en ligne mais non indexé, avant toute publication.

- Elle participe si elle en a envie, sous la forme qui lui convient, et peut arrêter quand elle veut.
- On teste l'app, pas la personne : une difficulté est un défaut de l'app.
- Séances courtes, avec des tâches concrètes : trouver un mot vu sur un courrier, l'écouter, le retrouver dans ses derniers mots.
- L'observateur n'aide pas pendant la tâche et note où ça bloque.
- La forme de reconnaissance de sa contribution (mention dans l'app, contrepartie) se décide avec elle.

### Critères de sortie de la V1

- [ ] Toutes les fiches publiées sont au moins relues, et le nombre de fiches validées est affiché honnêtement.
- [ ] Les trois tâches de séance sont réussies sans aide.
- [ ] Tous les critères d'acceptation de l'app sont tenus sur le plus ancien iPhone pris en charge.
- [ ] L'audit d'accessibilité de l'app et celui du site ne laissent aucun défaut bloquant.
- [ ] L'app fonctionne en Accès d'aide.
- [ ] La fiche App Store et le site sont rédigés en FALC et relus en séance.

### Suivi après le lancement

Sans traceur, le suivi repose sur trois sources : les statistiques agrégées de l'App Store, le compteur des mots demandés, et les séances régulières. Les mots les plus demandés décident du lot suivant.

## Lots de réalisation

Six lots, dans cet ordre. Chaque lot se termine par quelque chose de montrable en séance.

| Lot | Contenu | Se termine par |
| --- | --- | --- |
| 0. Cadrage | Première liste de mots : 106 mots proposés dans la feuille « Mots simples : liste des mots de la V1 », dont 20 pour le lot pilote | Specs verrouillées |
| 1. Contenu | Dépôt, schéma de fiche, script de contrôle, consigne de génération, 20 fiches pilotes relues | 20 fiches relues par Adrien |
| 2. Prototype de l'app | Chercher, Fiche, Écouter, contenu embarqué | Prototype utilisable sur téléphone |
| 3. Site | Accueil, pages mot et thème, liste, paquet de contenu, mise en ligne | Site en ligne en noindex, liens partageables |
| 4. App complète | Photo, dictée, Thèmes, demande de mot, mise à jour du contenu, Spotlight, App Intents, Accès d'aide | Version TestFlight, puis première discussion avec Sophia |
| 5. Finition | Audits d'accessibilité, séances, centaine de fiches, fiche App Store, pages légales, retrait du noindex | Publication |

## Décisions prises sur les dix points

Les dix points sont tranchés. Le nom « Mots simples » est confirmé et le domaine motssimples.fr est réservé.

- [ ] **Source des pictogrammes.** Décidé : ARASAAC pour lancer, puis remplacement progressif par des illustrations originales.
- [ ] **Publication des fiches relues.** Décidé : les fiches relues sont publiées avec la mention « Pas encore validé ».
- [ ] **Version minimale d'iOS.** Décidé : iOS 26.
- [ ] **Nom.** Décidé : pas de « FALC » dans le nom, et un nom de domaine dédié. Nom retenu : « Mots simples ». Adrien a vérifié la base de marques de l'INPI et l'App Store le 26 novembre 2026 : rien ne s'y oppose. Le domaine motssimples.fr est réservé depuis le 26 novembre 2026 : c'est l'adresse du site.
- [ ] **Open source et licences.** Décidé : tout est ouvert, dépôt public dès le début. Code sous licence MIT, fiches en Creative Commons BY-NC-SA tant qu'elles intègrent des pictogrammes ARASAAC.
- [ ] **Hébergement.** Décidé : Railway, pour le site statique et pour le point de collecte des mots demandés.
- [ ] **Tutoiement ou vouvoiement.** Décidé : vouvoiement, partout.
- [ ] **Modèle d'IA pour les brouillons.** Décidé : Claude Code, par lots, à la main. La consigne reste versionnée dans le dépôt.
- [ ] **Générateur du site.** Décidé : Astro.
- [ ] **Mesure d'audience du site.** Décidé : aucune.

## Sources

- [Apple : Assistive Access, documentation développeur](https://developer.apple.com/documentation/accessibility/assistive-access)
- [Apple : session WWDC25 sur l'Accès d'aide](https://developer.apple.com/videos/play/wwdc2025/238/)
- [AppleVis : nouveautés d'accessibilité d'iOS 27 et appareils compatibles](https://applevis.com/comment/215310)
- [ARASAAC : conditions d'utilisation](https://aulaabierta.arasaac.org/en/terms-of-use)
- Étude préalable : FALC, état des lieux des apps et services, et propositions pour le bien commun
