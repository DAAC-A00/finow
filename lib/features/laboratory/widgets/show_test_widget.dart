import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowTestWidget extends StatelessWidget {
  const ShowTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        _buildCard(
          title: 'Toast',
          subtitle: 'A brief message at the bottom of the screen.',
          icon: Icons.info_outline,
          onTap: _showToast,
        ),
        _buildCard(
          title: 'SnackBar',
          subtitle: 'A lightweight message with an optional action.',
          icon: Icons.feedback,
          onTap: () => _showSnackBar(context),
        ),
        _buildCard(
          title: 'Material Banner',
          subtitle: 'A banner displayed at the top of the screen.',
          icon: Icons.view_day_outlined,
          onTap: () => _showMaterialBanner(context),
        ),
        _buildCard(
          title: 'Confirmation Dialog',
          subtitle: 'A standard Material Design dialog.',
          icon: Icons.check_circle_outline,
          onTap: () => _showConfirmationDialog(context),
        ),
        _buildCard(
          title: 'Cupertino Alert',
          subtitle: 'An iOS-style alert dialog.',
          icon: Icons.phone_iphone,
          onTap: () => _showCupertinoAlert(context),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }

  void _showToast() {
    Fluttertoast.showToast(
      msg: "This is a toast message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
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
}