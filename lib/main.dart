// main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // For generating UUIDs

import 'constants/app_colors.dart';
import 'constants/app_theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'services/supabase_service.dart';
import 'models/user.dart'; // Import the User model
import 'utils/app_router.dart'; // Import the AppRouter
import 'screens/auth/login_screen.dart'; // Import CurrentUser

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Replace with your actual Supabase URL and Anon Key
  const String supabaseUrl = 'https://gnjjqhchzmcwhoelugen.supabase.co';
  const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImduampxaGNoem1jd2hvZWx1Z2VuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI0MTM1MDAsImV4cCI6MjA2Nzk4OTUwMH0.U9fzz-njmirRZBGhYmdxj9gPWvIS_srS6vvBf2_5g20';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Debug prints for Supabase initialization and potential auth
  debugPrint('Supabase initialized. URL: $supabaseUrl');
  debugPrint('Supabase Anon Key: ${supabaseAnonKey.isNotEmpty ? "SET" : "NOT SET"}');
  
  final supabaseClient = Supabase.instance.client;
  final currentSupabaseUser = supabaseClient.auth.currentUser;
  debugPrint('Supabase current user ID (main.dart): ${currentSupabaseUser?.id}');

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>(
          create: (_) => SupabaseService(Supabase.instance.client),
        ),
        ChangeNotifierProvider<CurrentUser>(
          create: (_) => CurrentUser(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Reader App',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.merriweatherTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // Set the initial route for the app
      initialRoute: AppRouter.welcomeRoute,
      // Use onGenerateRoute to handle all named routes
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}