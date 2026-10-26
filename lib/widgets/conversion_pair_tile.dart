import 'package:flutter/material.dart';

import '../models/conversion_category.dart';
import 'category_icon.dart';

class ConversionPairTile extends StatelessWidget {
  const ConversionPairTile({
    super.key,
    required this.category,
    required this.fromId,
    required this.toId,
    required this.onTap,
    this.trailing,
  });
  final ConversionCategory category;
  final String fromId;
  final String toId;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    final from = category.unit(fromId);
    final to = category.unit(toId);
    return ListTile(
      onTap: onTap,
      minTileHeight: 76,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(categoryIcon(category.iconKey), color: color, size: 21),
      ),
      title: Text(
        '${from.symbol}  →  ${to.symbol}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${category.name} · ${from.name} to ${to.name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
    );
  }
}
