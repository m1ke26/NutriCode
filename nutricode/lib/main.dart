import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'providers/allergen_provider.dart';
import 'providers/vegan_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NutriCodeApp());
}

class NutriCodeApp extends StatelessWidget {
  const NutriCodeApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCode',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = false;
  bool _initialized = false;

  void _toggleView() {
    setState(() => _showLogin = !_showLogin);
  }

  Future<void> _initializeUserData() async {
    if (_initialized) return;
    
    final authService = AuthService();
    final userData = await authService.getUserData();
    
    if (userData == null) {
      // User is authenticated in Firebase Auth but missing from Firestore
      // (e.g. manually deleted or sync error). Force sign out.
      await authService.signOut();
      if (mounted) {
        setState(() {
          _initialized = false;
        });
      }
      return;
    }

    await AllergenProvider.instance.loadFromFirestore();
    await VeganProvider.instance.loadFromFirestore();
    
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          if (!_initialized) {
            _initializeUserData();
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const HomeScreen();
        }

        // Unauthenticated flow
        _initialized = false; // Reset for next login
        if (_showLogin) {
          return LoginScreen(onBack: _toggleView);
        }
        return WelcomeScreen(onGetStarted: _toggleView);
      },
    );
  }
}

