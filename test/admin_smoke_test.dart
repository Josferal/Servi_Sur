import 'package:flutter_test/flutter_test.dart';
import 'package:servi_sur/main.dart';
import 'package:servi_sur/routes/app_router.dart';

void main() {
  testWidgets('admin dashboard renders', (tester) async {
    AppRouter.router.go('/admin');
    await tester.pumpWidget(const ServiSurApp());
    await tester.pumpAndSettle();

    expect(find.text('Panel de Control'), findsOneWidget);
  });
}
