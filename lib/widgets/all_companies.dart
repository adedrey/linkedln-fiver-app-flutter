import 'package:flutter/material.dart';
import 'package:linkedln/models/worker.dart';
import 'package:linkedln/search/profile_company.dart';
import 'package:url_launcher/url_launcher.dart';

class AllWorkersWidget extends StatefulWidget {
  String userId;
  String username;
  String userEmail;
  String phoneNumber;
  String userImageUrl;
  AllWorkersWidget({
    required this.userId,
    required this.username,
    required this.userEmail,
    required this.phoneNumber,
    required this.userImageUrl,
  });

  @override
  _AllWorkersWidgetState createState() => _AllWorkersWidgetState();
}

class _AllWorkersWidgetState extends State<AllWorkersWidget> {
  void _mailTo() async {
    // Send Mail
    var mailUrl = Uri.parse("mailto: ${widget.userEmail}");
    print(mailUrl.toString());
    if (await canLaunchUrl(mailUrl)) {
      await launchUrl(mailUrl);
    } else {
      print("error occured");
      throw "Error occured";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: widget.userId),
            ),
          );
        },
        leading: Container(
          padding: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: const Border(
              right: BorderSide(width: 1),
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Image.network(
              widget.userImageUrl == null
                  ? 'https://cdn.icon-icons.com/icons2/1285/PNG/512/male6_85212.png'
                  : widget.userImageUrl,
            ),
          ),
        ),
        title: Text(
          widget.userEmail,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              "Visit Profile",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.mail_outline,
            size: 30,
            color: Colors.grey,
          ),
          onPressed: _mailTo,
        ),
      ),
    );
  }
}
