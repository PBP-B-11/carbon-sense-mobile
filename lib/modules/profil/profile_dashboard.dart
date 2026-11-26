import 'package:flutter/material.dart';

const profileInk = Color(0xFF14301F);
const profilePaper = Color(0xFFFFFAF0);
const profileMuted = Color(0xFF55604F);
const profileLine = Color(0xFFDCCFB4);
const profileGreen = Color(0xFF2C7A4B);
const profileDanger = Color(0xFFA9231D);
const profileWidth = 480.0;

TextStyle profileHeading(double size, {Color color = profileInk}) => TextStyle(
  fontFamily: 'Fraunces',
  fontSize: size,
  fontWeight: FontWeight.w800,
  fontVariations: const [FontVariation('wght', 800)],
  height: 1.07,
  color: color,
);

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.child,
    this.color = profilePaper,
    this.border = profileLine,
    this.borderWidth = 1,
    this.radius = const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(28),
      bottomRight: Radius.circular(42),
      bottomLeft: Radius.circular(34),
    ),
  });

  final Widget child;
  final Color color;
  final Color border;
  final double borderWidth;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: border, width: borderWidth),
      borderRadius: radius,
    ),
    child: child,
  );
}

class ProfileSummary extends StatelessWidget {
  const ProfileSummary({super.key, required this.profile});

  final Map<String, dynamic>? profile;

  @override
  Widget build(BuildContext context) {
    final username = profile?['username'] as String?;
    final city = profile?['city_name'] as String?;
    final bio = profile?['bio'] as String?;
    final stats = profile?['challenge_stats'] as Map<String, dynamic>?;
    final joined = stats?['diikuti'] as int?;
    final completed = stats?['selesai'] as int?;
    final badges = stats?['lencana'];
    final badgeTotal = stats?['total_lencana'];
    final streak = stats?['streak'];

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFD3E86A),
                  shape: BoxShape.circle,
                  border: Border.all(color: profileInk, width: 2),
                ),
                child: ExcludeSemantics(
                  child: username == null || username.isEmpty
                      ? const Icon(Icons.person_outline, color: profileInk)
                      : Text(
                          username.characters.take(2).toString().toUpperCase(),
                          style: profileHeading(22),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username ?? 'Profil kamu', style: profileHeading(22)),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (username != null)
                          Text(
                            '@$username',
                            style: const TextStyle(color: profileMuted),
                          ),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: profileMuted,
                        ),
                        Text(
                          city == null || city.isEmpty
                              ? 'Kota belum dipilih'
                              : city,
                          style: const TextStyle(color: profileMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            username == null
                ? 'Masuk untuk melihat profil dan aktivitasmu.'
                : bio == null || bio.isEmpty
                ? 'Tambah bio untuk memperkenalkan dirimu.'
                : bio,
            style: const TextStyle(color: profileMuted, height: 1.5),
          ),
          const Divider(height: 27, color: profileLine),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value, detail) in [
                (
                  'Poin',
                  stats?['poin']?.toString() ?? '—',
                  streak == null ? null : 'Streak $streak hari',
                ),
                (
                  'Tantangan',
                  joined == null || completed == null
                      ? '—'
                      : '${joined + completed}',
                  completed == null ? null : '$completed selesai',
                ),
                (
                  'Lencana',
                  badges?.toString() ?? '—',
                  badgeTotal == null ? null : 'dari $badgeTotal',
                ),
              ])
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: profileMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: profileHeading(26),
                        textAlign: TextAlign.center,
                      ),
                      if (detail != null)
                        Text(
                          detail,
                          style: const TextStyle(
                            fontSize: 11,
                            color: profileMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileWeather extends StatelessWidget {
  const ProfileWeather({
    super.key,
    required this.city,
    required this.snapshot,
    required this.status,
    this.onRetry,
  });

  final String city;
  final Map<String, dynamic>? snapshot;
  final String status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final aqi = (snapshot?['us_aqi'] as num?)?.round();
    // US AQI categories follow the EPA AirNow index.
    final (category, tint, foreground) = switch (aqi) {
      null => (null, const Color(0xFFD6EAEF), const Color(0xFF0D5267)),
      <= 50 => ('Baik', const Color(0xFFE5F2DC), const Color(0xFF1D5A37)),
      <= 100 => ('Sedang', const Color(0xFFF9EBC8), const Color(0xFF644303)),
      <= 150 => (
        'Tidak sehat bagi kelompok sensitif',
        const Color(0xFFF7D8C4),
        const Color(0xFF743916),
      ),
      <= 200 => (
        'Tidak sehat',
        const Color(0xFFFFE6E3),
        const Color(0xFF9E2A24),
      ),
      <= 300 => (
        'Sangat tidak sehat',
        const Color(0xFFEEDCF3),
        const Color(0xFF63326A),
      ),
      _ => ('Berbahaya', const Color(0xFFF3CFCB), const Color(0xFF7A242F)),
    };
    final metrics = [
      (Icons.cloud_outlined, 'Suhu', _measure('temperature_2m', '°C')),
      (
        Icons.water_drop_outlined,
        'Kelembapan',
        _measure('relative_humidity_2m', '%'),
      ),
      (Icons.air, 'Angin', _measure('wind_speed_10m', ' km/j')),
      (null, 'US AQI', aqi?.toString() ?? '—'),
    ];

    return ProfileCard(
      color: const Color(0xFF1B6F88),
      border: profileInk,
      borderWidth: 2,
      radius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(50),
        bottomRight: Radius.circular(36),
        bottomLeft: Radius.circular(42),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: Semantics(
              header: true,
              child: Text(
                'Cuaca dan udara di ${city.isEmpty ? 'kotamu' : city}',
                style: profileHeading(23, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Sumber Open-Meteo',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 14),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var column = 0; column < 2; column++) ...[
                    if (column > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _WeatherMetric(
                        icon: metrics[row * 2 + column].$1,
                        label: metrics[row * 2 + column].$2,
                        value: metrics[row * 2 + column].$3,
                        category: row == 1 && column == 1 ? category : null,
                        tint: tint,
                        foreground: foreground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: aqi != null && aqi > 50 && aqi <= 100
                    ? const Color(0xFFF0AE33)
                    : foreground.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: foreground, size: 19),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category != null)
                        Text(
                          'Kualitas udara ${category.toLowerCase()}',
                          style: TextStyle(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      Text(
                        category == null
                            ? status
                            : 'Estimasi model Open-Meteo dan CAMS.',
                        style: TextStyle(color: foreground, fontSize: 13),
                      ),
                      if (onRetry != null)
                        TextButton(
                          onPressed: onRetry,
                          child: const Text('Muat ulang'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _measure(String key, String unit) {
    final value = snapshot?[key] as num?;
    return value == null ? '—' : '${value.round()}$unit';
  }
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.category,
    required this.tint,
    required this.foreground,
  });

  final IconData? icon;
  final String label;
  final String value;
  final String? category;
  final Color tint;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 105),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: profilePaper,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(14),
        topRight: Radius.circular(23),
        bottomLeft: Radius.circular(23),
        bottomRight: Radius.circular(14),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 16, color: profileMuted),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: profileMuted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: profileHeading(25)),
        if (category != null) ...[
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
