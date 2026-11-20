import 'package:flutter/material.dart';

import '../module_intro.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleIntro(
      icon: Icons.person_outline,
      title: 'Profil & Udara',
      description: 'Kelola akun dan pantau kualitas udara di kotamu.',
    );
  }
}
