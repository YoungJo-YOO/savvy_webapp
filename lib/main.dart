import 'package:flutter/widgets.dart';

import 'app/app_storage.dart';
import 'app/app_state.dart';
import 'app/savvy_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final query = _resolveLaunchQuery();
  final userNamespace = query['user']?.trim();
  final hasUserNamespace = userNamespace != null && userNamespace.isNotEmpty;
  final forceFreshStart = _toBool(query['fresh']);

  final appState = AppState(
    storage: AppStorage(namespace: hasUserNamespace ? userNamespace : null),
  );
  await appState.initialize(forceFreshStart: forceFreshStart);
  runApp(SavvyApp(appState: appState));
}

Map<String, String> _resolveLaunchQuery() {
  final direct = Uri.base.queryParameters;
  if (direct.isNotEmpty) return direct;

  // Support hash-based URLs like .../#/dashboard?user=alice&fresh=1
  final fragment = Uri.base.fragment;
  final queryIndex = fragment.indexOf('?');
  if (queryIndex < 0 || queryIndex >= fragment.length - 1) {
    return const <String, String>{};
  }

  try {
    return Uri.splitQueryString(fragment.substring(queryIndex + 1));
  } catch (_) {
    return const <String, String>{};
  }
}

bool _toBool(String? value) {
  switch (value?.toLowerCase()) {
    case '1':
    case 'true':
    case 'yes':
      return true;
    default:
      return false;
  }
}
