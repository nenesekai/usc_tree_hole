import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:usc_tree_hole/view/page/my_profile_page.dart';
import 'package:usc_tree_hole/view/page/notifications_page.dart';
import 'package:usc_tree_hole/view/page/posts_page.dart';
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USC Tree Hole',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/signin':
            return MaterialPageRoute(builder: (context) => SignInPage());
          case '/signup':
            return MaterialPageRoute(builder: (context) => SignUpPage());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        const PostsPage(),
        const NotificationsPage(),
        const MyProfilePage(),
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
