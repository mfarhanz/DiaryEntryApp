import 'package:dear_diary/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'view/diary_list_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  // final DiaryService diaryService;
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: AuthGate(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.dark,
            // useMaterial3: true,
            bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: const Color(0x27222B).withOpacity(0))));
  }
}

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final List<AuthProvider<AuthListener, AuthCredential>> providers = [
    EmailAuthProvider(),
    GoogleProvider(
        clientId:
            "1083430098079-ombhkcftfip8sstuq96fthcasf6rlgbs.apps.googleusercontent.com")
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text(snapshot.error.toString())),
          );
        }
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: providers,
          );
        } else {
          return DiaryListView();
        }
      },
    );
  }
}
