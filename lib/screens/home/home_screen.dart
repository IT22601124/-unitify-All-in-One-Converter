import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/conversion_catalog.dart';
import '../../models/conversion_category.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/conversion_pair_tile.dart';
import '../../widgets/empty_state.dart';
import '../converter/converter_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ConversionCategory> get _results {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return conversionCatalog;
    return conversionCatalog
        .where(
          (category) =>
              category.name.toLowerCase().contains(query) ||
              category.description.toLowerCase().contains(query) ||
              category.units.any(
                (unit) =>
                    unit.name.toLowerCase().contains(query) ||
                    unit.symbol.toLowerCase().contains(query),
              ),
        )
        .toList();
  }

  void _open(ConversionCategory category, {String? fromId, String? toId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConverterScreen(
          category: category,
          initialFromId: fromId,
          initialToId: toId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = Theme.of(context).colorScheme;
    final results = [..._results];
    if (_query.isEmpty) {
      final preferredIndex = results.indexWhere(
        (category) => category.id == state.defaultCategoryId,
      );
      if (preferredIndex > 0) {
        results.insert(0, results.removeAt(preferredIndex));
      }
    }
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    const AppLogo(size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unitify',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Everyday conversion toolkit',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    _HeaderAction(
                      tooltip: 'Change theme',
                      onPressed: state.cycleTheme,
                      icon: Icon(switch (state.themeMode) {
                        ThemeMode.light => Icons.light_mode_outlined,
                        ThemeMode.dark => Icons.dark_mode_outlined,
                        _ => Icons.brightness_auto_outlined,
                      }),
                    ),
                    const SizedBox(width: 6),
                    _HeaderAction(
                      tooltip: 'Settings',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SettingsScreen(showBackButton: true),
                        ),
                      ),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'Convert Anything',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Accurate, instant conversions across ${conversionCatalog.length} categories.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search a converter or unit',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_query.isEmpty) ...[
                  _SectionTitle(
                    title: 'Favorites',
                    action: state.favorites.isEmpty
                        ? null
                        : '${state.favorites.length} saved pair${state.favorites.length == 1 ? '' : 's'}',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: state.favorites.isEmpty
                        ? const _FavoritesEmptyState()
                        : Column(
                            children: state.favorites.take(3).map((favorite) {
                              final category = categoryById(
                                favorite.categoryId,
                              );
                              return ConversionPairTile(
                                category: category,
                                fromId: favorite.fromUnitId,
                                toId: favorite.toUnitId,
                                onTap: () => _open(
                                  category,
                                  fromId: favorite.fromUnitId,
                                  toId: favorite.toUnitId,
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
                _SectionTitle(
                  title: _query.isEmpty
                      ? 'All converters'
                      : '${results.length} result${results.length == 1 ? '' : 's'}',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (results.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No converters found',
                message: 'Try a category, unit name, or symbol.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final count = width >= 760
                      ? 4
                      : width >= 520
                      ? 3
                      : 2;
                  return SliverGrid.builder(
                    itemCount: results.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: width < 360 ? .84 : .92,
                    ),
                    itemBuilder: (_, index) => _CategoryCard(
                      category: results[index],
                      onTap: () => _open(results[index]),
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

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              color: colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your shortcuts live here',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Save a unit pair for one-tap access.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    icon: icon,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (action != null)
        Text(
          action!,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
    ],
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});
  final ConversionCategory category;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      categoryIcon(category.iconKey),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.north_east_rounded,
                    size: 18,
                    color: colors.onSurfaceVariant.withValues(alpha: .7),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                category.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 9),
              Text(
                '${category.units.length} UNITS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
