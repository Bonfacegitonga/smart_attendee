import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
  final controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        //controller: controller,
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
                    onPressed: () async {
                      final image = await controller.capture();
                      if (image == null) return;
                      await saveImage(image);
                      _showToast(context);
                    },
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [Icon(Icons.download), Text("Download")],
                    )),
                ElevatedButton(
                    onPressed: () async {
                      final image = await controller.capture();
                      saveAndShare(image!);
                    },
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(Icons.share_rounded),
                        Text("Share")
                      ],
                    )),
              ],
            )
          ],
        ),
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

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Image saved to gallery succesfully'),
      ),
    );
  }

  Future saveAndShare(Uint8List bytes) async {
    final imageName = widget.courseName;
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/$imageName.png');
    image.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(image.path)]);
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final result =
        await ImageGallerySaver.saveImage(bytes, name: widget.courseName);
    return result['filePath'];
  }
}
