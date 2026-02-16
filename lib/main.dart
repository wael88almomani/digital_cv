import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/data/auth_service.dart';
import 'auth/presentation/login_screen.dart';
import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'cv/data/cv_repository.dart';
import 'cv/data/local_image_store.dart';
import 'firebase_options.dart';
import 'home/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  runApp(DigitalCvApp(localImageStore: LocalImageStore(prefs)));
}

class DigitalCvApp extends StatelessWidget {
  const DigitalCvApp({super.key, required this.localImageStore});

  final LocalImageStore localImageStore;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: localImageStore.prefs),
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        Provider<CvRepository>(
          create: (_) => CvRepository(FirebaseFirestore.instance),
        ),
        Provider<LocalImageStore>.value(value: localImageStore),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) return supportedLocales.first;
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
          return supportedLocales.first;
        },
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _forcedSignOut = false;
  bool _initialCheckDone = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthService>().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final prefs = context.read<SharedPreferences>();
        final rememberMe = prefs.getBool(AppStrings.rememberMeKey) ?? true;

        if (!_initialCheckDone) {
          _initialCheckDone = true;
          if (snapshot.hasData && !rememberMe) {
            if (!_forcedSignOut) {
              _forcedSignOut = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<AuthService>().signOut();
                }
              });
            }
            return const LoginScreen();
          }
        }

        _forcedSignOut = false;
        return snapshot.hasData ? const MainScreen() : const LoginScreen();
      },
    );
  }
}
