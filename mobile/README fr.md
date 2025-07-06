# Caretime (Flutter Mobile)

Application mobile Flutter pour la gestion de rendez-vous médicaux (Caretime).

## Prérequis
- Flutter 3.x (https://docs.flutter.dev/get-started/install)
- Un backend Caretime fonctionnel (voir dossier backend)

## Installation

1. Clone le dépôt et place-toi dans le dossier `mobile` :
   ```bash
   cd mobile
   ```
2. Installe les dépendances :
   ```bash
   flutter pub get
   ```

## Configuration

- L'application est configurée pour pointer par défaut sur `http://localhost:5000` pour l'API backend.
- Pour tester sur un appareil physique ou un émulateur, adapte les URLs dans les fichiers `api_config.dart` si besoin (ex : remplace `localhost` par l'IP de ta machine).

## Lancer l'application

- Sur un émulateur ou un appareil connecté :
  ```bash
  flutter run
  ```

## Générer un APK (Android)

```bash
flutter build apk --release
```

## Structure du projet

- `lib/`
  - `main.dart` : Point d'entrée principal
  - `screens/` : Pages principales (admin, docteur, patient, login...)
  - `services/` : Appels API et logique métier
  - `app_theme.dart`, `app_colors.dart` : Thème et couleurs
  - `strings.dart` : Textes statiques
- `assets/` : Images et polices
- `android/`, `ios/` : Projets natifs

## Dépendances principales
- `http` : Requêtes HTTP
- `shared_preferences` : Stockage local
- `intl` : Formatage des dates

## Lien avec le backend
- L'application nécessite que le backend Caretime soit lancé et accessible.
- Les comptes de test sont générés par les seeders du backend.

## Personnalisation
- Pour changer le nom, l'icône ou le thème, modifie les fichiers dans `android/app/src/main/`, `ios/Runner/`, et `lib/`.
