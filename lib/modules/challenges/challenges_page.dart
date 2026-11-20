import 'package:flutter/material.dart';

import '../module_intro.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleIntro(
      icon: Icons.emoji_events_outlined,
      title: 'Eco-Challenges',
      description:
          'Pilih tantangan, catat progres harian, dan kumpulkan lencana.',
    );
  }
}
