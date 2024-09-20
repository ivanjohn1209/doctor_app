import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/client_page.dart';
import 'pages/doctor_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized before use
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // Ensure this is the root widget
      routes: {
        '/client': (context) => AuthGuard(child: ClientPage()),
        '/doctor': (context) => AuthGuard(child: DoctorPage()),
        '/signup': (context) => SignupPage(),
        '/login': (context) => LoginPage(),
        // Add any additional routes here
      },
    );
  }
}

// InheritedWidget for providing user data
class UserDataProvider extends InheritedWidget {
  final Map<String, dynamic>? userData;

  UserDataProvider({Key? key, required Widget child, this.userData})
      : super(key: key, child: child);

  static UserDataProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserDataProvider>();
  }

  @override
  bool updateShouldNotify(UserDataProvider oldWidget) {
    return userData != oldWidget.userData;
  }
}

// AuthWrapper checks if the user is logged in and retrieves user type from Firestore
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // Fetch user type and navigate accordingly
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('accounts')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasData) {
                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return LoginPage();
                }

                String userType = userData['type'] ??
                    'Unknown'; // Default to 'Unknown' if 'type' is null

                print('User Data in AuthWrapper: $userData');

                return UserDataProvider(
                  userData: userData,
                  child: userType == 'Client'
                      ? ClientPage()
                      : userType == 'Doctor'
                          ? DoctorPage()
                          : Center(child: Text('Unknown user type')),
                );
              } else {
                return LoginPage();
              }
            },
          );
        } else {
          return LoginPage();
        }
      },
    );
  }
}

// AuthGuard ensures that the user is authenticated before accessing certain pages
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // Fetch user type and navigate accordingly
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('accounts')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasData) {
                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return LoginPage();
                }

                String userType = userData['type'] ??
                    'Unknown'; // Default to 'Unknown' if 'type' is null

                print('User Data in AuthWrapper: $userData');

                return UserDataProvider(
                  userData: userData,
                  child: child,
                );
              } else {
                return LoginPage();
              }
            },
          );
        } else {
          // Redirect to login page if not authenticated
          Future.microtask(
              () => Navigator.pushReplacementNamed(context, '/login'));
          return SizedBox.shrink();
        }
      },
    );
  }
}
