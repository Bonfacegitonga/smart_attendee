import 'package:flutter/material.dart';
import 'package:smart_attendee/constant/constant.dart';

class BeautifulContainer extends StatelessWidget {
  final String headline;
  final String subtitle;
  final LinearGradient kcolor;

  const BeautifulContainer(
      {super.key,
      required this.headline,
      required this.subtitle,
      required this.kcolor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kcolor,
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(5.0, 5.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            headline,
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13.0,
            ),
          ),
        ],
      ),
    );
  }
}
