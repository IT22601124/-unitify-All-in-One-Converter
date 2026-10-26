import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/conversion_catalog.dart';
import '../../core/utils/number_formatter.dart';
import '../../providers/app_state.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/empty_state.dart';
import '../converter/converter_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, this.showBackButton = false});
  final bool showBackButton;

  Future<void> _clear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear conversion history?'),
        content: const Text(
          'This removes all saved conversions from this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppState>().clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final history = state.history;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!showBackButton)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your 100 most recent conversions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (history.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear all history',
                    onPressed: () => _clear(context),
                    icon: const Icon(Icons.delete_sweep_outlined),
                  ),
              ],
            ),
          ),
        Expanded(
          child: history.isEmpty
              ? const Center(
                  child: EmptyState(
                    icon: Icons.history_rounded,
                    title: 'Nothing here yet',
                    message:
                        'Completed conversions will appear here automatically.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final category = categoryById(item.categoryId);
                    final from = category.unit(item.fromUnitId);
                    final to = category.unit(item.toUnitId);
                    final color = Color(category.colorValue);
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) =>
                          context.read<AppState>().deleteHistory(item.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                      child: Card(
                        child: ListTile(
                          minTileHeight: 88,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConverterScreen(
                                category: category,
                                initialFromId: from.id,
                                initialToId: to.id,
                                initialValue: item.input,
                              ),
                            ),
                          ),
                          leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              categoryIcon(category.iconKey),
                              color: color,
                            ),
                          ),
                          title: Text(
                            '${formatNumber(item.input, state.precision)} ${from.symbol}  →  ${formatNumber(item.result, state.precision)} ${to.symbol}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${category.name} · ${DateFormat.MMMd().add_jm().format(item.createdAt)}',
                          ),
                          trailing: IconButton(
                            tooltip: 'Delete entry',
                            onPressed: () =>
                                context.read<AppState>().deleteHistory(item.id),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
    if (!showBackButton) return SafeArea(bottom: false, child: content);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion history'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Clear all history',
              onPressed: () => _clear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: SafeArea(top: false, child: content),
    );
  }
}
