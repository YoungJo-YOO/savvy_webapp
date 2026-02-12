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

  @override
  AppScreen? readInitialScreen() {
    // Preferred: path-based route (/dashboard, /report, ...)
    final path = (html.window.location.pathname ?? '').trim();
    final normalizedPath = _normalizeRoutePath(path);
    final fromPath = _screenFromRoute(normalizedPath);
    if (fromPath != null) return fromPath;

    // Backward compatibility: hash-based route (#/dashboard)
    final hash = html.window.location.hash;
    if (hash.isNotEmpty) {
      final raw = hash.startsWith('#') ? hash.substring(1) : hash;
      final routePath = raw.split('?').first.trim();
      final normalizedHashPath = _normalizeRoutePath(routePath);
      final fromHash = _screenFromRoute(normalizedHashPath);
      if (fromHash != null) return fromHash;
    }

    return null;
  }

  @override
  void listen(void Function(AppScreen screen) onScreenChanged) {
    _listeners.add(onScreenChanged);

    _popStateSubscription ??= html.window.onPopState.listen((_) {
      final screen = readInitialScreen();
      if (screen == null) return;
      for (final listener in List<void Function(AppScreen screen)>.from(
        _listeners,
      )) {
        listener(screen);
      }
    });

    // Legacy hash URL support
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
    final nextPath = '/${_routeFromScreen(screen)}';
    final currentPath = html.window.location.pathname;
    final search = html.window.location.search;

    if (replace) {
      html.window.history.replaceState(
        null,
        html.document.title,
        '$nextPath$search',
      );
      return;
    }

    if (currentPath == nextPath) return;
    html.window.history.pushState(
      null,
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
      case '':
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
}

AppRouteSync createAppRouteSyncImpl() => _WebAppRouteSync();
