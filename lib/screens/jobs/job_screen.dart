import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkedln/models/job.dart';
import 'package:linkedln/persistent/persistent.dart';
import 'package:linkedln/search/search_job.dart';
import 'package:linkedln/services/global_variables.dart';
import 'package:linkedln/widgets/bottom_navbar.dart';
import 'package:linkedln/widgets/job.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({Key? key}) : super(key: key);

  @override
  _JobScreenState createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  String? jobCategoryFilter;

  void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = userDoc.get("name");
      userImage = userDoc.get("userImage");
      location = userDoc.get("location");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
  }

  _showJobCategoryDialog({required Size size}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Job Category",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          content: Container(
            width: size.width * .9,
            child: ListView.builder(
              itemCount: Persistent.jobsList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      jobCategoryFilter == Persistent.jobsList[index];
                    });
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_right_outlined,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          Persistent.jobsList[index],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  jobCategoryFilter = null;
                });
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: const Text(
                "Cancel Filter",
                style: TextStyle(
                  color: Colors.grey,
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationWidget(selectedIndex: 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.filter_list_outlined,
            color: Colors.grey,
          ),
          onPressed: () {
            _showJobCategoryDialog(size: size);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.search_outlined,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("jobs")
            .where("jobCategory", isEqualTo: jobCategoryFilter)
            .where("recruitment", isEqualTo: true)
            .orderBy("createdAt", descending: false)
            .snapshots(),
        builder: (context, jobSnapshot) {
          if (jobSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (jobSnapshot.connectionState == ConnectionState.active) {
            if (jobSnapshot.data?.docs.isNotEmpty == true) {
              return ListView.builder(
                itemCount: jobSnapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  return JobWidget(
                    jobTitle: jobSnapshot.data?.docs[index]["jobTitle"],
                    jobDescription: jobSnapshot.data?.docs[index]
                        ["jobDescription"],
                    jobId: jobSnapshot.data?.docs[index]["jobId"],
                    uploadedBy: jobSnapshot.data?.docs[index]["uploadedBy"],
                    userImage: jobSnapshot.data?.docs[index]["userImage"],
                    name: jobSnapshot.data?.docs[index]["name"],
                    recruitment: jobSnapshot.data?.docs[index]["recruitment"],
                    email: jobSnapshot.data?.docs[index]["email"],
                    location: jobSnapshot.data?.docs[index]["location"],
                  );
                },
              );
            } else {
              return const Center(
                child: Text("There is no job"),
              );
            }
          }
          return const Center(
            child: Text(
              "Something went wrong",
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
