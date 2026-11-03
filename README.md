# PromptGo — Admin and User Flutter Apps

Two separate Android apps sharing Firebase Realtime Database:
- PromptGo Admin: Firebase email/password sign-in; create, edit, and delete prompts (title, category, content).
- PromptGo User: browse, search, filter by category, copy prompts, and save favorites locally on the device.
- Both apps use system light/dark appearance automatically and include a branded splash screen.

## Firebase setup
1. Enable Authentication > Sign-in method > Email/Password.
2. Create the administrator account manually in Authentication > Users. There is no public admin registration.
3. Import database.rules.json into Realtime Database > Rules. These are test rules: reads are public and any authenticated user can write. For production, restrict writes to the administrator UID/custom claim.
4. The supplied Firebase Android appId is currently reused as a test configuration. For production, register separate Android apps with package IDs com.safisafi.promptgo.promptgo_admin and com.safisafi.promptgo.promptgo_user, then configure each app with its own Firebase options / google-services file.

## Build
Run GitHub Actions > Build PromptGo Admin and User APKs manually. It uploads separate Admin and User APK artifacts plus a ZIP containing both.
