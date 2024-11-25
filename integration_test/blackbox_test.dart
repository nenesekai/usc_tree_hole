import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/firebase_options.dart';
import 'package:usc_tree_hole/main.dart';
import 'package:usc_tree_hole/view/component/post_card.dart';

import '../test/mock.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });
  testWidgets("should be able to sign up", (tester) async {
    final auth = FirebaseAuth.instance;
    final profileProvider = FirebaseProfileProvider();
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
        find.widgetWithText(TextField, "USC Email"), "test2@usc.edu");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(
        find.widgetWithText(TextField, "Name"), "Test Account");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(find.widgetWithText(TextField, "USC ID"), "114514");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.tap(find.text("Role").last);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Undergraduate").last);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, "Password"), "114514");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(
        find.widgetWithText(TextField, "Confirm Password"), "114514");
    await tester.testTextInput.receiveAction(TextInputAction.done);

    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, "Sign Up"));

    await tester.pump(Duration(seconds: 2));

    final user = auth.currentUser;
    if (user != null) {
      await profileProvider.deleteProfile(user.uid);
      await user.delete();
    }
  });
}
