import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:servi_sur/core/firebase/firebase_options.dart';
import 'package:servi_sur/shared/data/repositories/firebase_marketplace_repository.dart';

Future<void> main(List<String> args) async {
  final overwrite = args.contains('--overwrite');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  final repository = FirebaseMarketplaceRepository(loadOnCreate: false);
  final written = await repository.seedFromFallback(overwrite: overwrite);

  stdout.writeln('Seed Firestore completado. Documentos escritos: $written.');
  if (written == 0) {
    stdout.writeln(
      'No se escribio nada porque los documentos ya existen. Usa --overwrite para reemplazarlos.',
    );
  }
}
