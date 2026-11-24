// 
import 'package:flutter_test/flutter_test.dart';
import 'package:watchx_project/main.dart';

void main() {
  testWidgets('WatchX app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const WatchXApp());

    expect(find.byType(WatchXApp), findsOneWidget);
  });
}
