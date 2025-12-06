import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trawallet_final_version/views/home/components/capitalizeWords.dart';

class ImageViewerScreen extends StatelessWidget {
  final File file;
  final String fileType;

  const ImageViewerScreen({
    required this.file,
    required this.fileType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My ' + capitalizeWords(fileType),
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Image.file(file, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
