import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Reads the clipboard only after the user comes back from an external
/// browser (see [readAfterBrowserReturn] for why).
class AppResumeClipboard {
  AppResumeClipboard._();

  static const Duration _settleTime = Duration(milliseconds: 250);
  static const int _maxAttempts = 4;

  /// Waits for the app to be backgrounded and resumed, then returns the
  /// clipboard text if [accept] accepts it and it is not [previous] (the value
  /// that was in the field before the browser opened, so a link copied for an
  /// earlier activity is not applied again).
  ///
  /// Returns null when the app never left the foreground within
  /// [launchTimeout] (the browser failed to open), never resumed within
  /// [resumeTimeout], or the clipboard holds nothing acceptable.
  ///
  /// `Clipboard.getData` is bound to the activity that issued it: a request
  /// sent while the app is paused can be rejected, and a request sent right
  /// after resuming can still be served from the clipboard view of the browser
  /// that had focus. Neither is reported, so the value is only used once two
  /// consecutive reads (0.25 s apart) agree.
  static Future<String?> readAfterBrowserReturn(
    bool Function(String clipboardText) accept, {
    String? previous,
    Duration launchTimeout = const Duration(seconds: 3),
    Duration resumeTimeout = const Duration(minutes: 10),
  }) async {
    final _LifecycleTracker tracker = _LifecycleTracker();
    WidgetsBinding.instance.addObserver(tracker);
    try {
      if (!await tracker.didLeaveForeground(launchTimeout)) {
        return null;
      }
      if (!await tracker.didResume(resumeTimeout)) {
        return null;
      }

      for (int attempt = 0; attempt < _maxAttempts; attempt++) {
        final String first = await _read();
        await Future<void>.delayed(_settleTime);
        final String second = await _read();
        if (first.isEmpty || first != second || first == previous) {
          continue;
        }
        if (accept(first)) {
          return first;
        }
      }
      return null;
    } finally {
      WidgetsBinding.instance.removeObserver(tracker);
    }
  }

  static Future<String> _read() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text?.trim() ?? "";
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
