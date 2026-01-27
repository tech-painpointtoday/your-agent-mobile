import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';

class XFileImage extends StatelessWidget {
  final XFile file;
  final double? width;
  final double? height;
  final BoxFit fit;

  const XFileImage({
    super.key,
    required this.file,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return Center(
            child: Text(
              'ไม่สามารถแสดงรูปภาพได้',
              style: GoogleFonts.anuphan(color: AppColors.baseGrey),
            ),
          );
        }
        return Image.memory(bytes, width: width, height: height, fit: fit);
      },
    );
  }
}
