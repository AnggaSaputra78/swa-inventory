// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:swa_asset_management/main.dart';

void main() {
  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SWAAssetManagementApp());

    expect(find.text('Masuk ke Portal'), findsOneWidget);
    expect(find.text('PT Swabina Gatra'), findsOneWidget);
  });
}