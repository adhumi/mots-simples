# Point de collecte des mots demandés

Un petit service en Node, sans dépendance. Il reçoit un mot et tient un compteur par mot. Rien d'autre.

| Adresse | Rôle |
| --- | --- |
| `POST /demandes` | Un seul champ, `mot`. En JSON pour l'app, en formulaire pour le site |
| `GET /demandes` | Les compteurs, pour Adrien. Demande l'en-tête `Authorization: Bearer <JETON_DE_LECTURE>`. `?format=csv` pour un tableur |
| `GET /sante` | Surveillance |

## Ce qu'il garde

Pour chaque mot : le nombre de demandes, le jour de la première et de la dernière. Pas d'heure, pas d'adresse IP, pas d'identifiant.
Il ne pose aucun cookie et n'écrit aucun journal de requêtes.

Un mot est accepté s'il fait de 2 à 40 caractères, avec des lettres, des espaces, des tirets et des apostrophes seulement.
Un chiffre, une arobase ou un point le font refuser : cela écarte les numéros et les adresses.

La limite de débit garde en mémoire une empreinte de l'origine, calculée avec un sel tiré au hasard qui change chaque minute.
Elle n'est jamais écrite.

## Lancer et tester

```
node server/serveur.mjs                      # port 8081, compteurs dans ./donnees
JETON_DE_LECTURE=essai node server/serveur.mjs
curl -X POST localhost:8081/demandes -H 'Content-Type: application/json' -d '{"mot":"hypothèque"}'
curl localhost:8081/demandes -H 'Authorization: Bearer essai'
npm test                                     # les tests du service tournent avec ceux des outils
```

Variables : `PORT`, `DOSSIER_DES_DONNEES`, `JETON_DE_LECTURE`, `ADRESSE_DU_SITE`. Le déploiement est décrit dans `docs/deploiement.md`.
