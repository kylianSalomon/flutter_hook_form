import 'package:flutter/material.dart';

import 'profile_page.dart';
import 'registration_page.dart';
import 'sign_in_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Hook Form Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleCard(
            title: 'Sign In Form',
            description: 'Basic form with email and password validation',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignInPage()),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: 'Registration Form',
            description:
                'Advanced form with multiple field types: text, dropdown, checkbox, date picker',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegistrationPage()),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: 'Profile Form',
            description:
                'Form using useFormContext for nested widgets and custom validation',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
