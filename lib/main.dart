import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/view/page/edit_profile_page.dart';
import 'package:usc_tree_hole/view/page/my_profile_page.dart';
import 'package:usc_tree_hole/view/page/new_post_page.dart';
import 'package:usc_tree_hole/view/page/not_signed_in_page.dart';
import 'package:usc_tree_hole/view/page/notifications_page.dart';
import 'package:usc_tree_hole/view/page/posts_page.dart';
import 'package:usc_tree_hole/view/page/profile_page.dart';
import 'package:usc_tree_hole/view/page/sign_in_page.dart';
import 'package:usc_tree_hole/view/page/sign_up_page.dart';
import 'package:usc_tree_hole/view/page/welcome_page.dart';
import 'firebase_options.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;

  runApp(MyApp(auth: auth, storage: storage, firestore: firestore));
}

class MyApp extends StatelessWidget {
  static final ThemeData _appTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
    useMaterial3: true,
  );

  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final FirebaseFirestore firestore;

  const MyApp(
      {super.key,
      required this.auth,
      required this.storage,
      required this.firestore});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USC Tree Hole',
      theme: _appTheme,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case WelcomePage.route:
            return MaterialPageRoute(builder: (context) => const WelcomePage());
          case SignInPage.route:
            return MaterialPageRoute(
                builder: (context) => SignInPage(auth: auth));
          case SignUpPage.route:
            return MaterialPageRoute(
                builder: (context) => SignUpPage(
                    firestore: firestore, storage: storage, auth: auth));
          case NewPostPage.route:
            return MaterialPageRoute(builder: (context) {
              final category = settings.arguments as PostCategory;
              return NewPostPage(
                  initialCategory: category,
                  firestore: firestore,
                  storage: storage,
                  auth: auth);
            });
          case ProfilePage.route:
            return MaterialPageRoute(builder: (context) {
              final profileId = settings.arguments as String;
              return ProfilePage(
                  profileId: profileId,
                  firestore: firestore,
                  storage: storage,
                  auth: auth);
            });
          case EditProfilePage.route:
            return MaterialPageRoute(builder: (context) {
              final profileId = settings.arguments as String;
              return EditProfilePage(
                  profileId: profileId,
                  firestore: firestore,
                  storage: storage,
                  auth: auth);
            });
          default:
            return MaterialPageRoute(
                builder: (context) => FirebaseAuth.instance.currentUser == null
                    ? const WelcomePage()
                    : HomePage(
                        user: FirebaseAuth.instance.currentUser!,
                        storage: storage,
                        firestore: firestore,
                        auth: auth));
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  static const route = '/';

  const HomePage(
      {super.key,
      required this.user,
      required this.storage,
      required this.firestore,
      required this.auth});

  final User user;
  final FirebaseStorage storage;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  static const unselectedIcons = <IconData>[
    Icons.home_outlined,
    Icons.notifications_outlined,
    Icons.person_outline
  ];
  static const selectedIcons = <IconData>[
    Icons.home,
    Icons.notifications,
    Icons.person,
  ];
  static const labels = <String>[
    'Posts',
    'Notifications',
    'My Profile',
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        PostsPage(
            firestore: widget.firestore,
            storage: widget.storage,
            auth: widget.auth),
        NotificationsPage(
            user: widget.user,
            firestore: widget.firestore,
            storage: widget.storage,
            auth: widget.auth),
        MyProfilePage(
            user: widget.user,
            firestore: widget.firestore,
            storage: widget.storage,
            auth: widget.auth),
      ][_selectedPage],
      bottomNavigationBar: NavigationBar(
        destinations: [
          for (int i = 0; i < 3; ++i)
            NavigationDestination(
              icon: Icon(HomePage.unselectedIcons[i]),
              selectedIcon: Icon(HomePage.selectedIcons[i]),
              label: HomePage.labels[i],
            )
        ],
        selectedIndex: _selectedPage,
        onDestinationSelected: (value) => setState(() => _selectedPage = value),
      ),
    );
  }
}
