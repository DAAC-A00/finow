import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'api_key_status.g.dart';

@HiveType(typeId: 6)
enum ApiKeyStatus {
  @HiveField(0) valid('Valid', icon: Icons.check_circle, color: Colors.green),
  @HiveField(1) invalidKey('Invalid Key', icon: Icons.error, color: Colors.red),
  @HiveField(2) inactiveAccount('Inactive Account', icon: Icons.account_circle_outlined, color: Colors.orange),
  @HiveField(3) quotaReached('Quota Reached', icon: Icons.block, color: Colors.amber),
  @HiveField(4) unsupportedCode('Unsupported Currency', icon: Icons.money_off, color: Colors.grey),
  @HiveField(5) malformedRequest('Malformed Request', icon: Icons.warning, color: Colors.yellow),
  @HiveField(6) unknown('Unknown Status', icon: Icons.help_outline, color: Colors.grey),
  @HiveField(7) validating('Validating...', icon: Icons.sync, color: Colors.blue);

  const ApiKeyStatus(this.label, {required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;
}
