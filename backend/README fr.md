# Backend Caretime

Ce dossier contient l'API backend du projet Caretime (Node.js + Express + MongoDB).

## Prérequis
- Node.js >= 16
- MongoDB (local ou distant)

## Installation

1. Clone le dépôt et place-toi dans le dossier `backend` :
   ```bash
   cd backend
   ```
2. Installe les dépendances :
   ```bash
   npm install
   ```
3. Crée un fichier `.env` à la racine du dossier `backend` avec le contenu suivant :
   ```env
   MONGO_URI=mongodb://localhost:27017/clinic
   JWT_SECRET=supersecretkey
   PORT=5000
   ```
   - Adapte `MONGO_URI` à ta configuration MongoDB.
   - `JWT_SECRET` : clé secrète pour les tokens JWT.
   - `PORT` : port d'écoute du serveur (optionnel, 5000 par défaut).

## Lancer le serveur

- En mode production :
  ```bash
  npm start
  ```
- En mode développement (avec rechargement auto) :
  ```bash
  npm run dev
  ```

Le serveur sera accessible sur `http://localhost:5000` (ou le port défini).

## Seeders (données de test)

Pour peupler la base avec des données de test (utilisateurs, disponibilités, rendez-vous) :

```bash
npm run seed
```

> ⚠️ **Attention** : Cette commande supprime toutes les données existantes dans les collections concernées !

Voir [seeders/README.md](./seeders/README.md) pour plus de détails.

## Structure des dossiers

- `controllers/` : Logique métier des routes (users, appointments, admin...)
- `models/` : Schémas Mongoose (User, Appointment, Availability)
- `routes/` : Définition des routes Express
- `middlewares/` : Middlewares (authentification, etc.)
- `seeders/` : Scripts pour peupler la base de données
- `server.js` : Point d'entrée principal du serveur

## Scripts disponibles

- `npm start` : Lancer le serveur
- `npm run dev` : Lancer le serveur en mode développement (nodemon)
- `npm run seed` : Exécuter les seeders (données de test)

## API REST

Les routes principales sont accessibles sous `/api/` :
- `/api/users` : Auth, gestion utilisateurs
- `/api/appointments` : Rendez-vous (patients, docteurs)
- `/api/availability` : Disponibilités des docteurs
- `/api/admin` : Fonctions d'administration (stats, gestion globale)

> Voir le code source pour le détail des endpoints et des paramètres.