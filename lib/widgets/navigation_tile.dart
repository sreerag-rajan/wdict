import 'package:flutter/material.dart';
import 'custom_list_tile.dart';
import '../theme/app_colors.dart';

class NavigationTile extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const NavigationTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.description,
    this.iconColor = AppColors.sketchBlue,
  });

  @override
  Widget build(BuildContext context) {
    return SketchyListTile(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      onTap: onTap,
      leading: Icon(icon, size: 32, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      subtitle: description != null
          ? Text(
              description!,
              style: const TextStyle(fontSize: 14, color: AppColors.graphite),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.graphite),
    );
  }
}
