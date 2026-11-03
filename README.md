# Firebase Message Apps (Flutter)
Two independent Flutter Android apps:
- Admin: Firebase email/password login; create, edit and delete messages.
- User: live read-only list of messages.

Firebase project: pashto-poetry-new-2c4ba
Realtime Database: https://pashto-poetry-new-2c4ba-default-rtdb.firebaseio.com
Generated Android package IDs: com.safisafi.test.admin and com.safisafi.test.user.

## Firebase setup
1. Enable Authentication > Sign-in method > Email/Password.
2. Create the administrator account manually in Authentication > Users. The app has no public registration.
3. Import database.rules.json in Realtime Database > Rules. Test rules allow public reads and authenticated writes. Before production, restrict writes to the admin UID/custom claim.
4. The supplied Android appId is used for both test builds. For production, register both package IDs as separate Android apps and use each matching Firebase appId.

## Build
GitHub Actions builds separate release APK artifacts and a ZIP containing both. Open Actions > Build Admin and User APKs after a push or run it manually.
