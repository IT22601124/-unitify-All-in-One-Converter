import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 3;
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() => context.read<AppState>().completeOnboarding();

  void _next() {
    if (_currentPage == _pageCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_currentPage == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    const AppLogo(size: 40),
                    const SizedBox(width: 12),
                    Text(
                      'Unitify',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _currentPage == _pageCount - 1 ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: _currentPage == _pageCount - 1,
                        child: TextButton(
                          onPressed: _finish,
                          child: const Text('Skip'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: const [
                    _OnboardingPage(
                      eyebrow: 'FAST & EFFORTLESS',
                      title: 'Every conversion,\nright at hand',
                      description:
                          'Explore 14 everyday categories and get accurate results as you type.',
                      illustration: _ConversionIllustration(),
                    ),
                    _OnboardingPage(
                      eyebrow: 'MADE FOR YOUR ROUTINE',
                      title: 'Save the pairs\nyou use most',
                      description:
                          'Favorite useful unit pairs and jump back into recent conversions in one tap.',
                      illustration: _FavoritesIllustration(),
                    ),
                    _OnboardingPage(
                      eyebrow: 'PRIVATE BY DESIGN',
                      title: 'Works anywhere.\nStays on your device.',
                      description:
                          'No account, no ads, and conversions work offline. Your preferences and history stay local.',
                      illustration: _PrivacyIllustration(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    Semantics(
                      label: 'Page ${_currentPage + 1} of $_pageCount',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pageCount,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: index == _currentPage ? 28 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: index == _currentPage
                                  ? colors.primary
                                  : colors.outlineVariant,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        if (_currentPage > 0) ...[
                          IconButton.outlined(
                            tooltip: 'Previous page',
                            onPressed: _back,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: FilledButton(
                            key: const Key('onboarding-primary-button'),
                            onPressed: _next,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == _pageCount - 1
                                      ? 'Start converting'
                                      : 'Continue',
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.illustration,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget illustration;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            illustration,
            const SizedBox(height: 32),
            Text(
              eyebrow,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontSize: 34, height: 1.12),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _IllustrationFrame extends StatelessWidget {
  const _IllustrationFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 286,
      height: 224,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: .78),
            colors.secondaryContainer.withValues(alpha: .5),
          ],
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: child,
    );
  }
}

class _ConversionIllustration extends StatelessWidget {
  const _ConversionIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _IllustrationFrame(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Card(
              color: colors.surface,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LENGTH', style: _microStyle(context)),
                    const Spacer(),
                    const _ValueRow(value: '1', unit: 'Kilometer'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: colors.outlineVariant),
                    ),
                    const _ValueRow(value: '0.621371', unit: 'Miles'),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -10,
            top: 68,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: .3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.swap_vert_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.value, required this.unit});
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      Text(unit, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}

class _FavoritesIllustration extends StatelessWidget {
  const _FavoritesIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _IllustrationFrame(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PairCard(
            icon: Icons.straighten_rounded,
            color: const Color(0xFF8B5CF6),
            title: 'Meters  →  Feet',
            detail: 'Length',
          ),
          const SizedBox(height: 8),
          _PairCard(
            icon: Icons.thermostat_rounded,
            color: const Color(0xFFF97316),
            title: 'Celsius  →  Fahrenheit',
            detail: 'Temperature',
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_rounded, color: Colors.white, size: 15),
                  SizedBox(width: 5),
                  Text(
                    'Saved',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PairCard extends StatelessWidget {
  const _PairCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              Text(detail, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Icon(
          Icons.favorite_rounded,
          size: 19,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    ),
  );
}

class _PrivacyIllustration extends StatelessWidget {
  const _PrivacyIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _IllustrationFrame(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 134,
            height: 134,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: .14),
                  blurRadius: 26,
                ),
              ],
            ),
            child: Icon(Icons.shield_rounded, size: 74, color: colors.primary),
          ),
          const Positioned(
            left: 10,
            top: 22,
            child: _FeatureBubble(icon: Icons.wifi_off_rounded),
          ),
          const Positioned(
            right: 4,
            top: 32,
            child: _FeatureBubble(icon: Icons.person_off_outlined),
          ),
          const Positioned(
            right: 24,
            bottom: 2,
            child: _FeatureBubble(icon: Icons.speed_rounded),
          ),
        ],
      ),
    );
  }
}

class _FeatureBubble extends StatelessWidget {
  const _FeatureBubble({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .08),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 22),
  );
}

TextStyle? _microStyle(BuildContext context) =>
    Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
    );
