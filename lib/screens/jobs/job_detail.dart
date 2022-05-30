import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkedln/models/comment.dart';
import 'package:linkedln/models/job.dart';
import 'package:linkedln/services/global_methods.dart';
import 'package:linkedln/services/global_variables.dart';
import 'package:linkedln/widgets/comments.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class JobDetailScreen extends StatefulWidget {
  final String? uploadedBy;
  final String? jobId;
  const JobDetailScreen({this.uploadedBy, this.jobId});
  @override
  _JobDetailScreenState createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  TextEditingController _commentController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isCommenting = false;
  String? jobTitle;
  String? jobDescription;
  bool? recruitment;
  String? email;
  String? location;
  String? authorName;
  String? userImageUrl;
  int applicant = 0;
  bool isDeadlineAvailable = false;
  bool showComment = false;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? dealineDate;

  void getJobData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uploadedBy)
        .get();

    if (userDoc == null) {
      return;
    } else {
      setState(() {
        authorName = userDoc.get("name");
        userImageUrl = userDoc.get("userImage");
      });
    }
    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance
        .collection("jobs")
        .doc(widget.jobId)
        .get();
    if (jobDatabase == null) {
      return;
    } else {
      setState(() {
        jobTitle = jobDatabase.get("jobTitle");
        jobDescription = jobDatabase.get("jobDescription");
        recruitment = jobDatabase.get("recruitment");
        email = jobDatabase.get("email");
        location = jobDatabase.get("location");

        applicant = jobDatabase.get("applicants");
        postedDateTimeStamp = jobDatabase.get("createdAt");
        deadlineDateTimeStamp = jobDatabase.get("deadlineDateTimeStamp");
        dealineDate = jobDatabase.get("deadlineDate");
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
      });
      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());
    }
  }

  applyForJob() {
    final Uri params = Uri(
        scheme: 'mailto',
        path: email,
        query:
            'subject=Applying for ${jobTitle}&body=Hello, please attach Resume CV file.');
    // final url = params.toString();
    launchUrl(params);
    addNewApplicant();
  }

  void addNewApplicant() async {
    var docRef =
        FirebaseFirestore.instance.collection("jobs").doc(widget.jobId);
    docRef.update({
      "applicants": applicant + 1,
    });
    setState(() {
      applicant = applicant + 1;
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    getJobData();
    super.initState();
  }

  Widget dividerWidget() {
    return Column(
      children: const [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            size: 40,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.white38,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobTitle != null ? jobTitle.toString() : '',
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 3,
                                color: Colors.grey,
                              ),
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  userImageUrl == null
                                      ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"
                                      : userImageUrl!,
                                ),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authorName == null ? '' : authorName!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  location == null ? '' : location!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      dividerWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            applicant.toString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Text(
                            " Applicants",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.how_to_reg_sharp,
                            color: Colors.grey,
                          )
                        ],
                      ),
                      FirebaseAuth.instance.currentUser!.uid !=
                              widget.uploadedBy
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                dividerWidget(),
                                const Text(
                                  " Recruitment",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        final _uid = FirebaseAuth
                                            .instance.currentUser!.uid;
                                        if (_uid == widget.uploadedBy) {
                                          try {
                                            FirebaseFirestore.instance
                                                .collection("jobs")
                                                .doc(widget.jobId)
                                                .update({"recruitment": true});
                                          } catch (err) {
                                            GlobalMethod.showErrorDialog(
                                                error:
                                                    "Action can't be performed",
                                                ctx: context);
                                          }
                                        } else {
                                          GlobalMethod.showErrorDialog(
                                              error:
                                                  "You can't perform this action.",
                                              ctx: context);
                                        }
                                        getJobData();
                                      },
                                      child: const Text(
                                        'On',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: recruitment == true ? 1 : 0,
                                      child: const Icon(
                                        Icons.check_box,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final _uid = FirebaseAuth
                                            .instance.currentUser!.uid;
                                        if (_uid == widget.uploadedBy) {
                                          try {
                                            FirebaseFirestore.instance
                                                .collection("jobs")
                                                .doc(widget.jobId)
                                                .update({"recruitment": false});
                                          } catch (err) {
                                            GlobalMethod.showErrorDialog(
                                                error:
                                                    "Action can't be performed",
                                                ctx: context);
                                          }
                                        } else {
                                          GlobalMethod.showErrorDialog(
                                              error:
                                                  "You can't perform this action.",
                                              ctx: context);
                                        }
                                        getJobData();
                                      },
                                      child: const Text(
                                        'Off',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: recruitment == false ? 1 : 0,
                                      child: const Icon(
                                        Icons.check_box,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      dividerWidget(),
                      const Text(
                        'Job Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        jobDescription == null ? '' : jobDescription!,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      dividerWidget(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.white38,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          isDeadlineAvailable
                              ? 'Actively Recruiting, Send CV/Resume'
                              : 'Deadline Passed away.',
                          style: TextStyle(
                            // fontStyle: FontStyle.italic,
                            color:
                                isDeadlineAvailable ? Colors.green : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Center(
                        child: MaterialButton(
                          onPressed: () {
                            print("we are here to apply");
                            applyForJob();
                          },
                          color: Colors.blueAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Easy Apply Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      dividerWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Uploaded On',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            postedDate == null ? '' : postedDate!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Deadline Date',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            dealineDate == null ? '' : dealineDate!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      dividerWidget(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.white38,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: 500,
                        ),
                        child: _isCommenting
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: TextField(
                                      controller: _commentController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      maxLength: 200,
                                      keyboardType: TextInputType.text,
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.pink),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: MaterialButton(
                                            onPressed: () async {
                                              if (_commentController
                                                      .text.length <
                                                  7) {
                                                GlobalMethod.showErrorDialog(
                                                    error:
                                                        "Comment cant be less than 7 characters",
                                                    ctx: context);
                                              } else {
                                                final _generatedId =
                                                    Uuid().v4();
                                                await FirebaseFirestore.instance
                                                    .collection("jobs")
                                                    .doc(widget.jobId)
                                                    .update(
                                                  {
                                                    "jobComments":
                                                        FieldValue.arrayUnion(
                                                      [
                                                        {
                                                          "userId": FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid,
                                                          "commentId":
                                                              _generatedId,
                                                          "name": name,
                                                          "userImageUrl":
                                                              userImage,
                                                          "commentBody":
                                                              _commentController
                                                                  .text,
                                                          "time":
                                                              Timestamp.now(),
                                                        },
                                                      ],
                                                    ),
                                                  },
                                                );
                                                await Fluttertoast.showToast(
                                                  msg:
                                                      "Your comment has been added",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  backgroundColor: Colors.grey,
                                                  fontSize: 18.0,
                                                );
                                                setState(() {
                                                  showComment = true;
                                                });
                                              }
                                            },
                                            elevation: 0,
                                            color: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              "Post",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                              showComment = false;
                                            });
                                          },
                                          child: const Text(
                                            "Cancel",
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isCommenting = !_isCommenting;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add_comment,
                                      color: Colors.blueAccent,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showComment = !showComment;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_drop_down_circle,
                                      color: Colors.blueAccent,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      showComment == false
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection("jobs")
                                    .doc(widget.jobId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    if (snapshot.data == null) {
                                      const Center(
                                        child: Text(
                                          "No Comment for this job",
                                        ),
                                      );
                                    }
                                  }
                                  return ListView.separated(
                                    itemBuilder: (context, index) {
                                      return CommentWidget(
                                        comment: CommentModel(
                                            commentId:
                                                snapshot.data!["jobComments"]
                                                    [index]["commentId"],
                                            commenterId:
                                                snapshot.data!["jobComments"]
                                                    [index]["userId"],
                                            commenterName:
                                                snapshot.data!["jobComments"]
                                                    [index]["name"],
                                            commenterImageUrl:
                                                snapshot.data!["jobComments"]
                                                    [index]["userImageUrl"],
                                            commentBody:
                                                snapshot.data!["jobComments"]
                                                    [index]["commentBody"]),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return const Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                      );
                                    },
                                    itemCount:
                                        snapshot.data!["jobComments"].length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
