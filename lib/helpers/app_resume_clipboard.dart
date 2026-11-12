import 'dart:async';

import 'package:flutter/widgets.dart';

/// Reads the clipboard, or returns null when it holds no text or the system
/// refuses the request.
typedef ClipboardTextReader = Future<String?> Function();

/// What happened while the user was away in another app, such as a browser.
enum AppReturnStatus {
  /// The app never left the foreground: the other app did not open.
  stayed,

  /// The user came back, but nothing new is available.
  notFound,

  /// Something usable came back.
  copied,
}

/// The result of waiting for the user to come back from another app.
class AppReturn {
  const AppReturn(this.status, [this.text]);

  final AppReturnStatus status;

  final String? text;

  bool get copied => status == AppReturnStatus.copied;
}

/// Waits for the user to come back from an external app.
///
/// Deliberately does **not** read the clipboard on return. On Android 12+
/// `Clipboard.getData` issued by the app right after it resumes is refused
/// (silently: it returns null), which the app observed on Android 17 — every
/// read after the browser came back was null. The one reliable clipboard read
/// is one the user asks for, which is why the image field has an explicit
/// paste button instead. Links shared from other apps arrive through the
/// share intent (see `ChainList.sharedLink`).
class AppResumeClipboard {
  AppResumeClipboard._();

  /// Notes what is on the clipboard beforehand, for callers that want to
  /// report or compare it. A refused read returns an empty string.
  static Future<String> snapshot(ClipboardTextReader readClipboard) async {
    try {
      return await readClipboard() ?? "";
    } catch (_) {
      return "";
    }
  }

  /// Returns [AppReturnStatus.stayed] when the app never left the foreground
  /// within [launchTimeout], or [AppReturnStatus.notFound] once the user is
  /// back. Never reads the clipboard (see the class comment).
  static Future<AppReturn> waitForReturn({
    Duration launchTimeout = const Duration(seconds: 3),
    Duration resumeTimeout = const Duration(minutes: 10),
  }) async {
    final _LifecycleTracker tracker = _LifecycleTracker();
    WidgetsBinding.instance.addObserver(tracker);
    try {
      if (!await tracker.didLeaveForeground(launchTimeout)) {
        return const AppReturn(AppReturnStatus.stayed);
      }
      if (!await tracker.didResume(resumeTimeout)) {
        return const AppReturn(AppReturnStatus.stayed);
      }
      return const AppReturn(AppReturnStatus.notFound);
    } finally {
      WidgetsBinding.instance.removeObserver(tracker);
    }
  }
}

class _LifecycleTracker extends WidgetsBindingObserver {
  final Completer<void> _leftForeground = Completer<void>();
  final Completer<void> _resumed = Completer<void>();

  _LifecycleTracker() {
    final AppLifecycleState? state = WidgetsBinding.instance.lifecycleState;
    if (_isGone(state)) {
      _leftForeground.complete();
    }
    if (state == AppLifecycleState.resumed) {
      _resumed.complete();
    }
  }

  static bool _isGone(AppLifecycleState? state) =>
      state == AppLifecycleState.paused ||
      state == AppLifecycleState.hidden ||
      state == AppLifecycleState.detached;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_leftForeground.isCompleted && _isGone(state)) {
      _leftForeground.complete();
    }
    if (_leftForeground.isCompleted &&
        !_resumed.isCompleted &&
        state == AppLifecycleState.resumed) {
      _resumed.complete();
    }
  }

  Future<bool> didLeaveForeground(Duration timeout) =>
      _completedOrTimedOut(_leftForeground.future, timeout);

  Future<bool> didResume(Duration timeout) =>
      _completedOrTimedOut(_resumed.future, timeout);

  static Future<bool> _completedOrTimedOut(
    Future<void> future,
    Duration timeout,
  ) async {
    try {
      await future.timeout(timeout);
      return true;
    } on TimeoutException {
      return false;
    }
  }
}
