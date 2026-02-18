import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const TeknisiApp());
}

class TeknisiApp extends StatelessWidget {
  const TeknisiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teknisi AssetICT',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.getToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        return const DashboardScreen();
      },
    );
  }
}
