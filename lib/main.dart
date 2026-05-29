import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:servi_sur/app/app.dart';
import 'package:servi_sur/core/config/url_strategy.dart';
import 'package:servi_sur/core/firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureUrlStrategy();
  runApp(const ServiSurApp());
}
