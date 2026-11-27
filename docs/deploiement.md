# Déployer le site sur Railway

Rien n'est déployé. Ce document dit à Adrien quoi faire, dans l'ordre.
Le site reste en noindex tant que la V1 n'est pas publiée.

Les étapes Railway ci-dessous n'ont pas été jouées : le fichier de conteneur n'a pas pu être construit avec Docker ici.
Ses commandes ont été rejouées une à une dans un dossier propre, et le serveur démarre.

## Ce qui est prêt dans le dépôt

| Fichier | Rôle |
| --- | --- |
| `site/Dockerfile` | Construit le site, puis le sert avec `site/serveur.mjs`. Contexte : la racine du dépôt |
| `site/railway.json` | Dit à Railway d'utiliser ce Dockerfile et de vérifier que `/` répond |
| `site/serveur.mjs` | Serveur statique en Node, sans dépendance : noindex, cache, sécurité, adresses sans `.html` |
| `.dockerignore` | Garde `ios/`, `docs/` et `node_modules/` hors de l'image |

## Les variables

Elles sont lues **à la construction** du site. Les changer demande donc un nouveau déploiement.

| Variable | Valeur jusqu'à la publication | Sens |
| --- | --- | --- |
| `MODE_CONTENU` | `preversion` | `preversion` : toutes les fiches, brouillons compris. `public` : fiches relues et validées seulement |
| `INDEXATION` | `fermee` | `fermee` : noindex partout. `ouverte` : le site peut être indexé |
| `APP_STORE_ID` | vide | Numéro de l'app sur l'App Store. Affiche le bandeau « ouvrir dans l'app » sur iPhone |
| `ADRESSE_DES_DEMANDES` | vide | Adresse du point de collecte des mots demandés. Voir le lot 4 |
| `PORT` | fournie par Railway | Port d'écoute du serveur |

Ces valeurs sont déjà les valeurs par défaut du Dockerfile. Sans aucune variable, le site est en préversion et en noindex.

Deux garde-fous :

- `MODE_CONTENU=preversion` avec `INDEXATION=ouverte` fait échouer la construction. Un brouillon n'est jamais public.
- Un seul réglage, `INDEXATION`, commande la balise `<meta name="robots">` et l'en-tête `X-Robots-Tag`.
  La construction l'écrit dans `reglages.json`, que le serveur lit. La balise et l'en-tête ne peuvent pas se contredire.
  Si ce fichier manque, le serveur pose le noindex.

## Étapes

1. Dans Railway, créer un projet, puis un service à partir du dépôt GitHub `adhumi/mots-simples`.
2. Dans les réglages du service, indiquer le fichier de configuration : `site/railway.json`.
   Laisser le dossier racine du service à la racine du dépôt : le site a besoin de `content/` et de `tools/`.
3. Ne définir aucune variable pour commencer. Lancer le déploiement.
4. Ouvrir l'adresse en `*.up.railway.app` donnée par Railway. Faire les vérifications ci-dessous.
5. Brancher le domaine, voir plus bas.

Railway passe les variables du service aux lignes `ARG` du Dockerfile.
C'est ce que dit sa documentation, section « Using variables at build time ». À confirmer au premier déploiement
en changeant `APP_STORE_ID` et en regardant le code source d'une page de mot.

## Brancher motssimples.fr

1. Dans le service Railway : Settings, Networking, Custom Domain. Ajouter `motssimples.fr`, puis `www.motssimples.fr`.
2. Railway affiche les enregistrements DNS à créer. Les recopier chez le bureau d'enregistrement du domaine.
   Pour le domaine nu, il faut un enregistrement de type ALIAS ou ANAME, ou un CNAME aplati, selon le fournisseur DNS.
3. Attendre que Railway indique que le certificat est émis.
4. Le serveur ne redirige pas `www` vers le domaine nu. Les pages portent une adresse canonique en `https://motssimples.fr`.
   Si une redirection est voulue, la faire chez le fournisseur DNS, ou me la demander.

## Vérifier le noindex une fois en ligne

```
curl -sI https://motssimples.fr/ | grep -i x-robots-tag
curl -sI https://motssimples.fr/mot/facture | grep -i x-robots-tag
curl -sI https://motssimples.fr/contenu/v1/manifest.json | grep -i -E "x-robots-tag|cache-control"
curl -s  https://motssimples.fr/mot/facture | grep -o '<meta name="robots"[^>]*>'
curl -s  https://motssimples.fr/robots.txt
```

Attendu :

- `X-Robots-Tag: noindex, nofollow` sur les trois premières lignes.
- `<meta name="robots" content="noindex, nofollow">` dans la page.
- `robots.txt` ne bloque rien. C'est voulu : un robot bloqué ne lirait pas la consigne.

Autres vérifications utiles :

```
curl -sI https://motssimples.fr/ | grep -i set-cookie          # rien ne doit sortir
curl -sI https://motssimples.fr/mot/facture.html                # 301 vers /mot/facture
curl -s  https://motssimples.fr/.well-known/apple-app-site-association
```

## Avant la publication : ce qui reste à remplacer

- `site/public/.well-known/apple-app-site-association` contient `EQUIPE_A_REMPLACER`.
  Le remplacer par l'identifiant d'équipe Apple, dix caractères, visible dans le compte développeur.
  Sans cela, les liens vers une page de mot n'ouvrent pas l'app.
- `APP_STORE_ID`, quand l'app a sa fiche.
- Les pages « Vie privée » et « Accessibilité » sont provisoires et le disent.

## Ouvrir l'indexation, au lot 5

C'est une décision d'Adrien. Il faut alors, ensemble : `MODE_CONTENU=public` et `INDEXATION=ouverte`, puis un nouveau déploiement.
Vérifier ensuite que l'en-tête `X-Robots-Tag` a disparu et que plus aucune page ne dit « Brouillon non relu ».

## En local

```
npm ci
npm run build:site                 # préversion, noindex, dans site/dist
npm start --workspace site         # http://localhost:8080
npm run dev --workspace site       # serveur de développement d'Astro

MODE_CONTENU=public npm run build:site   # le site public : fiches relues et validées seulement
npm run check:site                 # tous les contrôles automatiques
```
