import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LaboratoryScreen extends StatelessWidget {
  const LaboratoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                _showBottomSheet(context);
              },
              child: const Text('Show Bottom Sheet'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showAlertDialog(context);
              },
              child: const Text('Show Popup (AlertDialog)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showToast();
              },
              child: const Text('Show Toast Message'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showSnackBar(context);
              },
              child: const Text('Show Snackbar'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Info Icon:'),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    _showInfoDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('This is a Bottom Sheet'),
                ElevatedButton(
                  child: const Text('Close Bottom Sheet'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Popup Title'),
          content: const Text('This is a simple popup message.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showToast() {
    Fluttertoast.showToast(
      msg: "This is a Toast Message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('This is a Snackbar'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Some action to undo
          },
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Information'),
          content: const Text('This is some information related to the icon.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
