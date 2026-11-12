# Pocketwise

A personal finance tracker built with Flutter, Firebase Authentication, and Cloud Firestore.

## Firebase setup

The app is configured for Firebase project `praktikumfirebase-92b07`. Its default Cloud Firestore database is in Jakarta (`asia-southeast2`), and the security rules are maintained in [`firestore.rules`](./firestore.rules).

Before signing in, enable **Email/Password** under Firebase Console → Authentication → Sign-in method. New users should choose **Create account** first; registration creates a Firebase Authentication account and a profile document at `users/{uid}`. Transactions are stored under `users/{uid}/transactions`.

If the Firestore rules change, deploy them with:

```bash
firebase deploy --only firestore:rules --project praktikumfirebase-92b07
```

## Run the app

```bash
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

Open the URL printed by Flutter in a browser. You can also use `flutter run -d chrome` if Chrome starts correctly on your system.

## Video Demo
[Screencast from 2026-11-13 03-38-47.webm](https://github.com/user-attachments/assets/65145718-bb07-4aea-b11d-baeda4864906)
