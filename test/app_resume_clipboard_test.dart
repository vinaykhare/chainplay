import 'package:chain_activities/helpers/app_resume_clipboard.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The clipboard is never read on return from another app: on Android 12+ that
// read is silently refused after the app resumes (observed on Android 17, every
// read came back null). AppResumeClipboard therefore only waits for the user to
// come back, and these tests pin that down so a read is not reintroduced.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// What the clipboard holds right now.
  String clipboard = "";
  late Future<String?> Function() readClipboard;
  int reads = 0;

  setUp(() {
    clipboard = "";
    reads = 0;
    readClipboard = () async {
      reads++;
      return clipboard;
    };
  });

  void leaveApp() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  }

  void returnToApp() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  }

  test('a link left over from an earlier activity is never reported as new',
      () async {
    clipboard = "http://previous-activity.example/old.gif";
    final String before = await AppResumeClipboard.snapshot(readClipboard);
    expect(before, clipboard);
    reads = 0;

    final Future<AppReturn> pending = AppResumeClipboard.waitForReturn();
    leaveApp();
    returnToApp();

    final AppReturn result = await pending;
    expect(result.copied, isFalse);
    expect(result.text, isNull);
    // Nothing was read after the app came back.
    expect(reads, 0);
  });

  test('reports when the browser never opened', () async {
    final AppReturn result = await AppResumeClipboard.waitForReturn(
      launchTimeout: const Duration(milliseconds: 100),
    );

    expect(result.status, AppReturnStatus.stayed);
  });

  test('reports coming back without a clipboard check', () async {
    final Future<AppReturn> pending = AppResumeClipboard.waitForReturn();
    leaveApp();
    clipboard = "http://copied-in-browser.example/new.gif";
    returnToApp();

    final AppReturn result = await pending;
    expect(result.status, AppReturnStatus.notFound);
    expect(result.copied, isFalse);
    expect(reads, 0);
  });

  test('a refused clipboard read becomes an empty snapshot', () async {
    readClipboard = () async {
      throw PlatformException(code: "clipboard_unavailable");
    };

    expect(await AppResumeClipboard.snapshot(readClipboard), isEmpty);
  });

  test('a null clipboard read becomes an empty snapshot', () async {
    readClipboard = () async => null;

    expect(await AppResumeClipboard.snapshot(readClipboard), isEmpty);
  });
}
