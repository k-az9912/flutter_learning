import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_learning/main.dart';

void main() {
  testWidgets('OCR home screen is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const OcrApp());

    expect(find.text('日本語 OCR'), findsOneWidget);
    expect(find.text('画像から文字を読み取る'), findsOneWidget);
    expect(find.text('画像を選ぶ'), findsOneWidget);
    expect(find.text('認識結果'), findsNothing);
  });
}
