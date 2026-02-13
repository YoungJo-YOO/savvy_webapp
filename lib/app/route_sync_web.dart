// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'app_screen.dart';
import 'route_sync.dart';

class _WebAppRouteSync implements AppRouteSync {
  final List<void Function(AppScreen screen)> _listeners =
      <void Function(AppScreen screen)>[];

  StreamSubscription<html.PopStateEvent>? _popStateSubscription;
  StreamSubscription<html.Event>? _hashSubscription;

  // ✅ 브라우저 뒤/앞 이동(popstate, hashchange)으로 들어온 화면 전환 중에는
  //    pushState/replaceState를 금지해서 forward stack이 잘리는 문제를 막는다.
  bool _isFromBrowserNavigation = false;

  @override
  AppScreen? readInitialScreen() {
    final fromState = _screenFromHistoryState(html.window.history.state);
    if (fromState != null) return fromState;

    // Backward compatibility first: hash-based route (#/dashboard).
    // This keeps old mixed URLs like /landing#/dashboard working in history.
    final hash = html.window.location.hash;
    if (hash.isNotEmpty) {
      final raw = hash.startsWith('#') ? hash.substring(1) : hash;
      final routePath = raw.split('?').first.trim();
      final normalizedHashPath = _normalizeRoutePath(routePath);
      final fromHash = _screenFromRoute(normalizedHashPath);
      if (fromHash != null) return fromHash;
    }

    // Path-based route (/dashboard, /report, ...)
    final path = (html.window.location.pathname ?? '').trim();
    final normalizedPath = _normalizeRoutePath(path);
    if (normalizedPath.isNotEmpty) {
      final fromPath = _screenFromRoute(normalizedPath);
      if (fromPath != null) return fromPath;
    }

    if (normalizedPath.isEmpty) {
      return AppScreen.landing;
    }

    return null;
  }

  @override
  void listen(void Function(AppScreen screen) onScreenChanged) {
    _listeners.add(onScreenChanged);

    _popStateSubscription ??= html.window.onPopState.listen((event) {
      _isFromBrowserNavigation = true;
      try {
        final screen =
            _screenFromHistoryState(event.state) ?? readInitialScreen();
        if (screen == null) return;

        for (final listener in List<void Function(AppScreen screen)>.from(
          _listeners,
        )) {
          listener(screen);
        }
      } finally {
        _isFromBrowserNavigation = false;
      }
    });

    // Legacy hash URL support
    _hashSubscription ??= html.window.onHashChange.listen((_) {
      _isFromBrowserNavigation = true;
      try {
        final screen = readInitialScreen();
        if (screen == null) return;

        for (final listener in List<void Function(AppScreen screen)>.from(
          _listeners,
        )) {
          listener(screen);
        }
      } finally {
        _isFromBrowserNavigation = false;
      }
    });
  }

  @override
  void updateScreen(AppScreen screen, {bool replace = false}) {
    if (_isFromBrowserNavigation) return;

    final nextPath = '/${_routeFromScreen(screen)}';
    final currentPath = html.window.location.pathname;
    final search = html.window.location.search;
    final historyState = <String, String>{'screen': screen.name};

    if (replace) {
      html.window.history.replaceState(
        historyState,
        html.document.title,
        '$nextPath$search',
      );
      return;
    }

    if (currentPath == nextPath) return;

    html.window.history.pushState(
      historyState,
      html.document.title,
      '$nextPath$search',
    );
  }

  @override
  void dispose() {
    _popStateSubscription?.cancel();
    _popStateSubscription = null;

    _hashSubscription?.cancel();
    _hashSubscription = null;

    _listeners.clear();
  }

  AppScreen? _screenFromRoute(String route) {
    switch (route) {
      case 'landing':
        return AppScreen.landing;

      case 'onboarding/1':
      case 'onboarding':
        return AppScreen.onboardingStep1;

      case 'onboarding/2':
        return AppScreen.onboardingStep2;

      case 'onboarding/3':
        return AppScreen.onboardingStep3;

      case 'dashboard':
        return AppScreen.dashboard;

      case 'card-analysis':
        return AppScreen.cardAnalysis;

      case 'report':
        return AppScreen.report;

      case 'my-page':
        return AppScreen.myPage;

      default:
        return null;
    }
  }

  String _routeFromScreen(AppScreen screen) {
    switch (screen) {
      case AppScreen.landing:
        return 'landing';

      case AppScreen.onboardingStep1:
        return 'onboarding/1';

      case AppScreen.onboardingStep2:
        return 'onboarding/2';

      case AppScreen.onboardingStep3:
        return 'onboarding/3';

      case AppScreen.dashboard:
        return 'dashboard';

      case AppScreen.cardAnalysis:
        return 'card-analysis';

      case AppScreen.report:
        return 'report';

      case AppScreen.myPage:
        return 'my-page';
    }
  }

  String _normalizeRoutePath(String rawPath) {
    if (rawPath.isEmpty) return '';

    var path = rawPath.split('?').first.trim();

    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }

  AppScreen? _screenFromHistoryState(Object? state) {
    if (state is Map) {
      final screenName = state['screen'];
      if (screenName is String) {
        return _screenFromName(screenName);
      }
      return null;
    }

    if (state is String) {
      return _screenFromName(state);
    }

    return null;
  }

  AppScreen? _screenFromName(String? name) {
    if (name == null || name.isEmpty) return null;

    for (final screen in AppScreen.values) {
      if (screen.name == name) return screen;
    }
    return null;
  }
}

AppRouteSync createAppRouteSyncImpl() => _WebAppRouteSync();
