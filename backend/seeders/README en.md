# Seeders Caretime

Ce dossier contient des scripts pour peupler la base de données MongoDB avec des données de test pour le projet Caretime.

## Contenu
- `user.seeder.js` : Ajoute des utilisateurs (admin, docteurs, patients)
- `availability.seeder.js` : Ajoute des créneaux de disponibilité pour chaque docteur
- `appointment.seeder.js` : Crée des rendez-vous de test entre patients et docteurs
- `index.js` : Lance tous les seeders dans l'ordre

## Prérequis
- Node.js installé
- MongoDB accessible (local ou distant)
- Fichier `.env` à la racine du dossier `backend` avec la variable :
  ```
  MONGO_URI=mongodb://localhost:27017/clinic
  ```
  (ou l'URL de ta base)

## Utilisation

1. Place-toi dans le dossier `backend` :
   ```bash
   cd backend
   ```
2. Installe les dépendances si besoin :
   ```bash
   npm install
   ```
3. Lance le seed :
   ```bash
   npm run seed
   ```

Cela va :
- Supprimer les anciennes données (utilisateurs, disponibilités, rendez-vous)
- Insérer des utilisateurs de test (admin, docteurs, patients)
- Générer des créneaux de disponibilité pour les docteurs
- Créer des rendez-vous de test

## Personnalisation

- Modifie les fichiers `user.seeder.js`, `availability.seeder.js` ou `appointment.seeder.js` pour adapter les données à tes besoins.

## Sécurité

⚠️ **Attention** : Les seeders suppriment toutes les données existantes dans les collections concernées !