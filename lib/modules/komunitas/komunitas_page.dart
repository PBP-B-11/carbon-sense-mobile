import 'package:flutter/material.dart';

import '../module_intro.dart';

class KomunitasPage extends StatelessWidget {
  const KomunitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleIntro(
      icon: Icons.groups_outlined,
      title: 'Green Community',
      description: 'Berbagi tips dan berdiskusi tentang lingkungan.',
    );
  }
}
