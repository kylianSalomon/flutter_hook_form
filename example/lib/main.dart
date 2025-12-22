import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

import 'messages/custom_messages.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hook Form Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      // Wrap your app with HookFormScope to provide custom error messages
      builder: (context, child) => HookFormScope(
        messages: CustomFormMessages(),
        child: child ?? const SizedBox.shrink(),
      ),
      home: const HomePage(),
    );
  }
}
