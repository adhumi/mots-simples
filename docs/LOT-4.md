# Lot 4 : app complète

## But

À la fin de ce lot, l'app a toutes les fonctions de la V1 et elle est prête à être envoyée sur TestFlight par Adrien.
Tu ne l'envoies pas.

Prérequis : les lots 2 et 3 sont terminés.
Lis `CLAUDE.md`, puis les sections « App iOS », « Standards de la plateforme » et « Vie privée » de `docs/specs.md`.

Plusieurs fonctions s'appuient sur des API système qui évoluent d'une version d'iOS à l'autre.
Avant d'en utiliser une, vérifie sa forme actuelle dans la documentation Apple pour iOS 26 et suivants. Ne te fie pas à ta mémoire.

## Tâches, dans l'ordre

### 1. Écran Thèmes

- Bouton flottant « Voir les thèmes » sur l'accueil. Pas de barre d'onglets.
- Grille des huit thèmes, chacun avec sa couleur, son image et son nom. Puis la liste des mots du thème, avec bouton d'écoute.
- « Retour » ramène toujours à l'accueil.

### 2. Chercher en parlant

- Un bouton « Dire le mot », avec image et texte, lance la reconnaissance vocale en français.
- L'autorisation est demandée au premier usage, avec une phrase simple qui dit pourquoi.
- En cas de refus, le bouton reste et explique comment réactiver. Rien d'autre n'est bloqué.
- Reconnaissance sur l'appareil quand il le permet.

### 3. Photographier un mot

- Un bouton « Prendre en photo » ouvre la caméra. Le texte est reconnu sur l'appareil, les mots sont mis en évidence.
- Toucher un mot ouvre sa fiche, ou l'écran « Mot absent ».
- Aucune image n'est enregistrée ni envoyée. Même gestion de l'autorisation que pour la voix.
- Sur un appareil sans caméra ou sans prise en charge, le bouton n'apparaît pas.

### 4. Demander un mot

Trois morceaux.

**Le point de collecte**, dans `server/` :

- Un petit service qui accepte `POST /demandes` avec un seul champ, le mot.
- Il valide : texte court, lettres, espaces, tirets et apostrophes seulement. Il normalise, puis incrémente un compteur par mot.
- Il ne journalise aucune adresse IP et ne pose aucun cookie. Limitation de débit sans stocker d'identifiant durable.
- Une lecture protégée des compteurs pour Adrien.
- Stockage : le plus simple qui tienne sur Railway. Signale ton choix et son coût éventuel.
- Tests, et la marche de déploiement ajoutée à `docs/deploiement.md`. Tu ne déploies pas.

**Dans l'app** : sur « Mot absent », un bouton « Demander ce mot ». Seul le mot part.
Sans réseau, la demande est gardée et envoyée plus tard, et l'app le dit simplement.
L'écran rappelle de ne pas écrire son nom ni d'information personnelle.

**Sur le site** : la page `/demander`, un champ et un bouton, utilisable sans JavaScript.

### 5. Mise à jour du contenu

- Au plus une fois par jour, l'app lit `manifest.json` sur le site.
- Si la version diffère : téléchargement du paquet, vérification de l'empreinte, remplacement d'un seul coup.
- Un paquet de schéma trop récent, corrompu ou incomplet est ignoré. L'app garde son contenu et ne montre aucune erreur.
- L'adresse du site est un réglage de compilation. Un build public ne charge jamais un paquet de préversion.

### 6. Intégrations système

- **Spotlight** : chaque mot est indexé et ouvre sa fiche.
- **App Intents** : « Expliquer un mot », utilisable depuis Siri et Raccourcis.
- **Liens universels** : `https://motssimples.fr/mot/<slug>` ouvre la fiche. Le partage d'une fiche envoie cette adresse.
- **Accès d'aide** : l'app déclare sa prise en charge et fournit une scène dédiée, réduite à Chercher et Fiche.

### 7. Aide et à propos

Un écran simple, écrit comme le reste : comment ça marche, qui a fait l'app, vie privée, crédits des pictogrammes, vitesse de la voix.
Il porte l'avertissement : le dictionnaire explique des mots, il ne remplace ni un médecin ni un conseiller.

### 8. Accessibilité et qualité

- Audit d'accessibilité automatique dans les tests d'interface, sur chaque écran.
- Captures aux plus grandes tailles de texte, en clair et en sombre, sur iPhone et iPad.
- Vérification du contraste des bordures légères et des éléments en verre. Si un contraste est insuffisant,
  propose une correction dans le rapport sans changer le style validé, sauf pour le mode « Augmenter le contraste ».
- Respect des réglages : texte en gras, réduction des animations, réduction de la transparence, formes de boutons.
- Mise en page iPad et toutes orientations.
- Manifeste de confidentialité renseigné. Cible : « Aucune donnée collectée ».
- Mesure des budgets de performance des specs, sur le plus ancien simulateur disponible. Donne les chiffres.

### 9. Préparer TestFlight, sans envoyer

`docs/testflight.md` : ce qu'Adrien doit régler (équipe, signature, identifiant, numéro de version),
les textes des autorisations à relire, et la liste de ce qu'il faut tester à la main sur un vrai téléphone.

### 10. Rapport

`docs/rapports/lot-4.md` : état de chaque fonction, résultats des audits, chiffres de performance,
API vérifiées dans la documentation, choix pris, textes d'interface nouveaux, ce qui demande un vrai appareil.

## Critères de fin

- [ ] Chaque critère d'acceptation de la section « App iOS » des specs est tenu, ou son écart est expliqué dans le rapport.
- [ ] L'app fonctionne en mode avion, sauf la demande de mot et la mise à jour.
- [ ] Les tests et les audits automatiques passent.
- [ ] Le point de collecte a ses tests et sa marche de déploiement.
- [ ] `docs/testflight.md` et le rapport sont écrits, sur la branche `lot-4`.

## Tu ne fais pas

- Envoyer un build, créer un identifiant d'app, toucher aux certificats.
- Déployer le point de collecte.
- Ajouter « Mes mots », un compte, une synchronisation ou une IA à l'exécution.
