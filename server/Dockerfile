# Image du point de collecte des mots demandés. À construire depuis la racine du dépôt :
#   docker build -f server/Dockerfile -t mots-simples-collecte .
# Aucune dépendance : Node suffit.
FROM node:22-alpine
WORKDIR /app
COPY server/demandes.mjs server/serveur.mjs ./
# Les compteurs sont écrits dans /donnees. Sur Railway, y monter un volume.
# Le service tourne avec l'utilisateur par défaut de l'image, pour pouvoir écrire dans le volume monté.
ENV NODE_ENV=production PORT=8080 DOSSIER_DES_DONNEES=/donnees
EXPOSE 8080
CMD ["node", "serveur.mjs"]
