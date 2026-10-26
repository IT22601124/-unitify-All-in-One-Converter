import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../models/conversion_category.dart';
import '../../models/conversion_history.dart';
import '../../models/conversion_unit.dart';
import '../../models/favorite_conversion.dart';
import '../../providers/app_state.dart';
import '../../services/conversion_service.dart';
import '../../widgets/category_icon.dart';
import '../history/history_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({
    super.key,
    required this.category,
    this.initialFromId,
    this.initialToId,
    this.initialValue,
  });
  final ConversionCategory category;
  final String? initialFromId;
  final String? initialToId;
  final double? initialValue;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  static const _service = ConversionService();
  late final TextEditingController _controller;
  late ConversionUnit _from;
  late ConversionUnit _to;
  Timer? _historyTimer;
  ConversionResult? _result;
  bool _swapped = false;

  @override
  void initState() {
    super.initState();
    final units = widget.category.units;
    _from = _unitOr(widget.initialFromId, units.first);
    _to = _unitOr(
      widget.initialToId,
      units.length > 1 ? units[1] : units.first,
    );
    _controller = TextEditingController(
      text: widget.initialValue == null
          ? '1'
          : formatNumber(widget.initialValue!, 6),
    );
    _calculate(record: false);
  }

  ConversionUnit _unitOr(String? id, ConversionUnit fallback) {
    if (id == null) return fallback;
    return widget.category.units.where((unit) => unit.id == id).firstOrNull ??
        fallback;
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _calculate({bool record = true}) {
    _historyTimer?.cancel();
    final input = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    setState(() {
      _result = input == null
          ? (_controller.text.trim().isEmpty
                ? null
                : ConversionResult.failure('Enter a valid number'))
          : _service.convert(
              category: widget.category,
              from: _from,
              to: _to,
              value: input,
            );
    });
    if (record && input != null && _result?.isValid == true) {
      _historyTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        context.read<AppState>().addHistory(
          ConversionHistory(
            id: '${DateTime.now().microsecondsSinceEpoch}',
            categoryId: widget.category.id,
            input: input,
            result: _result!.value!,
            fromUnitId: _from.id,
            toUnitId: _to.id,
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }

  void _swap() {
    HapticFeedback.selectionClick();
    final currentResult = _result?.value;
    setState(() {
      final old = _from;
      _from = _to;
      _to = old;
      _swapped = !_swapped;
    });
    if (currentResult != null) {
      _controller.text = formatNumber(currentResult, 10);
    }
    _calculate();
  }

  Future<void> _copy() async {
    final value = _result?.value;
    if (value == null) return;
    final text =
        '${formatNumber(value, context.read<AppState>().precision)} ${_to.symbol}';
    await Clipboard.setData(ClipboardData(text: text));
    await HapticFeedback.lightImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied $text'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = Theme.of(context).colorScheme;
    final isFavorite = state.isFavorite(widget.category.id, _from.id, _to.id);
    final result = _result?.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () {
              HapticFeedback.selectionClick();
              state.toggleFavorite(
                FavoriteConversion(
                  categoryId: widget.category.id,
                  fromUnitId: _from.id,
                  toUnitId: _to.id,
                ),
              );
            },
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? colors.error : null,
            ),
          ),
          IconButton(
            tooltip: 'Conversion history',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HistoryScreen(showBackButton: true),
              ),
            ),
            icon: const Icon(Icons.history_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CategoryBanner(category: widget.category),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Conversion details',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.bolt_rounded,
                                size: 18,
                                color: colors.secondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'LIVE',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.secondary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: .8,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Amount',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller,
                            autofocus: widget.initialValue == null,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^-?\d*[\.,]?\d*(?:[eE][+-]?\d*)?$'),
                              ),
                            ],
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                            decoration: InputDecoration(
                              hintText: '0',
                              errorText: _result?.error,
                              suffixIcon: _controller.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear amount',
                                      onPressed: () {
                                        _controller.clear();
                                        _calculate();
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                            ),
                            onChanged: (_) => _calculate(),
                          ),
                          const SizedBox(height: 18),
                          _UnitSelector(
                            label: 'From',
                            value: _from,
                            units: widget.category.units,
                            onChanged: (unit) {
                              setState(() => _from = unit);
                              _calculate();
                            },
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Semantics(
                              label: 'Swap source and target units',
                              button: true,
                              child: AnimatedRotation(
                                turns: _swapped ? .5 : 0,
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutBack,
                                child: FilledButton.tonalIcon(
                                  onPressed: _swap,
                                  icon: const Icon(Icons.swap_vert_rounded),
                                  label: const Text('Swap'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _UnitSelector(
                            label: 'To',
                            value: _to,
                            units: widget.category.units,
                            onChanged: (unit) {
                              setState(() => _to = unit);
                              _calculate();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _ResultPanel(
                      key: ValueKey('${result ?? _result?.error}-${_to.id}'),
                      value: result == null
                          ? '—'
                          : formatNumber(result, state.precision),
                      unit: _to.symbol,
                      hasResult: result != null,
                      onCopy: _copy,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Quick amounts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Start with a common value',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [1, 10, 100, 1000]
                        .map(
                          (value) => ActionChip(
                            label: Text('$value ${_from.symbol}'),
                            onPressed: () {
                              _controller.text = '$value';
                              _calculate();
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.functions_rounded, color: colors.primary),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How it works',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _service.formula(widget.category, _from, _to),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBanner extends StatelessWidget {
  const _CategoryBanner({required this.category});
  final ConversionCategory category;
  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(categoryIcon(category.iconKey), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${category.units.length} units · Works offline',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_user_outlined, size: 20, color: color),
        ],
      ),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({
    required this.label,
    required this.value,
    required this.units,
    required this.onChanged,
  });
  final String label;
  final ConversionUnit value;
  final List<ConversionUnit> units;
  final ValueChanged<ConversionUnit> onChanged;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DropdownButtonFormField<ConversionUnit>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 420,
      borderRadius: BorderRadius.circular(18),
      dropdownColor: colors.surfaceContainerLow,
      elevation: 8,
      icon: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 21,
          color: colors.primary,
        ),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          label == 'From' ? Icons.login_rounded : Icons.logout_rounded,
        ),
      ),
      selectedItemBuilder: (context) =>
          units.map((unit) => _SelectedUnit(unit: unit)).toList(),
      items: units
          .map(
            (unit) => DropdownMenuItem(
              value: unit,
              child: _UnitMenuItem(unit: unit, selected: unit == value),
            ),
          )
          .toList(),
      onChanged: (unit) {
        if (unit != null) onChanged(unit);
      },
    );
  }
}

class _SelectedUnit extends StatelessWidget {
  const _SelectedUnit({required this.unit});

  final ConversionUnit unit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(unit.name, overflow: TextOverflow.ellipsis)),
      const SizedBox(width: 8),
      Text(
        unit.symbol,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _UnitMenuItem extends StatelessWidget {
  const _UnitMenuItem({required this.unit, required this.selected});

  final ConversionUnit unit;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer
                : colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            unit.symbol,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? colors.primary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(unit.name, overflow: TextOverflow.ellipsis)),
        if (selected) ...[
          const SizedBox(width: 8),
          Icon(Icons.check_rounded, size: 20, color: colors.primary),
        ],
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    super.key,
    required this.value,
    required this.unit,
    required this.hasResult,
    required this.onCopy,
  });
  final String value;
  final String unit;
  final bool hasResult;
  final VoidCallback onCopy;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, const Color(0xFF223F9D)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: .2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESULT',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: .78),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: .8),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Copy result',
            onPressed: hasResult ? onCopy : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: .16),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white.withValues(alpha: .08),
              disabledForegroundColor: Colors.white.withValues(alpha: .4),
            ),
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
    );
  }
}
