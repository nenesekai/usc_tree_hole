import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/view/page/new_post_page.dart';
import 'package:usc_tree_hole/view/page/not_signed_in_page.dart';
import 'package:usc_tree_hole/view/page/notifications_page.dart';
import 'package:usc_tree_hole/view/page/posts_page.dart';
import 'package:usc_tree_hole/view/page/profile_page.dart';
import 'package:usc_tree_hole/view/page/sign_in_page.dart';
import 'package:usc_tree_hole/view/page/sign_up_page.dart';
import 'firebase_options.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final ThemeData _appTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
    useMaterial3: true,
  );

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USC Tree Hole',
      theme: _appTheme,
      home: const HomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SignInPage.route:
            return MaterialPageRoute(builder: (context) => const SignInPage());
          case SignUpPage.route:
            return MaterialPageRoute(builder: (context) => const SignUpPage());
          case NewPostPage.route:
            return MaterialPageRoute(builder: (context) {
              final category = settings.arguments as PostCategory;
              return NewPostPage(initialCategory: category);
            });
          case ProfilePage.route:
            return MaterialPageRoute(builder: (context) {
              final userId = settings.arguments as String?;
              return ProfilePage(userId: userId!);
            });
          default:
            return MaterialPageRoute(builder: (context) => const HomePage());
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  final Stream<User?> _userStream = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _userStream,
        initialData: FirebaseAuth.instance.currentUser,
        builder: (context, snapshot) {
          final user = snapshot.data;
          return Scaffold(
            body: <Widget>[
              const PostsPage(),
              const NotificationsPage(),
              user == null
                  ? const NotSignedInPage()
                  : ProfilePage(userId: user.uid),
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
              onDestinationSelected: (value) =>
                  setState(() => _selectedPage = value),
            ),
          );
        });
  }
}
