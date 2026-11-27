# Lot 1 : contenu

## But

À la fin de ce lot, le dépôt contient 20 fiches pilotes en brouillon qui passent le contrôle,
des outils fiables pour les vérifier, et un rapport qui dit à Adrien quoi relire en priorité.

Lis d'abord `CLAUDE.md`, puis `prompts/generer-fiche.md`, puis `content/mots/facture.yaml`.

## Ce qui est déjà là

- `tools/schema.ts` : le schéma d'une fiche.
- `tools/check-fiches.ts` et ses tests : le contrôle.
- `prompts/generer-fiche.md` : la consigne de rédaction.
- `content/mots/facture.yaml` : la fiche modèle, en brouillon.
- `content/liste-v1.csv` : les 106 mots, dont 20 marqués `lot` = 1.

## Tâches, dans l'ordre

### 1. Vérifier le kit

- `npm ci`, puis `npm run ci`. Tout doit passer avant de commencer.
- Si quelque chose échoue, corrige-le d'abord, dans un commit à part.

### 2. Rédiger les 19 autres fiches pilotes

Les mots sont les lignes `lot` = 1 de `content/liste-v1.csv`, sauf `facture` :

échéance, prélèvement, RIB, AAH, ordonnance, mutuelle, carte Vitale, médecin traitant, bail, loyer,
préavis, fiche de paie, congés payés, ESAT, justificatif de domicile, formulaire, MDPH, curatelle, rendez-vous.

Pour chaque mot :

1. Ouvre la source indiquée dans la colonne `source` et lis la page qui définit le mot.
   Si la colonne est vide, c'est un mot courant : `source_de_reference: null`.
   Si tu n'as pas accès au web ou si la page est introuvable : `url: null` et une note de relecture.
2. Rédige la fiche en suivant `prompts/generer-fiche.md`.
3. Lance `npm run check`. Corrige jusqu'à zéro erreur sur cette fiche.
4. Un commit par fiche : `Fiche : <mot> (brouillon)`.

Points d'attention propres à ce lot :

- **Sigles** (RIB, AAH, ESAT, MDPH) : remplis `prononciation`, donne la forme développée dans `formes_de_recherche`,
  et explique ce que c'est avec des mots simples plutôt que de développer le sigle dans la définition.
- **Mots sensibles** (AAH, MDPH, ESAT, curatelle) : ils concernent directement le lecteur. Ton neutre et respectueux,
  aucune formulation qui infantilise ou qui présente la personne comme incapable.
- **Liens** : `mots_lies` ne peut pointer que vers un mot de `liste-v1.csv`. Privilégie les 20 mots pilotes.
- **Avertissements** du contrôle : traite-les ou explique dans le rapport pourquoi tu les laisses.

### 3. Relire ton propre travail

Quand les 20 fiches existent, relis-les toutes d'une traite, comme le ferait un lecteur :

- Le même mot est-il expliqué de la même façon d'une fiche à l'autre ?
- Une définition utilise-t-elle un mot difficile qui n'a pas sa fiche ? Ajoute-le à la section « Mots à ajouter » du rapport.
- Deux fiches se renvoient-elles l'une à l'autre sans rien expliquer ?

Corrige, puis relance `npm run ci`.

### 4. Renforcer le contrôle si nécessaire

Si tu as dû corriger à la main un défaut que le script aurait pu attraper, ajoute la règle et son test.
N'affaiblis aucune règle existante pour faire passer une fiche : corrige la fiche.

### 5. Écrire le rapport

`docs/rapports/lot-1.md`, en français, avec :

- Un tableau des 20 fiches : mot, nombre de phrases, source ouverte ou non, nombre de notes de relecture, avertissements restants.
- **À relire en priorité** : les 5 fiches dont tu es le moins sûr, et pourquoi.
- **Choix pris** : chaque décision que tu as dû prendre seul.
- **Mots à ajouter** à la liste, repérés en rédigeant.
- **Modifications des outils ou de la consigne**, avec la raison.
- **Ce qui n'a pas pu être fait**, par exemple des sources inaccessibles.

## Critères de fin

- [ ] 20 fichiers dans `content/mots/`, un par mot pilote.
- [ ] Toutes les fiches ont `statut: brouillon`.
- [ ] `npm run ci` passe, sans erreur.
- [ ] Chaque source citée a réellement été ouverte, sinon `url: null` avec une note.
- [ ] Aucun montant, délai ou seuil légal dans les fiches.
- [ ] `docs/rapports/lot-1.md` est écrit.
- [ ] Tout est commité sur la branche `lot-1`.

## Hors périmètre de ce lot

- Les 86 autres mots de la liste.
- Le choix des pictogrammes ARASAAC : laisse `pictogramme.id: null`, remplis seulement `alt`.
- Le paquet de contenu, le site et l'app : ce sont les lots 2 à 4.
- Passer une fiche en `relu` : c'est le travail d'Adrien.
