import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/drawer/gf_drawer.dart';
import 'package:getwidget/components/drawer/gf_drawer_header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_attendee/constant/constant.dart';

class MyDrawer extends StatefulWidget {
  final String names;
  final String email;
  final Function signOut;
  const MyDrawer(
      {super.key,
      required this.names,
      required this.email,
      required this.signOut});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  User user = FirebaseAuth.instance.currentUser!;
  String? fName;
  String? sName;
  String? role;

  Future getUser() async {
    //User user = FirebaseAuth.instance.currentUser!;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
    if (documentSnapshot.exists) {
      setState(() {
        fName = documentSnapshot.get('last_name');
        sName = documentSnapshot.get('first_name');
        role = documentSnapshot.get('role');
      });
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final email = user.email;
    final String myrole = role.toString();
    final String fullNames = '$fName $sName ($myrole)';
    return GFDrawer(
      // gradient: primaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 50),
            decoration: const BoxDecoration(gradient: primaryColor),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60.0,
                  backgroundImage: NetworkImage(
                      "https://cdn.pixabay.com/photo/2017/12/03/18/04/christmas-balls-2995437_960_720.jpg"),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(fullNames,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    )),
                const SizedBox(
                  height: 4,
                ),
                Text(email.toString(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.white,
                    )),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              'SIGN OUT',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
            onTap: () {
              widget.signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
