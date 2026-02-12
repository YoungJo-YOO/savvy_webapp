import 'app_screen.dart';
import 'route_sync_stub.dart'
    if (dart.library.html) 'route_sync_web.dart';

abstract class AppRouteSync {
  AppScreen? readInitialScreen();

  void listen(void Function(AppScreen screen) onScreenChanged);

  void updateScreen(AppScreen screen, {bool replace = false});

  void dispose();
}

AppRouteSync createAppRouteSync() => createAppRouteSyncImpl();
