import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/drawer/gf_drawer.dart';
import 'package:getwidget/components/drawer/gf_drawer_header.dart';

class MyDrawer extends StatelessWidget {
  final String names;
  final String email;
  final Function signOut;
  const MyDrawer(
      {super.key,
      required this.names,
      required this.email,
      required this.signOut});

  @override
  Widget build(BuildContext context) {
    return GFDrawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GFDrawerHeader(
            currentAccountPicture: const GFAvatar(
              radius: 80.0,
              backgroundImage: NetworkImage(
                  "https://cdn.pixabay.com/photo/2017/12/03/18/04/christmas-balls-2995437_960_720.jpg"),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(names),
                Text(email),
              ],
            ),
          ),
          ListTile(
            title: const Text('Sign Out'),
            onTap: () {
              signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
