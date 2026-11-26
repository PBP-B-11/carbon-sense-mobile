import 'package:carbon_sense_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Bottom navigation opens each module', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Jejak karbonmu'), findsOneWidget);

    const destinations = [
      ('Tracker', 'Carbon Tracker'),
      ('Profil', 'Profil dan'),
      ('Challenges', 'Eco-Challenges'),
      ('Komunitas', 'Green Community'),
      ('Beranda', 'Jejak karbonmu'),
    ];
    for (final (tab, title) in destinations) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
    }
  });
}
