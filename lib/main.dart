import 'package:flutter/widgets.dart';

import 'app/app_storage.dart';
import 'app/app_state.dart';
import 'app/savvy_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userNamespace = Uri.base.queryParameters['user'];
  final fresh = switch (Uri.base.queryParameters['fresh']) {
    '1' || 'true' || 'yes' => true,
    _ => false,
  };

  final appState = AppState(storage: AppStorage(namespace: userNamespace));
  await appState.initialize(forceFreshStart: fresh);
  runApp(SavvyApp(appState: appState));
}
