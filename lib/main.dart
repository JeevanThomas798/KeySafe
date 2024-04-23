import 'package:keysafe/constants.dart';
import 'package:keysafe/home/home.dart';
import 'package:keysafe/services/rtdb_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: defaultPropertyBackgroundColour,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const AuthWidget(),
    );
  }
}

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  RealtimeDatabaseService realtimeDatabaseService = RealtimeDatabaseService();
  int segmentedControlGroupValue = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return  const PasswordManagerPage();
        }
        return SignInScreen(
          subtitleBuilder: (context, action) {
            final actionText = switch (action) {
              AuthAction.signIn => 'Please sign in to continue.',
              AuthAction.signUp => 'Please create an account to continue',
              _ => throw Exception('Invalid action: $action'),
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Welcome to KeySafe! $actionText.'),
            );
          },
          footerBuilder: (context, action) {
            final actionText = switch (action) {
              AuthAction.signIn => 'signing in',
              AuthAction.signUp => 'registering',
              _ => throw Exception('Invalid action: $action'),
            };

            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'By $actionText, you agree to our terms and conditions.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
          headerBuilder: (context, constraints, shrinkOffset) {
            return Center(
              child: Image.asset('assets/images/icon.png',
                  width: 100, height: 100),
            );
          },
          providers: [EmailAuthProvider()],
          actions: [
            AuthStateChangeAction<UserCreated>((context, state) async {
              _createUserDocument(state.credential.user!);

              if (kDebugMode) {
                print('New User Created');
              }
            }),
            AuthStateChangeAction<SignedIn>((context, state) {}),
          ],
        );
      },
    );
  }

  void _createUserDocument(User user) {
    FirebaseFirestore.instance.collection('keysafeUsers').doc(user.uid).set({
      'userId': user.uid,
      'userName': "User",
      'userEmail': user.email,
      'userRole': '',
      'userPhone': '',
      'userGender': '',
      'userAge': '',
      'userProfileImage': ''
          'https://cdn-icons-png.flaticon.com/512/666/666201.png',
      'userAddress': '',
    });
  }
}
