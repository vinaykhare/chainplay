import 'package:chain_activities/helpers/app_resume_clipboard.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression: the clipboard used to be read right after launchUrl returned,
// i.e. while the app was still going to the background, so it picked up the
// link copied for a previous activity instead of the one copied in the
// browser for the current activity.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String clipboard = "";

  // Installed per test: the mock channel is bound to the messenger of the
  // binding that existed when it was set, so it must be refreshed once the
  // test binding is the current one.
  void mockClipboard() {
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': clipboard};
      }
      return null;
    });
  }

  setUp(() {
    clipboard = "";
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
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

  bool isHttpLink(String text) => text.startsWith("http");

  test('ignores a link left in the clipboard from an earlier activity',
      () async {
    mockClipboard();
    clipboard = "http://previous-activity.example/old.gif";

    final Future<String?> pending =
        AppResumeClipboard.readAfterBrowserReturn(
      isHttpLink,
      previous: "http://previous-activity.example/old.gif",
    );
    leaveApp();
    // User does not copy anything new in the browser and comes back.
    returnToApp();

    expect(await pending, isNull);
  });

  test('returns the link copied while the browser was open', () async {
    mockClipboard();
    clipboard = "";

    final Future<String?> pending =
        AppResumeClipboard.readAfterBrowserReturn(isHttpLink);
    leaveApp();
    clipboard = "http://copied-in-browser.example/new.gif";
    returnToApp();

    expect(await pending, "http://copied-in-browser.example/new.gif");
  });

  test('rejects text that is not a link', () async {
    mockClipboard();
    clipboard = "just some text copied in the browser";

    final Future<String?> pending =
        AppResumeClipboard.readAfterBrowserReturn(isHttpLink);
    leaveApp();
    returnToApp();

    expect(await pending, isNull);
  });

  test('the caller can exclude the value already in the field', () async {
    mockClipboard();
    clipboard = "http://editing.example/current.gif";

    final Future<String?> pending =
        AppResumeClipboard.readAfterBrowserReturn(
      isHttpLink,
      previous: "http://editing.example/current.gif",
    );
    leaveApp();
    returnToApp();

    expect(await pending, isNull);
  });

  test('a new link is accepted even after an excluded value', () async {
    mockClipboard();
    clipboard = "http://editing.example/current.gif";

    final Future<String?> pending =
        AppResumeClipboard.readAfterBrowserReturn(
      isHttpLink,
      previous: "http://editing.example/current.gif",
    );
    leaveApp();
    clipboard = "http://edited.example/new.gif";
    returnToApp();

    expect(await pending, "http://edited.example/new.gif");
  });

  test('gives up if the app never leaves the foreground', () async {
    mockClipboard();
    clipboard = "http://previous.example/old.gif";

    final String? result = await AppResumeClipboard.readAfterBrowserReturn(
      isHttpLink,
      launchTimeout: const Duration(milliseconds: 100),
    );

    expect(result, isNull);
  });
}
