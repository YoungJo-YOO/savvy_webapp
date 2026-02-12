import 'app_screen.dart';
import 'route_sync.dart';

class _NoopAppRouteSync implements AppRouteSync {
  @override
  void dispose() {}

  @override
  void listen(void Function(AppScreen screen) onScreenChanged) {}

  @override
  AppScreen? readInitialScreen() => null;

  @override
  void updateScreen(AppScreen screen, {bool replace = false}) {}
}

AppRouteSync createAppRouteSyncImpl() => _NoopAppRouteSync();
