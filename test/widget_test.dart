import 'package:flutter_test/flutter_test.dart';
import 'package:servi_sur/app/app.dart';

void main() {
  testWidgets('shows login screen', (tester) async {
    await tester.pumpWidget(const ServiSurApp());
    await tester.pump();

    expect(find.text('BIENVENIDO'), findsOneWidget);
    expect(find.text('Iniciar Sesion'), findsOneWidget);
  });
}
