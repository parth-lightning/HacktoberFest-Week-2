import 'dart:async';
import 'package:flutter/foundation.dart';

/// Telemetry record for an intercepted crash or fault.
class CrashReport {
  final String faultSignal;
  final String message;
  final String stackTrace;
  final DateTime timestamp;
  final bool isFatal;

  const CrashReport({
    required this.faultSignal,
    required this.message,
    required this.stackTrace,
    required this.timestamp,
    this.isFatal = false,
  });

  Map<String, dynamic> toMap() => {
        'signal': faultSignal,
        'message': message,
        'stackTrace': stackTrace,
        'timestamp': timestamp.toIso8601String(),
        'isFatal': isFatal,
      };
}

/// Native crash & ANR interceptor bridge mirroring:
/// - `libndk-crash.so` (`Java_com_ubercab_crash_ndk_NdkCrashBridge_initialize`)
/// - `libndk-anr.so` (`Java_com_ubercab_anr_ndk_NdkAnrBridge_initializeNative`)
class NativeCrashBridge {
  static final NativeCrashBridge _instance = NativeCrashBridge._internal();
  factory NativeCrashBridge() => _instance;
  NativeCrashBridge._internal();

  final List<CrashReport> _history = [];
  final StreamController<CrashReport> _crashStream =
      StreamController<CrashReport>.broadcast();

  Stream<CrashReport> get crashStream => _crashStream.stream;
  List<CrashReport> get history => List.unmodifiable(_history);

  /// Initializes error and unhandled signal hooks.
  void initialize() {
    // Intercept Flutter framework exceptions
    FlutterError.onError = (FlutterErrorDetails details) {
      _recordCrash(
        signal: 'SIG_FLUTTER_ERR',
        message: details.exceptionAsString(),
        stackTrace: details.stack?.toString() ?? 'No stack trace available',
        fatal: false,
      );
      FlutterError.presentError(details);
    };

    // Intercept asynchronous platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _recordCrash(
        signal: 'SIGSEGV_SIMULATED',
        message: error.toString(),
        stackTrace: stack.toString(),
        fatal: true,
      );
      return true;
    };
  }

  void _recordCrash({
    required String signal,
    required String message,
    required String stackTrace,
    required bool fatal,
  }) {
    final report = CrashReport(
      faultSignal: signal,
      message: message,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      isFatal: fatal,
    );
    _history.add(report);
    _crashStream.add(report);
    debugPrint('[NativeCrashBridge] Intercepted $signal: $message');
  }

  /// Manually forces a test crash, mirroring `NdkCrashBridge_forceNativeCrash` in `libndk-crash.so`.
  void forceTestCrash() {
    _recordCrash(
      signal: 'SIGSEGV',
      message: 'Forced native test crash (raising SIGSEGV via NdkCrashBridge)',
      stackTrace: StackTrace.current.toString(),
      fatal: true,
    );
  }

  /// Triggers a simulated ANR watchdog event, mirroring `libndk-anr.so`.
  void simulateAnrEvent() {
    _recordCrash(
      signal: 'SIGQUIT',
      message: 'Simulated ANR: UI thread unresponsive (>5000ms watchdog trigger)',
      stackTrace: StackTrace.current.toString(),
      fatal: false,
    );
  }
}
