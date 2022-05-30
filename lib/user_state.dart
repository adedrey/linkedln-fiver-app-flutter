import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './screens/authentications/login.dart';
import './screens/jobs/job_screen.dart';

class UserState extends StatefulWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  _UserStateState createState() => _UserStateState();
}

class _UserStateState extends State<UserState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: CircularProgressIndicator(),
            ),
          );
        }
        if (userSnapshot.data == null) {
          return LoginScreen();
        }
        if (userSnapshot.hasData) {
          print("user is signed in");
          return JobScreen();
        }

        if (userSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text("An error has occured"),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: Text("Something has occured"),
          ),
        );
      },
    );
  }
}
