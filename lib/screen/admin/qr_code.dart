import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QrCodeShare extends StatefulWidget {
  final String courseName;
  final String courseCode;
  final String classLink;
  const QrCodeShare(
      {super.key,
      required this.courseName,
      required this.courseCode,
      required this.classLink});

  @override
  State<QrCodeShare> createState() => _QrCodeShareState();
}

class _QrCodeShareState extends State<QrCodeShare> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
          backgroundColor: Colors.white),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          qrCode(),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [Icon(Icons.download), Text("Download")],
                  )),
              ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [Icon(Icons.share_rounded), Text("Share")],
                  )),
            ],
          )
        ],
      ),
    );
  }

  Widget qrCode() {
    return Column(
      children: [
        Text(
          widget.courseName,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          widget.courseCode,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 19,
            color: Colors.black,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        BarcodeWidget(
          data: widget.classLink,
          barcode: Barcode.qrCode(),
          color: Colors.black,
          width: 300,
          height: 300,
        )
      ],
    );
  }
}
