import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkedln/screens/jobs/job_screen.dart';
import 'package:linkedln/screens/jobs/upload.dart';
import 'package:linkedln/search/profile_company.dart';
import 'package:linkedln/search/search_company.dart';
import 'package:linkedln/user_state.dart';

class BottomNavigationWidget extends StatelessWidget {
  int selectedIndex = 0;
  BottomNavigationWidget({
    required this.selectedIndex,
  });

  void logout(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(9),
                child: Icon(
                  Icons.logout,
                  size: 34,
                  color: Colors.white70,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            "Do you want logout from App?",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                auth.signOut();
                Navigator.canPop(context) ? Navigator.pop(context) : null;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserState(),
                  ),
                );
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: CurvedNavigationBar(
        color: Colors.white,
        backgroundColor: Colors.black,
        buttonBackgroundColor: Colors.white,
        height: 52,
        index: selectedIndex,
        items: const [
          Icon(
            Icons.list,
            size: 20,
            color: Colors.blue,
          ),
          Icon(
            Icons.search,
            size: 20,
            color: Colors.blue,
          ),
          Icon(
            Icons.add,
            size: 20,
            color: Colors.blue,
          ),
          Icon(
            Icons.person_pin,
            size: 20,
            color: Colors.blue,
          ),
          Icon(
            Icons.exit_to_app,
            size: 20,
            color: Colors.blue,
          ),
        ],
        animationDuration: Duration(milliseconds: 300),
        animationCurve: Curves.bounceInOut,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => JobScreen(),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AllCompaniesScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UploadJobScreen(),
              ),
            );
          } else if (index == 3) {
            final FirebaseAuth _auth = FirebaseAuth.instance;
            final User? user = _auth.currentUser;
            final String uid = _auth.currentUser!.uid;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: uid),
              ),
            );
          } else if (index == 4) {
            // Logout
            logout(context);
          }
        },
      ),
    );
  }
}
