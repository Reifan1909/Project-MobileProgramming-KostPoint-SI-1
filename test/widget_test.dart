import 'package:flutter_test/flutter_test.dart';
import 'package:kostpoint/main.dart';

void main() {
  testWidgets('KostPointApp smoke test loads main navigation and katalog', (WidgetTester tester) async {
    await tester.pumpWidget(const KostPointApp());

    // Memastikan judul Kost Point muncul
    expect(find.text('Kost Point'), findsOneWidget);
    expect(find.text('Kota Padang • Mode Guest'), findsOneWidget);

    // Memastikan menu bar bawah terpisah (Katalog, Peta Lokasi, Favorit, Profil)
    expect(find.text('Katalog'), findsOneWidget);
    expect(find.text('Peta Lokasi'), findsOneWidget);
    expect(find.text('Favorit'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
