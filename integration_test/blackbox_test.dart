import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/firebase_options.dart';
import 'package:usc_tree_hole/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });
  // testWidgets("should be able to sign up", (tester) async {
  //   final auth = FirebaseAuth.instance;
  //   final profileProvider = FirebaseProfileProvider();
  //   await auth.signOut();

  //   await tester.pumpWidget(const MyApp());
  //   await tester.pumpAndSettle();
  //   while (!tester.any(find.text("Sign Up"))) {
  //     await tester.pumpAndSettle();
  //   }

  //   await tester.tap(find.text("Sign Up"));
  //   while (!tester.any(find.text("Create Account"))) {
  //     await tester.pumpAndSettle();
  //   }

  //   await tester.enterText(
  //       find.widgetWithText(TextField, "USC Email"), "test2@usc.edu");
  //   await tester.testTextInput.receiveAction(TextInputAction.done);
  //   await tester.enterText(
  //       find.widgetWithText(TextField, "Name"), "Test Account");
  //   await tester.testTextInput.receiveAction(TextInputAction.done);
  //   await tester.enterText(find.widgetWithText(TextField, "USC ID"), "114514");
  //   await tester.testTextInput.receiveAction(TextInputAction.done);
  //   await tester.tap(find.text("Role").last);
  //   await tester.pumpAndSettle();
  //   await tester.tap(find.text("Undergraduate").last);
  //   await tester.pumpAndSettle();
  //   await tester.enterText(
  //       find.widgetWithText(TextField, "Password"), "114514");
  //   await tester.testTextInput.receiveAction(TextInputAction.done);
  //   await tester.enterText(
  //       find.widgetWithText(TextField, "Confirm Password"), "114514");
  //   await tester.testTextInput.receiveAction(TextInputAction.done);

  //   await tester.pumpAndSettle();
  //   await tester.tap(find.widgetWithText(FilledButton, "Sign Up"));

  //   await tester.pump(Duration(seconds: 2));

  //   final user = auth.currentUser;
  //   if (user != null) {
  //     await profileProvider.deleteProfile(user.uid);
  //     await user.delete();
  //   }
  // });
  // testWidgets("should be able to sign in", (tester) async {
  //   final auth = FirebaseAuth.instance;
  //   await auth.signOut();

  //   await tester.pumpWidget(const MyApp());
  //   while (!tester.any(find.text("Sign In"))) {
  //     await tester.pumpAndSettle();
  //   }

  //   await tester.tap(find.text("Sign In"));
  //   await tester.pumpAndSettle();

  //   await tester.enterText(
  //       find.widgetWithText(TextField, "USC Email"), "test@usc.edu");
  //   await tester.testTextInput.receiveAction(TextInputAction.done);
  //   await tester.enterText(
  //       find.widgetWithText(TextField, "Password"), "114514");
  //   await tester.testTextInput.receiveAction(TextInputAction.done);
  //   await tester.tap(find.widgetWithText(FilledButton, "Sign In"));

  //   while (!tester.any(find.text("My Profile"))) {
  //     await tester.pumpAndSettle();
  //   }
  //   await tester.tap(find.text("My Profile"));
  //   await tester.pumpAndSettle();

  //   expect(find.textContaining("Test Account"), findsAny);
  // });
  // testWidgets("should be able to switch categories", (tester) async {
  //   final auth = FirebaseAuth.instance;
  //   await auth.signInWithEmailAndPassword(
  //       email: "test@usc.edu", password: "114514");

  //   await tester.pumpWidget(const MyApp());
  //   await tester.pumpAndSettle();

  //   expect(find.text("Academic", findRichText: true), findsAny);
  //   await tester.tap(find.byIcon(Icons.menu));
  //   await tester.pumpAndSettle();
  //   await tester.tap(find.text("Life", findRichText: true).first);
  //   await tester.pumpAndSettle();
  //   expect(find.text("Life", findRichText: true), findsAny);
  //   await tester.tap(find.byIcon(Icons.menu));
  //   await tester.pumpAndSettle();
  //   await tester.tap(find.text("Event", findRichText: true).first);
  //   await tester.pumpAndSettle();
  //   expect(find.text("Event", findRichText: true), findsAny);
  // });
  testWidgets("should be able to create post", (tester) async {
    final auth = FirebaseAuth.instance;
    await auth.signInWithEmailAndPassword(
        email: "test@usc.edu", password: "114514");

    await tester.pumpWidget(const MyApp());
    await tester.pump(Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FloatingActionButton, "New Post"));
    await tester.pump(Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Title"), "Test Post Title");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Content"), "Test Post Content");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, "Post").first);
    await tester.pump(Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
  testWidgets("should see the post has been created", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(
        find.textContaining("Test Post Title", findRichText: true), findsAny);
    expect(
        find.textContaining("Test Post Content", findRichText: true), findsAny);
    await tester.pump(Duration(seconds: 4));
  });
  testWidgets("should be able to view profile", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining("Test Account", findRichText: true));
    await tester.pump(Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.textContaining("Test Account", findRichText: true), findsAny);
  });
}
