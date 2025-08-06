import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowTestWidget extends StatelessWidget {
  const ShowTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _showToast,
          child: const Text('Show Toast'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showConfirmationDialog(context),
          child: const Text('Show Confirmation Dialog'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showCupertinoAlert(context),
          child: const Text('Show Cupertino Alert'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showMaterialBanner(context),
          child: const Text('Show Material Banner'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showSnackBar(context),
          child: const Text('Show SnackBar'),
        ),
      ],
    );
  }

  void _showToast() {
    Fluttertoast.showToast(
      msg: "This is a toast message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: const Text('Are you sure you want to proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showCupertinoAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Cupertino Alert'),
        content: const Text('This is a Cupertino-style alert.'),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          CupertinoDialogAction(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showMaterialBanner(BuildContext context) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: const Text('This is a Material Banner.'),
        actions: [
          TextButton(onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(), child: const Text('DISMISS')),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This is a SnackBar.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}