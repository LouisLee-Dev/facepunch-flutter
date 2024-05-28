import 'package:facepunch/config/app_const.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';


class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces, this.strokeWidth);

  final Size absoluteImageSize;
  final List<Face> faces;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Color(primaryColor);

    for (Face face in faces) {
      final rect = Rect.fromLTRB(
        face.boundingBox.left * scaleX,
        face.boundingBox.top * scaleY,
        face.boundingBox.right * scaleX,
        face.boundingBox.bottom * scaleY,
      );
      double length = rect.width * 0.25;
      double radius = rect.width * 0.1;
      final path = Path();
      path.moveTo(rect.left, rect.top+length);
      path.lineTo(rect.left, rect.top+radius);
      path.arcToPoint(Offset(rect.left+radius, rect.top), radius: Radius.circular(radius));
      path.lineTo(rect.left+length, rect.top);
      path.moveTo(rect.right-length, rect.top);
      path.lineTo(rect.right-radius, rect.top);
      path.arcToPoint(Offset(rect.right, rect.top+radius), radius: Radius.circular(radius));
      path.lineTo(rect.right, rect.top+length);
      path.moveTo(rect.right, rect.bottom-length);
      path.lineTo(rect.right, rect.bottom-radius);
      path.arcToPoint(Offset(rect.right-radius, rect.bottom), radius: Radius.circular(radius));
      path.lineTo(rect.right-length, rect.bottom);
      path.moveTo(rect.left+length, rect.bottom);
      path.lineTo(rect.left+radius, rect.bottom);
      path.arcToPoint(Offset(rect.left, rect.bottom-radius), radius: Radius.circular(radius));
      path.lineTo(rect.left, rect.bottom-length);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize || oldDelegate.faces != faces;
  }
}
