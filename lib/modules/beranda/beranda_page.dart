import 'package:flutter/material.dart';

import '../module_intro.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleIntro(
      icon: Icons.eco_outlined,
      title: 'Jejak karbonmu',
      description: 'Kenali jejak karbon dari aktivitas harianmu.',
    );
  }
}
