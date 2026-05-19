import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'providers/allergen_provider.dart';
import 'providers/vegan_provider.dart';
import 'providers/history_provider.dart';
import 'providers/favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, AllergenProvider>(
          create: (context) => AllergenProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, auth, previous) => previous ?? AllergenProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, VeganProvider>(
          create: (context) => VeganProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, auth, previous) => previous ?? VeganProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, HistoryProvider>(
          create: (context) => HistoryProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, auth, previous) => previous ?? HistoryProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, FavoritesProvider>(
          create: (context) => FavoritesProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, auth, previous) => previous ?? FavoritesProvider(auth),
        ),
      ],
      child: const NutriCodeApp(),
    ),
  );
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
    
    final authService = Provider.of<AuthService>(context, listen: false);
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

    await Provider.of<AllergenProvider>(context, listen: false).loadFromFirestore();
    await Provider.of<VeganProvider>(context, listen: false).loadFromFirestore();
    await Provider.of<HistoryProvider>(context, listen: false).loadFromFirestore();
    await Provider.of<FavoritesProvider>(context, listen: false).loadFromFirestore();
    
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder<User?>(
      stream: authService.userStateChanges,
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

