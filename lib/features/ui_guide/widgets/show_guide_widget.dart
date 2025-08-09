
// 이 위젯은 다양한 피드백(Toast, SnackBar, Dialog 등) UI의 구현 예시를 제공하여, 프로젝트 내 피드백 UI의 기준점 역할을 합니다.
// 실제 서비스 적용 전, 사용자에게 보여지는 피드백 UI의 방향성과 일관성을 확인하는 용도로 사용하세요.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowGuideWidget extends StatelessWidget {
  const ShowGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        _buildCard(
          context: context,
          title: 'Bottom Sheet',
          subtitle: 'A sheet that slides up from the bottom.',
          icon: Icons.vertical_align_bottom,
          onTap: () => _showBottomSheet(context),
        ),
        _buildCard(
          context: context,
          title: 'Toast',
          subtitle: 'A brief message at the bottom of the screen.',
          icon: Icons.info_outline,
          onTap: _showToast,
        ),
        _buildCard(
          context: context,
          title: 'SnackBar',
          subtitle: 'A lightweight message with an optional action.',
          icon: Icons.feedback,
          onTap: () => _showSnackBar(context),
        ),
        _buildCard(
          context: context,
          title: 'Material Banner',
          subtitle: 'A banner displayed at the top of the screen.',
          icon: Icons.view_day_outlined,
          onTap: () => _showMaterialBanner(context),
        ),
        _buildCard(
          context: context,
          title: 'Confirmation Dialog',
          subtitle: 'A standard Material Design dialog.',
          icon: Icons.check_circle_outline,
          onTap: () => _showConfirmationDialog(context),
        ),
        _buildCard(
          context: context,
          title: 'Cupertino Alert',
          subtitle: 'An iOS-style alert dialog.',
          icon: Icons.phone_iphone,
          onTap: () => _showCupertinoAlert(context),
        ),
      ],
    );
  }

  Widget _buildCard({required BuildContext context, required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Icon(
          icon, 
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(178), // withOpacity(0.7)
          ),
        ),
        trailing: Icon(
          Icons.play_arrow,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(153), // withOpacity(0.6)
        ),
        onTap: onTap,
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.drag_handle,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(102), // withOpacity(0.4)
              ),
              const SizedBox(height: 16),
              Text(
                'This is a Bottom Sheet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          ),
        ),
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
      SnackBar(
        content: Text(
          'This is a SnackBar.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: '확인',
          textColor: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showMaterialBanner(BuildContext context) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(
          'This is a Material Banner.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(), 
            child: Text(
              '닫기',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Confirm Action',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to proceed?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(204), // withOpacity(0.8)
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153), // withOpacity(0.6)
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text('OK'),
          ),
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

// Helper class to pass context to Fluttertoast
class ToastHelper {
  static void showToast(BuildContext context, String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      textColor: Theme.of(context).colorScheme.onInverseSurface,
      fontSize: 16.0,
    );
  }
}
