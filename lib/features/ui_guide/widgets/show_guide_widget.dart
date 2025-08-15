import 'package:finow/ui_scale_provider.dart';
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
          onTap: () => _showToast(context),
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

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: colorScheme.surface,
      child: ListTile(
        leading: ScaledIcon(
          icon,
          size: 40,
          color: colorScheme.primary,
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withAlpha((255 * 0.7).round()),
          ),
        ),
        trailing: ScaledIcon(
          Icons.play_arrow,
          color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      builder: (context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaledIcon(
                Icons.drag_handle,
                color: colorScheme.onSurface.withAlpha((255 * 0.4).round()),
              ),
              const SizedBox(height: 16),
              Text(
                'This is a Bottom Sheet',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
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

  void _showToast(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final uiScale = UIScaleProvider.of(context).scale;

    Fluttertoast.showToast(
      msg: "This is a toast message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: colorScheme.inverseSurface,
      textColor: colorScheme.onInverseSurface,
      fontSize: 16.0 * uiScale,
    );
  }

  void _showSnackBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'This is a SnackBar.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: colorScheme.inverseSurface,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: '확인',
          textColor: colorScheme.inversePrimary,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showMaterialBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(
          'This is a Material Banner.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        leading: ScaledIcon(
          Icons.info_outline,
          color: colorScheme.primary,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text(
              '닫기',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Confirm Action',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to proceed?',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withAlpha((255 * 0.8).round()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
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
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}