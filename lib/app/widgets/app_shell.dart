import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../router.dart';

/// Hosts the StampMail bottom bar around the four authenticated branches —
/// Home · Inbox · Album · Profile — with the coral create FAB docked in the
/// middle, per `pencil-new.pen` Navigation/TabBar (SM-004 BR-04/BR-05).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: StampMailCreateFab(
        onPressed: () => const CreateStampRoute().go(context),
      ),
      bottomNavigationBar: StampMailTabBar(
        currentIndex: navigationShell.currentIndex,
        onSelect: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

/// The docked coral create button (design: `fabWrap` 56px circle).
class StampMailCreateFab extends StatelessWidget {
  const StampMailCreateFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: const CircleBorder(),
      child: const FaIcon(FontAwesomeIcons.plus, size: 24),
    );
  }
}

/// The four-tab bottom bar with the center slot left open for the docked FAB.
///
/// Extracted from [AppShell] so the design-preview harness can wrap arbitrary
/// screens in the same chrome without a [StatefulNavigationShell].
class StampMailTabBar extends StatelessWidget {
  const StampMailTabBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return BottomAppBar(
      color: scheme.surfaceContainerLowest,
      elevation: 8,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _Tab(
            icon: FontAwesomeIcons.house,
            selectedIcon: FontAwesomeIcons.house,
            label: l10n.navHome,
            selected: currentIndex == 0,
            onTap: () => onSelect(0),
          ),
          _Tab(
            icon: FontAwesomeIcons.envelope,
            selectedIcon: FontAwesomeIcons.solidEnvelope,
            label: l10n.navLetters,
            selected: currentIndex == 1,
            onTap: () => onSelect(1),
          ),
          // Slot for the docked create FAB (design: fabWrap).
          const Spacer(),
          _Tab(
            icon: FontAwesomeIcons.images,
            selectedIcon: FontAwesomeIcons.solidImages,
            label: l10n.navAlbum,
            selected: currentIndex == 2,
            onTap: () => onSelect(2),
          ),
          _Tab(
            icon: FontAwesomeIcons.user,
            selectedIcon: FontAwesomeIcons.solidUser,
            label: l10n.navProfile,
            selected: currentIndex == 3,
            onTap: () => onSelect(3),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final FaIconData icon;
  final FaIconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          selected: selected,
          button: true,
          label: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(selected ? selectedIcon : icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
