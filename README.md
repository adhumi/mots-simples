# Mots simples

Un dictionnaire gratuit qui explique les mots compliqués avec des phrases simples, une image et une voix.

- Une app iOS native, qui fonctionne hors ligne.
- Un site, [motssimples.fr](https://motssimples.fr), où chaque mot a sa page.

Le dictionnaire est conçu d'abord pour les adultes avec un handicap intellectuel.
Il est gratuit, sans publicité, sans compte et sans traceur.

**État du projet : en construction.** Les fiches présentes sont des brouillons, pas encore relus ni validés.

## Comment une fiche est écrite

1. Un brouillon est rédigé à partir d'une source officielle, en suivant `prompts/generer-fiche.md`.
2. Un script contrôle la forme : phrases courtes, champs obligatoires, mot non répété.
3. Une personne relit le fond contre la source. La fiche devient « relue ».
4. Des personnes concernées la lisent ou l'écoutent en séance. Si elle est comprise, elle devient « validée ».

Seules les fiches validées peuvent se dire « faciles à lire et à comprendre ».

## Développer

```
npm ci
npm run ci
```

Voir `CLAUDE.md` pour la structure du dépôt et les règles du projet.

## Intégration continue

GitHub Actions lance deux séries de contrôles sur chaque demande de fusion et sur `main` :

- `.github/workflows/ci.yml` : `npm run ci`, sous Linux. Fiches, outils, paquet de contenu, site, point de collecte.
- `.github/workflows/ios.yml` : sur macOS, `swift test` pour `DictionaryCore`, puis la compilation de l'app
  et ses tests d'interface dans le simulateur. Elle ne tourne que si `ios/`, `content/` ou `tools/` changent.
  L'audit d'accessibilité automatique d'Apple y est désactivé : voir `ios/MotsSimplesUITests/Audit.swift`.

## Licences

- Code : MIT, voir `LICENSE`.
- Contenu : Creative Commons BY-NC-SA 4.0, voir `LICENSE-CONTENT.md`.
- Pictogrammes : ARASAAC, auteur Sergio Palao, propriété du Gouvernement d'Aragon, licence BY-NC-SA.
