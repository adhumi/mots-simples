# Mots simples

Un dictionnaire gratuit qui explique les mots compliqués avec des phrases simples, une image et une voix.
Deux formes, un seul contenu : une app iOS native hors ligne, et le site motssimples.fr où chaque mot a sa page.

Le public de conception est un adulte avec un handicap intellectuel, qui utilise l'app seul.
Projet d'intérêt général : gratuit, sans publicité, sans compte, sans traceur, open source.

Les spécifications complètes sont dans `docs/specs.md`. Ce fichier-ci résume ce qui est décidé.
Sur ce que le produit doit faire, `docs/specs.md` l'emporte, puis ce fichier. Sur l'ordre et le découpage du travail, c'est le brief du lot en cours qui décide.

## Structure du dépôt

| Dossier | Contenu |
| --- | --- |
| `content/mots/` | Une fiche YAML par mot. `facture.yaml` est la fiche modèle |
| `content/liste-v1.csv` | Les 106 mots prévus pour la V1 : mot, slug, thème, lot, source à consulter |
| `prompts/` | Consignes de génération des brouillons, versionnées |
| `tools/` | Schéma des fiches (`schema.ts`), contrôle (`check-fiches.ts`), tests |
| `site/` | Site statique Astro (lot 3) |
| `ios/` | Projet Xcode et modules Swift (lots 2 et 4) |
| `docs/` | Specs, briefs de lots, rapports |

## Commandes

```
npm ci               # installer
npm run check        # contrôler toutes les fiches (code de sortie 1 si erreur)
npm run check -- --strict   # les avertissements bloquent aussi
npm test             # tests des outils
npm run typecheck    # TypeScript
npm run ci           # les trois à la suite : c'est ce que la CI lance
```

Node 22 ou plus. Outils en TypeScript, lancés avec `tsx`. Pas d'autre dépendance sans raison écrite dans le rapport.

## Règles éditoriales : à ne jamais enfreindre

1. **Tu ne crées que des brouillons.** Une fiche que tu écris ou modifies a `statut: brouillon` et `valide_le: null`.
   - `relu` est posé par Adrien après relecture contre la source.
   - `valide` est posé après une séance avec des personnes concernées.
   - Si tu modifies le texte d'une fiche `relu` ou `valide`, elle repasse en `brouillon`.
2. **Un brouillon n'est jamais public.** Il n'apparaît qu'en préversion : site servi en noindex et builds TestFlight, avec un bandeau « Brouillon non relu ». La version publique n'embarque que `relu` et `valide`.
3. **Le mot « FALC » et le logo européen** ne s'appliquent qu'aux fiches `valide`. Ne les utilise pas ailleurs.
4. **N'invente jamais une source.** Si tu n'as pas ouvert la page, `url: null` et une note de relecture.
5. **Aucun montant, délai, seuil ou condition légale** dans une fiche. Aucun conseil médical, juridique ou financier.
6. **Un slug ne change jamais** une fois publié : il fait l'adresse de la page.
7. Suis `prompts/generer-fiche.md` pour toute fiche. Si la consigne te semble fausse, ne la contourne pas : corrige-la dans un commit séparé et explique-le dans le rapport.

## Règles d'écriture, en bref

Vouvoiement partout. 1 à 3 phrases par définition, 15 mots au plus par phrase, une idée par phrase.
Présent, voix active, mots de tous les jours, pas de parenthèses, pas de sigle non expliqué.
La première phrase commence par le mot. Il ne revient plus ensuite.
Le détail est dans `prompts/generer-fiche.md`, et `npm run check` en vérifie une partie.

L'interface de l'app et du site suit les mêmes règles : elle est elle-même écrite simplement.

## Décisions prises

| Sujet | Décision |
| --- | --- |
| Nom et domaine | « Mots simples », motssimples.fr. Pas de « FALC » dans le nom |
| Périmètre V1 | Dictionnaire seul. Le lecteur de textes viendra après et réutilisera le cœur |
| Plateforme | iOS natif, iOS 26 au minimum, iPhone et iPad. Le site sert les autres appareils |
| Identifiant de l'app | `fr.adhumi.motssimples` |
| App | Swift 6, SwiftUI, sans dépendance tierce. Modules `DictionaryCore`, `DictionaryUI`, app |
| Navigation | Pas de barre d'onglets : accueil (Chercher), bouton « Voir les thèmes », fiche. Pas de « Mes mots » en V1 |
| Style | Doux et coloré : formes très arrondies, vert calme, police Lexend, cartes blanches sur fond teinté, bordures légères. Liquid Glass réservé aux éléments flottants, contenu opaque |
| Écoute | « Tout écouter » lit toute la fiche. Un bouton d'écoute par bloc et par mot dans les listes : ces petits boutons montrent l'image seule, sans le mot « Écouter », pour ne pas charger l'écran. C'est la seule exception à « une image et un mot ». Ils font 30 points à l'écran, dans une zone de toucher de 44 points. Arrêt simple, reprise au début, pas de pause |
| Partage | Pas de bouton « Partager » sur la fiche : retiré par Adrien. Les liens universels restent : une page web de mot ouvre la fiche dans l'app |
| Listes de mots | Dans une ligne : l'image, le mot, le bouton d'écoute, puis le chevron en bout de ligne |
| Accessibilité | Accès d'aide, tailles de texte maximales, VoiceOver, réglages d'affichage, cibles de 44 points au moins |
| Site | Astro, statique, lisible sans JavaScript, RGAA 4 et WCAG 2.2 AA, aucun cookie, aucune mesure d'audience |
| Indexation | Tout le site en noindex (balise et en-tête HTTP) jusqu'à la publication de la V1 |
| Hébergement | Railway : site statique et point de collecte des mots demandés |
| Contenu | Brouillons par IA dans Claude Code, relecture par Adrien, validation en séance |
| Pictogrammes | ARASAAC pour lancer (BY-NC-SA), illustrations originales ensuite |
| Licences | Code MIT. Contenu BY-NC-SA tant qu'il intègre ARASAAC |
| Données | Aucune donnée personnelle. « Demander un mot » envoie le mot seul |

## Les lots

| Lot | Contenu | Se termine par |
| --- | --- | --- |
| 1. Contenu | Schéma, contrôle, consigne, 20 fiches pilotes | 20 brouillons qui passent le contrôle, prêts à relire |
| 2. Prototype de l'app | Chercher, Fiche, Écouter, contenu embarqué | Prototype utilisable sur téléphone |
| 3. Site | Accueil, pages mot et thème, liste, paquet de contenu | Site en ligne en noindex |
| 4. App complète | Photo, dictée, Thèmes, demande de mot, mise à jour du contenu, Spotlight, App Intents, Accès d'aide | Version TestFlight |
| 5. Finition | Audits, séances, centaine de fiches, pages légales, retrait du noindex | Publication |

Le brief détaillé d'un lot est dans `docs/LOT-<n>.md`. Ne commence pas un lot sans son brief.

Pour enchaîner plusieurs lots :

- Fais-les dans l'ordre. Ne passe au suivant que si les critères de fin du lot en cours sont tenus et son rapport écrit.
- Si un critère ne peut pas être tenu, par exemple faute de Xcode ou de réseau, dis-le dans le rapport, puis continue avec ce qui reste faisable.
- Une branche par lot, partie de la branche du lot précédent.
- Le lot 5 dépend surtout de personnes : fais ce que son brief te confie, puis arrête-toi.

## Travailler sans interruption

Adrien lance souvent le travail sans surveiller. Dans ce cas :

- Ne pose pas de question. Prends la lecture la plus raisonnable, écris ton choix dans le rapport du lot, et continue.
- Arrête-toi seulement devant une action irréversible ou qui engage de l'argent ou une publication. Prépare tout, décris la décision à prendre dans le rapport, et passe à la suite.
- Travaille sur une branche `lot-<n>`, avec de petits commits au message clair en français.
- Lance `npm run ci` avant chaque commit. Ne commite pas un état qui échoue.
- Termine chaque lot par `docs/rapports/lot-<n>.md` : ce qui est fait, ce qui ne l'est pas, les choix pris, les doutes, ce qu'Adrien doit vérifier.

## Ce que tu ne fais pas sans demande explicite

- Passer une fiche en `relu` ou `valide`.
- Déployer, acheter, créer un compte, toucher à des secrets ou à des DNS.
- Retirer le noindex, publier sur l'App Store, envoyer un build TestFlight.
- Ajouter un traceur, un cookie, une mesure d'audience ou une dépendance réseau à l'exécution.
- Ajouter une fonction hors périmètre de la V1 : comptes, synchronisation, « Mes mots », IA à l'exécution.
