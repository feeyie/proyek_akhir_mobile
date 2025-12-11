import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth/auth_gate.dart';
import 'services/notification_service.dart';

const SUPABASE_URL = 'https://eueflrmnbgbzgwwuclwa.supabase.co';
const SUPABASE_ANON_KEY =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1ZWZscm1uYmdiemd3d3VjbHdhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3NTI3MTksImV4cCI6MjA3NzMyODcxOX0.oRPQPTilCXNqxkLHni9i0Pn6OM8cxOroVSlDNwp3kYU';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('liked_destinations_box');
  await Hive.openBox('userBox');

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      home: const AuthGate(),
    );
  }
}
