import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/firebase_options.dart';
import 'package:usc_tree_hole/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.testTextInput.register();
  // setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.useFirestoreEmulator("127.0.0.1", 8080);
    FirebaseStorage.instance.useStorageEmulator("127.0.0.1", 9199);
    FirebaseAuth.instance.useAuthEmulator("127.0.0.1", 9099);
  });
  testWidgets("should be able to sign up", (tester) async {
    final auth = FirebaseAuth.instance;
    await auth.signOut();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    while (!tester.any(find.text("Sign Up"))) {
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text("Sign Up"));
    while (!tester.any(find.text("Create Account"))) {
      await tester.pumpAndSettle();
    }

    await tester.enterText(
        find.widgetWithText(TextField, "USC Email"), "test@usc.edu");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Name"), "Test Account");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, "USC ID"), "114514");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Role").last);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Undergraduate").last);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Password"), "114514");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Confirm Password"), "114514");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, "Sign Up"));
    await tester.pumpAndSettle();
  });
  testWidgets("should be able to see your user name in My Profile Tab",
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text("My Profile").first);
    await tester.pumpAndSettle();
    expect(find.textContaining("Test Account", findRichText: true), findsAny);
  });
  testWidgets("should be able to sign out", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text("My Profile").first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout).first);
    await tester.pumpAndSettle();
    expect(find.textContaining("Welcome to USC Tree Hole", findRichText: true),
        findsAny);
  });
  testWidgets("should be able to sign in", (tester) async {
    await tester.pumpWidget(const MyApp());
    while (!tester.any(find.text("Sign In"))) {
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text("Sign In"));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, "USC Email"), "test@usc.edu");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Password"), "114514");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, "Sign In"));
    await tester.pumpAndSettle();

    expect(FirebaseAuth.instance.currentUser, isNotNull);
  });
  testWidgets("should be able to switch categories", (tester) async {
    final auth = FirebaseAuth.instance;
    await auth.signInWithEmailAndPassword(
        email: "test@usc.edu", password: "114514");

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text("Academic", findRichText: true), findsAny);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Life", findRichText: true).first);
    await tester.pumpAndSettle();
    expect(find.text("Life", findRichText: true), findsAny);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Event", findRichText: true).first);
    await tester.pumpAndSettle();
    expect(find.text("Event", findRichText: true), findsAny);
  });
  testWidgets("should be able to subscribe to a category", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text("My Profile").last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect(
        (await FirebaseProfileProvider()
                .getProfileById(FirebaseAuth.instance.currentUser!.uid))!
            .subscribedCategories
            .contains("Academic"),
        isTrue);
    expect(
        (await FirebaseProfileProvider()
                .getProfileById(FirebaseAuth.instance.currentUser!.uid))!
            .subscribedCategories
            .contains("Life"),
        isTrue);
  });
  testWidgets("should be able to create post", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FloatingActionButton, "New Post"));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Title"), "Test Post Title");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Content"), "Test Post Content");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, "Post").first);
    await tester.pumpAndSettle();
    expect(
        find.textContaining("Test Post Title", findRichText: true), findsAny);
    expect(
        find.textContaining("Test Post Content", findRichText: true), findsAny);
  });
  testWidgets("should be able to create reply", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester
        .tap(find.textContaining("Test Post Title", findRichText: true).first);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Enter your reply..."),
        "test reply content");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, "OK").last);
    await tester.pumpAndSettle();

    expect(find.text("test reply content"), findsAny);
  });
  testWidgets("should be able to create reply to a reply", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester
        .tap(find.textContaining("Test Post Title", findRichText: true).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.reply).first);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Enter your reply...").last,
        "test reply to reply content");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, "Reply").first);
    await tester.pumpAndSettle();

    expect(find.text("test reply to reply content"), findsAny);
  });
  testWidgets("should be able to view profile", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester
        .tap(find.textContaining("Test Account", findRichText: true).first);
    await tester.pumpAndSettle();
    expect(find.textContaining("Test Account", findRichText: true), findsAny);
  });
  testWidgets(
      "should be able to receive notification upon new post in subscribed category",
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text("Notifications").last);
    await tester.pumpAndSettle();
    expect(
        find.textContaining("Test Post Title", findRichText: true), findsAny);
  });
  testWidgets("should be able to delete a post", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester
        .tap(find.textContaining("Test Post Title", findRichText: true).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, "Yes"));
    await tester.pumpAndSettle();
    expect(find.textContaining("Test Post Title", findRichText: true),
        findsNothing);
  });
  testWidgets("should be able to clear notifications", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text("Notifications").last);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Clear").first);
    await tester.pumpAndSettle();

    expect(find.textContaining("Test Post Title", findRichText: true),
        findsNothing);
  });
  testWidgets("should be able to unsubscribe to a category", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text("My Profile").last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect(
        (await FirebaseProfileProvider()
                .getProfileById(FirebaseAuth.instance.currentUser!.uid))!
            .subscribedCategories
            .contains("Academic"),
        isFalse);
    expect(
        (await FirebaseProfileProvider()
                .getProfileById(FirebaseAuth.instance.currentUser!.uid))!
            .subscribedCategories
            .contains("Life"),
        isFalse);
  });
  testWidgets("should be able to edit profile", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text("My Profile").last);
    await tester.pumpAndSettle();
    await tester
        .tap(find.textContaining("Edit Profile", findRichText: true).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, "USC ID"), "1919810");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, "Save"));
    await tester.pumpAndSettle();

    expect(find.textContaining("1919810", findRichText: true), findsAny);
  });
}
