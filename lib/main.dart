import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_practice/config/supabase_cofig.dart';
import 'package:supabase_practice/screens/auth/login_screen.dart';
import 'package:supabase_practice/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF0A0A0A),

        primaryColor: const Color(0xFFF7DF27),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF7DF27),
          secondary: Color(0xFFF7DF27),
          surface: Color(0xFF1A1A1A),
        ),
      ),

      home: const AuthWrapper(),
    );
  }
}

// Wrapper to check authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            return const HomeScreen();
          }
        }
        return const LoginScreen();
      },
    );
  }
}
