import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Opt-in metadata only. Never log bodies, headers, query values or error text.
class NetworkDiagnostics {
  NetworkDiagnostics({
    this.enabled = const bool.fromEnvironment('NETWORK_DIAGNOSTICS'),
    void Function(String)? sink,
  }) : _sink = sink ?? debugPrint;

  final bool enabled;
  final void Function(String) _sink;
  final Expando<Stopwatch> _timers = Expando();
  final Expando<int> _ids = Expando();
  int _nextId = 0;

  void record(
    String event,
    RequestOptions options, {
    Object? error,
    int? status,
    bool? blocked,
  }) {
    if (!enabled) return;
    // Observability must not interfere with authentication or request completion.
    try {
      _timers[options] ??= Stopwatch()..start();
      _ids[options] ??= ++_nextId;
      final uri = options.uri;
      const publicSegments = {
        'api',
        'v1',
        'auth',
        'login',
        'register',
        'refresh',
        'logout',
        'apple',
        'google',
        'clients',
        'quotes',
        'contracts',
        'finance',
        'entries',
        'summary',
        'categories',
        'users',
        'me',
        'profile',
        'settings',
        'app',
        'config',
        'privacy',
        'health',
        'ready',
      };
      final route = uri.pathSegments
          .map((part) => publicSegments.contains(part) ? part : ':redacted')
          .join('/');
      final dioError = error is DioException ? error : null;
      final cause = dioError?.error ?? error;
      // Inspect locally only to classify DNS/TLS; never emit exception messages.
      final errorText = cause?.toString().toLowerCase() ?? '';
      final category = errorText.contains('failed host lookup')
          ? 'dns'
          : errorText.contains('handshake') ||
                errorText.contains('certificate_verify_failed')
          ? 'tls'
          : cause?.runtimeType.toString();
      _sink(
        '[VendAI.network] ${jsonEncode({'time': DateTime.now().toUtc().toIso8601String(), 'request': _ids[options], 'event': event, 'method': options.method, 'url': '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}/$route', 'elapsedMs': _timers[options]!.elapsedMilliseconds, 'status': status, 'dioType': dioError?.type.name, 'cause': category, 'accessTokenPresent': options.headers.entries.any((entry) => entry.key.toLowerCase() == 'authorization' && entry.value is String && (entry.value as String).isNotEmpty), if (blocked != null) 'sessionBlocked': blocked, 'retried': options.extra['retried'] == true})}',
      );
    } catch (_) {
      // A diagnostic failure must never block an application request.
    }
  }
}
