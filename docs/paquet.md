# Le paquet de contenu

Le paquet est le contenu du dictionnaire, prêt à être lu par l'app et servi par le site.
Il est généré par `tools/build-content.ts` à partir de `content/mots/*.yaml`.

## Commandes

```
npm run build:content                                  # mode public, dans dist/contenu/v1/
npm run build:content -- --preversion                  # toutes les fiches, brouillons compris
npm run build:content -- --preversion --out <dossier>  # autre dossier de sortie
npm run build:content -- --date 2026-12-01             # fixe « genere_le »
```

Le contrôle des fiches tourne d'abord. Une seule erreur arrête tout et rien n'est écrit.

## Deux modes

| Mode | Fiches | `preversion` |
| --- | --- | --- |
| `--public`, par défaut | `relu` et `valide` seulement | `false` |
| `--preversion` | toutes, brouillons compris | `true` |

Un paquet de préversion ne doit jamais être servi au public. L'app publique le refuse.

## Fichiers

Le dossier de sortie contient deux fichiers. Le « v1 » du chemin est la version du format, pas celle du contenu.

### `paquet.json`

```json
{
  "schema": 1,
  "version": "c6283ccafb54",
  "genere_le": "2026-11-27",
  "preversion": true,
  "themes": [{ "slug": "argent", "nom": "Argent" }],
  "fiches": [{ "schema": 1, "mot": "Facture", "slug": "facture", "…": "…" }]
}
```

| Champ | Sens |
| --- | --- |
| `schema` | Numéro du format. Une app qui lit un numéro plus grand que celui qu'elle connaît garde son contenu |
| `version` | Les 12 premiers caractères du SHA-256 du contenu : schéma, mode, thèmes et fiches. Elle ne dépend ni de l'heure ni des champs internes |
| `genere_le` | Date du contenu. Par défaut, la date la plus récente portée par les fiches. `--date` ou `SOURCE_DATE_EPOCH` la remplace |
| `preversion` | `true` si le paquet contient des brouillons |
| `themes` | Les huit thèmes, dans l'ordre d'affichage, avec leur nom |
| `fiches` | Les fiches, triées par `slug` |

Une fiche du paquet a les champs de `tools/schema.ts`, dans le même ordre, **sauf** `source_de_reference` et `notes_de_relecture`.
Ces deux champs sont internes : ils restent dans le dépôt.
Dans `autres_sens`, `exemple` est toujours présent, à `null` s'il est vide.

### `manifest.json`

```json
{
  "schema": 1,
  "version": "c6283ccafb54",
  "preversion": true,
  "paquet": "paquet.json",
  "sha256": "…64 caractères…",
  "taille": 16648
}
```

`sha256` et `taille` portent sur les octets exacts de `paquet.json`.
L'app lit d'abord le manifeste, compare `version`, télécharge le paquet, puis vérifie l'empreinte et la taille.

## Garanties

- **Déterministe.** Deux générations du même contenu, dans le même mode, donnent les mêmes octets.
- **Compatible.** Un lecteur ignore les champs qu'il ne connaît pas. Un champ ajouté ne change pas `schema`.
  `schema` augmente seulement si un champ existant change de sens ou disparaît.
- **Pictogrammes.** Tant que `pictogramme.id` est `null`, le paquet ne contient aucune image.
  Quand les pictogrammes seront choisis, ils seront ajoutés au dossier et listés dans le manifeste.
