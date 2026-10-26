import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/conversion_catalog.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.showBackButton = false});
  final bool showBackButton;

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String message,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear'),
            ),
          ],
        ),
      ) ??
      false;

  void _privacy(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Privacy Policy'),
      content: const SingleChildScrollView(
        child: Text(
          'Unitify performs all conversions on your device. It does not collect, transmit, sell, or share personal data. Theme, preferences, favorites, and conversion history are stored locally on your device and can be cleared in Settings or by uninstalling the app. Unitify contains no analytics, advertising, accounts, or network services.',
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final body = ListView(
      padding: EdgeInsets.fromLTRB(20, showBackButton ? 10 : 20, 20, 32),
      children: [
        if (!showBackButton) ...[
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Make Unitify work your way',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
        ],
        const _SettingsHeader('APPEARANCE'),
        Card(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: 'Choose light, dark, or follow your device',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {state.themeMode},
                  onSelectionChanged: (selection) =>
                      state.setThemeMode(selection.first),
                  showSelectedIcon: false,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _SettingsHeader('CONVERSION'),
        Card(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.numbers_rounded,
                title: 'Decimal precision',
                subtitle: '${state.precision} decimal places',
                trailing: _SettingsDropdown<int>(
                  value: state.precision,
                  width: 72,
                  values: List.generate(11, (value) => value),
                  labelBuilder: (value) => '$value',
                  onChanged: (value) {
                    state.setPrecision(value);
                  },
                ),
              ),
              const Divider(height: 1, indent: 64),
              _SettingsTile(
                icon: Icons.home_work_outlined,
                title: 'Default converter',
                subtitle: 'Used as your preferred starting category',
                trailing: _SettingsDropdown<String>(
                  value: state.defaultCategoryId,
                  width: 148,
                  menuMaxHeight: 400,
                  values: conversionCatalog
                      .map((category) => category.id)
                      .toList(),
                  labelBuilder: (value) => conversionCatalog
                      .firstWhere((category) => category.id == value)
                      .name,
                  onChanged: (value) {
                    state.setDefaultCategory(value);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _SettingsHeader('YOUR DATA'),
        Card(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.delete_sweep_outlined,
                title: 'Clear history',
                subtitle: '${state.history.length} saved conversions',
                onTap: state.history.isEmpty
                    ? null
                    : () async {
                        if (await _confirm(
                              context,
                              'Clear history?',
                              'This permanently removes all conversion history from this device.',
                            ) &&
                            context.mounted) {
                          state.clearHistory();
                        }
                      },
              ),
              const Divider(height: 1, indent: 64),
              _SettingsTile(
                icon: Icons.heart_broken_outlined,
                title: 'Clear favorites',
                subtitle: '${state.favorites.length} saved pairs',
                onTap: state.favorites.isEmpty
                    ? null
                    : () async {
                        if (await _confirm(
                              context,
                              'Clear favorites?',
                              'This removes all saved unit-pair shortcuts.',
                            ) &&
                            context.mounted) {
                          state.clearFavorites();
                        }
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _SettingsHeader('ABOUT'),
        Card(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                subtitle: 'Your conversions stay on this device',
                onTap: () => _privacy(context),
              ),
              const Divider(height: 1, indent: 64),
              _SettingsTile(
                icon: Icons.code_rounded,
                title: 'Open-source licenses',
                subtitle: 'Libraries used by Unitify',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Unitify',
                  applicationIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: AppLogo(size: 56),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 64),
              const _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About Unitify',
                subtitle: 'Version 1.0.0 (1) · Offline converter',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: Column(
            children: [
              const AppLogo(size: 44),
              const SizedBox(height: 10),
              Text('Unitify', style: Theme.of(context).textTheme.titleMedium),
              Text(
                'Smart conversions, made simple.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
    if (showBackButton) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: SafeArea(top: false, child: body),
      );
    }
    return SafeArea(bottom: false, child: body);
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _SettingsDropdown<T> extends StatelessWidget {
  const _SettingsDropdown({
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
    required this.width,
    this.menuMaxHeight,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;
  final double width;
  final double? menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dropdownMenuWidth = width < 100 ? 112.0 : 220.0;

    return Container(
      width: width,
      height: 44,
      padding: const EdgeInsets.only(left: 12, right: 8),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.primary.withValues(alpha: .18)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: colors.surfaceContainerLow,
          elevation: 8,
          menuMaxHeight: menuMaxHeight,
          menuWidth: dropdownMenuWidth,
          icon: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 19,
              color: colors.primary,
            ),
          ),
          style: theme.textTheme.labelLarge?.copyWith(color: colors.onSurface),
          selectedItemBuilder: (context) => values
              .map(
                (item) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    labelBuilder(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          items: values
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          labelBuilder(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item == value) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.check_rounded,
                          size: 19,
                          color: colors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 76,
    onTap: onTap,
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle),
    trailing:
        trailing ??
        (onTap == null ? null : const Icon(Icons.chevron_right_rounded)),
  );
}
