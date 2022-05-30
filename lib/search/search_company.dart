import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linkedln/widgets/all_companies.dart';
import 'package:linkedln/widgets/bottom_navbar.dart';

class AllCompaniesScreen extends StatefulWidget {
  @override
  _AllCompaniesScreenState createState() => _AllCompaniesScreenState();
}

class _AllCompaniesScreenState extends State<AllCompaniesScreen> {
  TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = "Search Query";

  Widget _buildSearchField() {
    return TextField(
        controller: _searchQueryController,
        autocorrect: true,
        decoration: const InputDecoration(
          hintText: "Search for companies...",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white38),
        ),
        style: TextStyle(color: Colors.white, fontSize: 16),
        onChanged: (query) {
          updateSearchQuery(query);
        });
  }

  List<Widget> _buildActions() {
    return <Widget>[
      IconButton(
        onPressed: _clearSearchQuery,
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationWidget(selectedIndex: 1),
      appBar: AppBar(
        backgroundColor: Colors.white10,
        automaticallyImplyLeading: false,
        title: _buildSearchField(),
        actions: _buildActions(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("name", isGreaterThanOrEqualTo: searchQuery)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  print("here we are");
                  return AllWorkersWidget(
                    userId: snapshot.data!.docs[index]["id"],
                    userEmail: snapshot.data!.docs[index]["email"],
                    userImageUrl: snapshot.data!.docs[index]["userImage"],
                    username: snapshot.data!.docs[index]["name"],
                    phoneNumber: snapshot.data!.docs[index]["phoneNumber"],
                  );
                },
              );
            } else {
              return const Center(
                child: Text("There is no user."),
              );
            }
          }
          return const Center(
            child: Text(
              "Something went wrong.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          );
        },
      ),
    );
  }
}
