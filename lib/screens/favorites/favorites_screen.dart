import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/conversion_catalog.dart';
import '../../providers/app_state.dart';
import '../../widgets/conversion_pair_tile.dart';
import '../../widgets/empty_state.dart';
import '../converter/converter_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AppState>().favorites;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favorites',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Your saved conversion shortcuts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: favorites.isEmpty
                ? const Center(
                    child: EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No favorites yet',
                      message:
                          'Tap the heart in a converter to save a unit pair here.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                    itemCount: favorites.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final favorite = favorites[index];
                      final category = categoryById(favorite.categoryId);
                      return Card(
                        child: ConversionPairTile(
                          category: category,
                          fromId: favorite.fromUnitId,
                          toId: favorite.toUnitId,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConverterScreen(
                                category: category,
                                initialFromId: favorite.fromUnitId,
                                initialToId: favorite.toUnitId,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove favorite',
                            onPressed: () => context
                                .read<AppState>()
                                .toggleFavorite(favorite),
                            icon: const Icon(Icons.favorite_rounded),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
