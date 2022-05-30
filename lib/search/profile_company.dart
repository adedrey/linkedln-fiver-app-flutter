import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:linkedln/user_state.dart';
import 'package:linkedln/widgets/bottom_navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String phoneNumber = "";
  String email = "";
  String? name;
  String imageUrl = "";
  String joinedAT = " ";
  bool _isSameUser = false;

  void _getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          email = userDoc.get("email");
          name = userDoc.get("name");
          phoneNumber = userDoc.get("phoneNumber");
          imageUrl = userDoc.get("userImage");
          Timestamp joinedAtTimestamp = userDoc.get("createdAt");
          var joinedDate = joinedAtTimestamp.toDate();
          joinedAT = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState(() {
          _isSameUser = _uid == widget.userId;
        });
      }
    } catch (err) {
      // ...
    } finally {
      _isLoading = false;
    }
  }

  void _openWhatsAppChat() async {
    final url = Uri.parse('https//wa.me/$phoneNumber?text=HelloWorld');
    launchUrl(url);
  }

  void _mailTo() async {
    // Send Mail
    final Uri params = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Kklez Tech&body=Hello, Mr Adedire.');
    // final url = params.toString();
    launchUrl(params);
  }

  void _callPhoneNumber() async {
    var url = Uri.parse('tel://$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Error occured';
    }
  }

  Widget _contactBy({
    required Color color,
    required Function fct,
    required IconData icon,
  }) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 25,
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: IconButton(
            icon: Icon(
              icon,
              color: color,
            ),
            onPressed: () {
              fct();
            },
          ),
        ),
      ),
    );
  }

  Widget userInfo({
    required IconData icon,
    required String content,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: BottomNavigationWidget(
        selectedIndex: 3,
      ),
      body: Center(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                  ),
                  child: Stack(
                    children: [
                      Card(
                        color: Colors.white10,
                        margin: EdgeInsets.all(30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              const SizedBox(height: 100),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  name == null ? "Name here" : name!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                'Account Information',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 22),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child:
                                    userInfo(icon: Icons.email, content: email),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: userInfo(
                                    icon: Icons.phone_android,
                                    content: phoneNumber),
                              ),
                              const SizedBox(height: 35),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              _isSameUser
                                  ? Container()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _contactBy(
                                          color: Colors.green,
                                          fct: () {
                                            _openWhatsAppChat();
                                          },
                                          icon: FontAwesome.whatsapp,
                                        ),
                                        _contactBy(
                                          color: Colors.red,
                                          fct: _mailTo,
                                          icon: Icons.mail_outline,
                                        ),
                                        _contactBy(
                                          color: Colors.purple,
                                          fct: _callPhoneNumber,
                                          icon: Icons.call_outlined,
                                        ),
                                      ],
                                    ),
                              const SizedBox(height: 25),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 25),
                              !_isSameUser
                                  ? Container()
                                  : Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 30),
                                        child: MaterialButton(
                                          onPressed: () {
                                            _auth.signOut();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserState(),
                                              ),
                                            );
                                          },
                                          color: Colors.white10,
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  'Logout',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Icon(
                                                  Icons.logout,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.26,
                            height: size.width * 0.26,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 8,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              image: DecorationImage(
                                  image: NetworkImage(
                                    imageUrl == null
                                        ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"
                                        : imageUrl,
                                  ),
                                  fit: BoxFit.fill),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
