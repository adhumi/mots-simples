# Consigne : générer le brouillon d'une fiche « Mots simples »

Version 1 · 26 novembre 2026

Tu rédiges le brouillon d'une fiche de dictionnaire pour « Mots simples ».
Le lecteur est un adulte avec un handicap intellectuel, qui lit seul sur son téléphone.
Ta fiche sera relue par un humain, puis testée avec des personnes concernées.
Elle n'est donc jamais publiée telle quelle : son statut est toujours `brouillon`.

## Ce qu'on te donne

- `mot` : le mot ou l'expression à expliquer.
- `theme` : un seul parmi `argent`, `sante`, `logement`, `travail`, `papiers`, `justice`, `transports`, `vie-quotidienne`.
- `source` : le nom d'un site public où vérifier le sens (peut être vide pour un mot courant).

## Ce que tu fais, dans cet ordre

1. Si une source est donnée, ouvre la page qui définit le mot et lis-la. Note son titre et son adresse exacte.
2. Écris la définition, l'exemple et les autres champs en suivant les règles ci-dessous.
3. Passe la liste de contrôle. Corrige ce qui ne passe pas.
4. Écris le fichier `content/mots/<slug>.yaml`, au format exact de `content/mots/facture.yaml`. Une phrase par ligne dans `definition`.
5. Lance `npm run check`. Corrige jusqu'à ce qu'il n'y ait plus d'erreur pour ta fiche.

## Règles d'écriture

Ces règles viennent de la méthode FALC. Elles s'appliquent à la définition, à l'exemple et à « à ne pas confondre ».

- 1 à 3 phrases pour la définition. 1 phrase pour l'exemple.
- 15 mots au plus par phrase. Une seule idée par phrase.
- Voix active, présent de l'indicatif, forme affirmative quand c'est possible.
- Vouvoiement. On s'adresse au lecteur : « vous recevez », « vous payez ».
- Des mots de tous les jours. Aucun mot plus difficile que le mot expliqué.
- Si un mot difficile est inévitable, il doit avoir sa propre fiche : ajoute-le dans `mots_lies`.
- La première phrase commence par le mot et dit ce que c'est : « Une facture est… ».
- Après ce début, le mot expliqué et les mots de sa famille ne reviennent plus dans la définition. Utilise « elle », « il », « ce document ».
- Pas de sigle non expliqué, pas d'abréviation, pas de parenthèses, pas de « etc. ».
- Pas de métaphore, pas d'expression imagée, pas d'humour.
- Les nombres s'écrivent en chiffres. Pas de pourcentage ni de grand nombre si on peut l'éviter.
- Le même mot désigne toujours la même chose. Pas de synonymes pour varier.
- L'exemple montre une situation de la vie courante d'un adulte : courrier, travail, médecin, logement, transports.
- L'exemple ne répète pas la définition. Il contient le mot expliqué.

## Exactitude

- La définition est simple mais vraie. Une simplification qui devient fausse est refusée.
- Ne donne aucun montant, délai, seuil ou condition légale : ils changent, et le dictionnaire explique des mots, pas des règles.
- Ne donne aucun conseil médical, juridique ou financier.
- Si le mot a plusieurs sens courants, mets le plus fréquent dans `definition` et les autres dans `autres_sens` (3 au plus, mêmes règles). Chaque autre sens s'écrit `- definition: [phrase, phrase]` avec un `exemple` facultatif.
- N'invente jamais une adresse de page. Si tu n'as pas pu ouvrir la source, écris `url: null` et dis-le dans `notes_de_relecture`.

## Les autres champs

- `slug` : le mot en minuscules, sans accent, avec des tirets. Il ne changera plus jamais.
- `prononciation` : `null` en général. Pour un sigle ou un mot que la synthèse vocale lit mal, écris comment le dire, par exemple `a-a-hache` pour AAH ou `rib` pour RIB.
- `a_ne_pas_confondre` : un seul mot proche, et la différence en 1 ou 2 phrases courtes. `null` si rien ne s'impose.
- `mots_lies` : 4 slugs au plus, des mots de la liste de la V1 de préférence.
- `formes_de_recherche` : pluriel, féminin, sigle ou forme développée, et 2 ou 3 fautes fréquentes. Jamais affichées.
- `pictogramme.alt` : une phrase qui décrit l'image idéale pour ce mot. Laisse `id: null`.
- `notes_de_relecture` : tout ce dont tu doutes. Un mot peut-être trop difficile, un choix de simplification, un sens écarté.

## Liste de contrôle avant d'écrire le fichier

- [ ] Chaque phrase a 15 mots ou moins.
- [ ] La définition a 1 à 3 phrases et commence par le mot.
- [ ] Le mot expliqué ne revient pas dans la définition après ce début.
- [ ] Aucun mot de la définition n'est plus difficile que le mot expliqué.
- [ ] Tout est au présent, à la voix active, au vouvoiement.
- [ ] L'exemple contient le mot et décrit une situation d'adulte.
- [ ] Aucun montant, délai ou condition légale.
- [ ] La source a été ouverte et son adresse est exacte, ou `url: null` avec une note.
- [ ] Lue à voix haute, chaque phrase se comprend sans voir l'écran : pas de parenthèse, de barre oblique ni de symbole.
- [ ] Si le mot est un sigle, `prononciation` est rempli.
- [ ] `statut: brouillon` et `valide_le: null`.
- [ ] Le fichier respecte exactement les champs et l'ordre de `content/mots/facture.yaml`.

## Exemple de référence

Voir `content/mots/facture.yaml`. Reproduis son niveau de langue, pas ses phrases.

## Par lots

Quand on te donne plusieurs mots, traite-les un par un et écris un fichier par mot.
À la fin, donne un tableau : mot, nombre de phrases, source ouverte ou non, nombre de notes de relecture.
