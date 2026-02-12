import 'package:flutter/widgets.dart';

import 'app/app_state.dart';
import 'app/savvy_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.initialize();
  runApp(SavvyApp(appState: appState));
}
