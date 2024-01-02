// CustomDialog.dart
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title, content;
  final VoidCallback onConfirm, onCancel;

  CustomDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // border-radius: 10px;
      ),
      backgroundColor: Colors.white, // background: #FFF;
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFF476BEC), // Primary blue color
          fontFamily: 'Pretendard Variable',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.408,
          height: 1.0, // 100% line-height
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          color: Colors.black, // Black color
          fontFamily: 'Pretendard Variable',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.408,
          height: 1.41667, // 141.667% line-height
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onConfirm,
          child: Text(
            '예',
            style: TextStyle(
              color: Colors.black, // Black color
              fontFamily: 'Pretendard Variable',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.408,
              height: 1.375, // 137.5% line-height
            ),
          ),
        ),
        TextButton(
          onPressed: onCancel,
          child: Text(
            '아니오',
            style: TextStyle(
              color: Colors.black, // Black color
              fontFamily: 'Pretendard Variable',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.408,
              height: 1.375, // 137.5% line-height
            ),
          ),
        ),
      ],
    );
  }
}
