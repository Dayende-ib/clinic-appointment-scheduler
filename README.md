# CareTime – Gestionnaire de Rendez-vous en Clinique

CareTime est une application complète de gestion de rendez-vous médicaux, conçue pour faciliter la prise de rendez-vous entre patients, médecins et administrateurs. Elle propose une interface mobile moderne (Flutter) et une API backend robuste (Node.js/Express/MongoDB).

## Fonctionnalités principales

- **Authentification sécurisée** pour les patients, médecins et administrateurs
- **Gestion des rendez-vous** : prise, modification, annulation et consultation
- **Gestion des disponibilités des médecins**
- **Tableau de bord personnalisé** selon le rôle (patient, médecin, admin)
- **Rappels**
- **Interface mobile intuitive** (Flutter)
- **API RESTful** pour la communication entre le mobile et le backend

## Structure du projet

```
clinic-appointment-scheduler/
  ├── backend/         # API Node.js/Express/MongoDB, modèles, contrôleurs, routes
  ├── mobile/          # Application mobile Flutter (Android/iOS)
  ├── documentation/   # Diagrammes, ressources, docs techniques
  ├── postman/         # Collections pour tester l'API
  ├── presentation/    # Présentations, slides, etc.
  └── README.md        # Ce fichier
```

## Installation

### Backend

1. Accédez au dossier `backend/`
2. Installez les dépendances :
   ```bash
   npm install
   ```
3. Configurez les variables d'environnement (exemple : `.env`)
4. Lancez le serveur :
   ```bash
   npm start
   ```

### Mobile

1. Accédez au dossier `mobile/`
2. Installez les dépendances :
   ```bash
   flutter pub get
   ```
3. Lancez l'application sur un émulateur ou un appareil :
   ```bash
   flutter run
   ```

## Technologies utilisées

- **Backend** : Node.js, Express, MongoDB
- **Mobile** : Flutter (Dart)
- **Authentification** : JWT, SharedPreferences (mobile)
- **Gestion d'état** : setState, Provider (selon les écrans)
- **Autres** : Postman, Git

## Auteurs (Groupe 04)

- **GUISSOU Ali**
- **MADIEGA Aida**
- **OUGDA Ibrahim** (o.ibrahimdayende@gmail.com)

## Licence

Ce projet est sous licence MIT.
