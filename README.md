<h6><p align="right">Created: Sept 2023</p></h6>

## Dear Diary App
This was a rather neat app made using in Flutter using Dart and FirebaseDB services, so worth putting up here.
Able to do CRUD operations for diary entries, including adding images. Currently needs a splash page a better icon, maybe include recordings in entries

### Prerequisites
- Flutter (run `flutter doctor` to see all necessary prereqs)
- Android SDK Manager/Toolchain
- Android Studio or VSCode for emulating (optional)
- npm (node package manager) or Node.js
- Run `npm install -g firebase-tools` to install FirebaseCLI
- Run `dart pub global activate flutterfire_cli` to install FlutterfireCLI


### Execution
- Create a new flutter project in a folder named 'dear_diary' using `flutter create dear_diary` or whatever you want to the app name to be
- Replace files in `lib` and `fonts` with the ones given here
- Replace `pubspec.yaml` with the one given here
- Run `flutter pub get` in the project directory
- Resolve any errors
- If no issues, run `flutter build apk --release`
- Emulate app with Chrome or default emulator in VSCode or Android Studion using `flutter run` or run app directly on connected mobile device
- Optional: Install app on connected phone for immediate execution using `flutter install`
