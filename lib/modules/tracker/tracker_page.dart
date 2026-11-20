import 'package:flutter/material.dart';

import '../module_intro.dart';

class TrackerPage extends StatelessWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleIntro(
      icon: Icons.bar_chart,
      title: 'Carbon Tracker',
      description: 'Catat aktivitas harian dan pantau emisinya.',
    );
  }
}
