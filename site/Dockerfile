# Image du site motssimples.fr. À construire depuis la racine du dépôt :
#   docker build -f site/Dockerfile -t mots-simples-site .
# Le site lit ../content et ../tools : le contexte doit être tout le dépôt.

FROM node:22-alpine AS construction
WORKDIR /depot
COPY package.json package-lock.json ./
COPY site/package.json site/package.json
RUN npm ci --omit=dev --ignore-scripts
COPY content content
COPY tools tools
COPY site site

# Les deux réglages du site. Railway passe ses variables de service aux ARG du même nom.
# preversion + fermee : toutes les fiches, site en noindex. C'est le réglage jusqu'à la publication.
ARG MODE_CONTENU=preversion
ARG INDEXATION=fermee
ARG APP_STORE_ID=""
ARG ADRESSE_DES_DEMANDES=""
ENV MODE_CONTENU=$MODE_CONTENU INDEXATION=$INDEXATION APP_STORE_ID=$APP_STORE_ID ADRESSE_DES_DEMANDES=$ADRESSE_DES_DEMANDES
RUN npm run build --workspace site

FROM node:22-alpine
WORKDIR /app
COPY --from=construction /depot/site/dist ./dist
COPY site/serveur.mjs ./serveur.mjs
ARG ADRESSE_DES_DEMANDES=""
ENV NODE_ENV=production PORT=8080 ADRESSE_DES_DEMANDES=$ADRESSE_DES_DEMANDES
USER node
EXPOSE 8080
CMD ["node", "serveur.mjs"]
