import 'package:flutter/material.dart';

class ModuleIntro extends StatelessWidget {
  const ModuleIntro({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(48),
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFD3E86A),
                  foregroundColor: theme.colorScheme.onSurface,
                  child: Icon(icon),
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(description, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
