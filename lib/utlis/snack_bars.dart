import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      content: AwesomeSnackbarContent(
        color: Colors.red,
        title: 'Error',
        message: message,
        contentType: ContentType.failure,
      ),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      content: AwesomeSnackbarContent(
        color: Colors.green,
        title: 'Success',
        message: message,
        contentType: ContentType.success,
      ),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showWarningSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      content: AwesomeSnackbarContent(
        color: Colors.amber,
        title: 'Warning',
        message: message,
        contentType: ContentType.warning,
      ),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
