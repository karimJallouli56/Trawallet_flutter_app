import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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
    return Stack(
      children: [
        PhotoView(
          heroAttributes: PhotoViewHeroAttributes(
            tag: file,
          ), // même identifiant utilisé dans le widget Hero
          imageProvider: FileImage(file),
          backgroundDecoration: BoxDecoration(color: Colors.grey[50]),
        ),
        // Un bouton "X" pour fermer l'écran
        Positioned(
          top: 40,
          right: 10,
          child: Container(
            padding: EdgeInsets.all(4), // space around the icon
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.15), // soft teal background
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: Colors.teal, size: 30),
              padding: EdgeInsets.zero, // remove default IconButton padding
              constraints: BoxConstraints(), // fix icon centering
            ),
          ),
        ),
      ],
    );
  }
}
