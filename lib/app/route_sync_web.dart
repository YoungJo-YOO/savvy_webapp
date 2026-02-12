// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'app_screen.dart';
import 'route_sync.dart';

class _WebAppRouteSync implements AppRouteSync {
  final List<void Function(AppScreen screen)> _listeners =
      <void Function(AppScreen screen)>[];
  StreamSubscription<html.Event>? _hashSubscription;

  @override
  AppScreen? readInitialScreen() {
    final hash = html.window.location.hash;
    if (hash.isEmpty) return null;

    final raw = hash.startsWith('#') ? hash.substring(1) : hash;
    final routePath = raw.split('?').first.trim();
    final normalized = routePath.startsWith('/')
        ? routePath.substring(1)
        : routePath;
    if (normalized.isEmpty) return null;

    return _screenFromRoute(normalized);
  }

  @override
  void listen(void Function(AppScreen screen) onScreenChanged) {
    _listeners.add(onScreenChanged);

    _hashSubscription ??= html.window.onHashChange.listen((_) {
      final screen = readInitialScreen();
      if (screen == null) return;
      for (final listener in List<void Function(AppScreen screen)>.from(
        _listeners,
      )) {
        listener(screen);
      }
    });
  }

  @override
  void updateScreen(AppScreen screen, {bool replace = false}) {
    final nextHash = '#/${_routeFromScreen(screen)}';
    if (html.window.location.hash == nextHash) return;

    if (replace) {
      final path = html.window.location.pathname;
      final search = html.window.location.search;
      html.window.history.replaceState(
        null,
        html.document.title,
        '$path$search$nextHash',
      );
      return;
    }

    html.window.location.hash = '/${_routeFromScreen(screen)}';
  }

  @override
  void dispose() {
    _hashSubscription?.cancel();
    _hashSubscription = null;
    _listeners.clear();
  }

  AppScreen? _screenFromRoute(String route) {
    switch (route) {
      case 'landing':
        return AppScreen.landing;
      case 'onboarding':
        return AppScreen.onboarding;
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
      case AppScreen.onboarding:
        return 'onboarding';
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
}

AppRouteSync createAppRouteSyncImpl() => _WebAppRouteSync();
