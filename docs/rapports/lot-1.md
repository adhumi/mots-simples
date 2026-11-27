# Rapport du lot 1 : contenu

27 novembre 2026. Branche `lot-1`.

## Résumé

- 20 fiches dans `content/mots/`, toutes en `statut: brouillon`.
- `npm run ci` passe : 0 erreur, 18 avertissements, tous de la même règle `source`.
- **Aucune source n'a pu être ouverte.** Le conteneur de travail n'a pas d'accès au web, sauf aux registres de paquets.
  Les 17 fiches qui ont une source dans la liste ont donc `url: null` et une note de relecture.
  Leur texte est écrit de mémoire. La relecture contre la source est indispensable pour chacune.

## Les 20 fiches

| Mot | Phrases | Source ouverte | Notes de relecture | Avertissements restants |
| --- | --- | --- | --- | --- |
| AAH | 3 | non | 4 | 1, `source` |
| Bail | 3 | non | 4 | 1, `source` |
| Carte Vitale | 3 | non | 4 | 1, `source` |
| Congés payés | 3 | non | 4 | 1, `source` |
| Curatelle | 3 | non | 5 | 1, `source` |
| Échéance | 2 | non | 3 | 1, `source` |
| ESAT | 3 | non | 6 | 1, `source` |
| Facture | 3 | fiche modèle, non rouverte par moi | 2 | 0 |
| Fiche de paie | 3 | non | 4 | 1, `source` |
| Formulaire | 3 | sans objet, mot courant | 2 | 1, `source` |
| Justificatif de domicile | 3 | non | 3 | 1, `source` |
| Loyer | 3 | non | 4 | 1, `source` |
| MDPH | 3 | non | 5 | 1, `source` |
| Médecin traitant | 3 | non | 4 | 1, `source` |
| Mutuelle | 3 | non | 4 | 1, `source` |
| Ordonnance | 3 | non | 3 | 1, `source` |
| Préavis | 3 | non | 4 | 1, `source` |
| Prélèvement | 3 | non | 4 | 1, `source` |
| Rendez-vous | 2 | sans objet, mot courant | 3 | 0 |
| RIB | 3 | non | 4 | 1, `source` |

Les avertissements `source` restent parce qu'ils disent vrai : aucune source n'est ouverte.
Ils partiront quand Adrien aura rempli `titre` et `url` à la relecture.
Pour « formulaire », la liste ne donne pas de source, mais le thème « papiers » déclenche la règle. Je n'ai pas affaibli la règle.

## À relire en priorité

1. **Curatelle.** La fiche décrit la curatelle la plus légère. Il en existe de plus fortes, où le curateur fait plus.
   La phrase « Vous continuez à décider vous-même pour la vie de tous les jours » peut être fausse dans certains cas.
2. **ESAT.** Le nom développé a changé récemment et je n'ai pas pu le vérifier. Les deux formes sont dans les formes de recherche.
   « Vous recevez de l'argent chaque mois pour votre travail » évite le mot « salaire », car le statut est particulier. À vérifier.
3. **Congés payés.** « Votre employeur doit donner son accord sur les dates » simplifie une règle plus précise.
4. **Mutuelle.** La fiche suit l'usage courant. Le terme exact est « complémentaire santé ». La phrase sur le remboursement est très simplifiée.
5. **AAH et MDPH.** Mots sensibles, écrits sans source. La fiche AAH ne dit pas qui verse l'aide. La fiche MDPH ne dit pas qui décide.

## Choix pris

- **Source non ouverte.** `source_de_reference` garde le nom du site prévu dans `titre`, suivi de « page non ouverte », avec `url: null`.
  `consulte_le` est obligatoire dans le schéma : j'y ai mis la date de rédaction. Ce n'est pas une date de consultation réelle.
- **« Document » partout**, comme dans la fiche modèle, plutôt que « papier ».
- **« En situation de handicap »** dans les trois fiches concernées, toujours la même formule.
- **« Sécurité sociale »** plutôt que « Assurance Maladie », car c'est le mot que les gens disent. Il n'a pas de fiche.
- **Sigles** : la définition dit ce que c'est sans développer le sigle. La forme développée est dans `formes_de_recherche`.
  Prononciations choisies : `rib`, `a-a-hache`, `ésate`, `èm-dé-pé-hache`. À écouter avec la vraie voix.
- **Aucun chiffre** dans les fiches, même dans les exemples, pour ne laisser aucun avertissement `chiffre`.
- **Expressions** (carte Vitale, médecin traitant) : un mot de l'expression revient dans la définition. Le contrôle l'accepte, la consigne moins. Signalé en note.
- **« Congés payés »** reste au pluriel, comme dans l'usage et dans la liste.
- **Autres sens gardés** : échéance (somme à payer), prélèvement (sang), ordonnance (juge), préavis (travail, grève).
- **Branches.** Une branche par lot : `lot-1` à `lot-4`, chacune partie de la précédente. La session de travail impose aussi une branche `claude/amazing-goldberg-9rwyv0` : elle porte le même état que `lot-4`.

## Relecture d'ensemble

- Le même mot est expliqué de la même façon d'une fiche à l'autre : « document », « propriétaire », « employeur », « Sécurité sociale ».
- Pas de renvoi circulaire vide : « loyer » cite le bail, « bail » n'a pas besoin du mot « loyer ». « RIB » cite le prélèvement, pas l'inverse.
- Les mots difficiles employés ont tous une fiche prévue dans la liste, sauf ceux de la section suivante.

## Mots à ajouter à la liste

Repérés dans les définitions, sans fiche prévue :

- Sécurité sociale
- Salaire (la liste a « salaire brut » et « salaire net », pas le mot seul)
- Compte bancaire, ou banque
- Handicap, ou « situation de handicap »
- Département
- Curateur (peut rester une forme de recherche de « curatelle »)
- Grève
- Pharmacien, pharmacie
- Complémentaire santé (forme de recherche de « mutuelle » aujourd'hui)
- Entreprise adaptée (à ne pas confondre avec ESAT)

## Modifications des outils ou de la consigne

- `tools/check-fiches.ts` : nouvelle règle bloquante `source-sans-note`. Une source sans adresse doit avoir une note de relecture qui parle de la source.
  Raison : c'est la règle éditoriale 4, et rien ne la vérifiait. Test ajouté.
- `.gitignore` ajouté : `node_modules/`, `dist/`.
- La consigne `prompts/generer-fiche.md` n'a pas changé.
- Aucune règle affaiblie.

## Ce qui n'a pas pu être fait

- **Ouvrir les sources.** Sites bloqués par la politique réseau du conteneur : service-public, ameli, monparcourshandicap,
  mesquestionsdargent, code.travail. Pour refaire ce travail avec les sources, il faut autoriser ces sites dans l'environnement.
- Le dépôt n'a pas de configuration d'intégration continue. `npm run ci` est lancé à la main avant chaque commit.

## Ce qu'Adrien doit vérifier

- Chaque fiche contre sa source, puis remplir `titre`, `url`, `consulte_le`.
- Les cinq fiches prioritaires ci-dessus.
- Les prononciations des quatre sigles, à l'oreille.
- La liste des mots à ajouter.
