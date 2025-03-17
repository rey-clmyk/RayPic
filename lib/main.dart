import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ray/auth/AuthGate.dart';
import 'package:ray/style/appcolor.dart';
import 'package:ray/style/handle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/auth/login_screen.dart';

void main() async{
  await Supabase.initialize(
    url: 'https://njqimqirisycofzubylr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qcWltcWlyaXN5Y29menVieWxyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE1NzcyMDYsImV4cCI6MjA1NzE1MzIwNn0.D1Y7Vgk3VnFtSw4SPWMJ1vk1wRdLVOk2PJB8WAdld8g',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeNotifier.themeMode,
      home: AuthGate(),
    );
  }
}
