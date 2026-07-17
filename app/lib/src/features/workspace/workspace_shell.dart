import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';
import 'package:renkevia/src/features/response_room/response_room_page.dart';
import 'package:renkevia/src/features/workspace/demo_run_controller.dart';
import 'package:renkevia/src/shared/status_pill.dart';

class WorkspaceShell extends StatelessWidget {
  const WorkspaceShell({super.key, required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 920) {
                return const _DesktopRequired();
              }
              final compact = constraints.maxWidth < 1260;
              return Row(
                children: [
                  _NavigationRail(controller: controller, compact: compact),
                  Expanded(
                    child: Column(
                      children: [
                        _CommandBar(controller: controller),
                        Expanded(child: _SectionBody(controller: controller)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _CommandBar extends StatelessWidget {
  const _CommandBar({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        color: RenkeviaColors.surface,
        border: Border(bottom: BorderSide(color: RenkeviaColors.hairline)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_tree_outlined, size: 17),
          const SizedBox(width: 9),
          Text('RUN 24-0717-A', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 12),
          const _DividerDot(),
          const SizedBox(width: 12),
          Text(
            'Northstar University Hospital',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: RenkeviaColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const StatusPill(
            label: 'SYNTHETIC • NO PHI',
            icon: Icons.shield_outlined,
            foreground: RenkeviaColors.cyanDark,
            background: RenkeviaColors.cyanWash,
          ),
          const SizedBox(width: 8),
          const StatusPill(
            label: 'FIXTURE REPLAY',
            icon: Icons.replay_outlined,
            foreground: RenkeviaColors.violet,
            background: Color(0xFFEDEBF6),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: controller.resetFixture,
            tooltip: 'Reset synthetic run',
            icon: const Icon(Icons.restart_alt_rounded, size: 19),
          ),
          const SizedBox(width: 2),
          const CircleAvatar(
            radius: 15,
            backgroundColor: RenkeviaColors.graphite,
            child: Text(
              'AM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerDot extends StatelessWidget {
  const _DividerDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: RenkeviaColors.inkMuted,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({required this.controller, required this.compact});

  final DemoRunController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 78.0 : 224.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      color: RenkeviaColors.graphite,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 76,
              child: compact
                  ? const Center(child: _BrandMark())
                  : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19),
                      child: Row(
                        children: [
                          _BrandMark(),
                          SizedBox(width: 11),
                          Text(
                            'RENKEVIA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (!compact)
              const Padding(
                padding: EdgeInsets.fromLTRB(19, 3, 19, 15),
                child: Text(
                  'CHANGE COMPILER / 01',
                  style: TextStyle(
                    color: Color(0xFF8FA2A0),
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            _NavItem(
              compact: compact,
              selected: controller.section == WorkspaceSection.responseRoom,
              icon: Icons.hub_outlined,
              label: 'Response Room',
              detail: 'Map blast radius',
              onTap: () =>
                  controller.selectSection(WorkspaceSection.responseRoom),
            ),
            _NavItem(
              compact: compact,
              selected: controller.section == WorkspaceSection.patchStudio,
              icon: Icons.difference_outlined,
              label: 'Patch Studio',
              detail: 'Compile artifacts',
              onTap: () =>
                  controller.selectSection(WorkspaceSection.patchStudio),
            ),
            _NavItem(
              compact: compact,
              selected: controller.section == WorkspaceSection.simulationLab,
              icon: Icons.grid_view_outlined,
              label: 'Simulation Lab',
              detail: 'Test pathways',
              onTap: () =>
                  controller.selectSection(WorkspaceSection.simulationLab),
            ),
            _NavItem(
              compact: compact,
              selected: controller.section == WorkspaceSection.evidenceVault,
              icon: Icons.inventory_2_outlined,
              label: 'Evidence Vault',
              detail: 'Prove & rollback',
              onTap: () =>
                  controller.selectSection(WorkspaceSection.evidenceVault),
            ),
            const Spacer(),
            if (!compact)
              Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  border: Border.all(color: RenkeviaColors.hairlineDark),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_clock_outlined,
                          color: RenkeviaColors.amber,
                          size: 15,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'APPROVAL LOCKED',
                          style: TextStyle(
                            color: RenkeviaColors.amber,
                            fontSize: 9,
                            letterSpacing: 0.7,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Final writes remain outside the model capability set.',
                      style: TextStyle(
                        color: Color(0xFFAAB8B6),
                        fontSize: 10,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(bottom: 22),
                child: Tooltip(
                  message: 'Approval locked',
                  child: Icon(
                    Icons.lock_clock_outlined,
                    color: RenkeviaColors.amber,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        border: Border.all(color: RenkeviaColors.cyan, width: 1.5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Center(
        child: Text(
          'R',
          style: TextStyle(
            color: RenkeviaColors.cyan,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.compact,
    required this.selected,
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final bool compact;
  final bool selected;
  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(
          horizontal: compact ? 11 : 10,
          vertical: 3,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 0 : 11,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF253433) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? const Border(
                  left: BorderSide(color: RenkeviaColors.cyan, width: 2),
                )
              : null,
        ),
        child: compact
            ? Icon(
                icon,
                color: selected ? RenkeviaColors.cyan : const Color(0xFF91A09F),
                size: 20,
              )
            : Row(
                children: [
                  Icon(
                    icon,
                    color: selected
                        ? RenkeviaColors.cyan
                        : const Color(0xFF91A09F),
                    size: 19,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFFCAD2D1),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          style: const TextStyle(
                            color: Color(0xFF82908E),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
    return compact ? Tooltip(message: label, child: content) : content;
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return switch (controller.section) {
      WorkspaceSection.responseRoom => ResponseRoomPage(controller: controller),
      WorkspaceSection.patchStudio => const _ComingSection(
        eyebrow: 'PATCH STUDIO / 02',
        title: 'One Patch IR. Six synchronized artifacts.',
        detail:
            'This surface unlocks after the dependency graph reaches a reviewable candidate.',
        icon: Icons.difference_outlined,
      ),
      WorkspaceSection.simulationLab => const _ComingSection(
        eyebrow: 'SIMULATION LAB / 03',
        title: 'Patient pathways become executable assertions.',
        detail:
            'The red-to-green regression matrix is the next vertical slice.',
        icon: Icons.grid_view_outlined,
      ),
      WorkspaceSection.evidenceVault => const _ComingSection(
        eyebrow: 'EVIDENCE VAULT / 04',
        title: 'Every mutation carries its proof and rollback.',
        detail:
            'Provenance, audit events, approvals, and exact restoration converge here.',
        icon: Icons.inventory_2_outlined,
      ),
    };
  }
}

class _ComingSection extends StatelessWidget {
  const _ComingSection({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: RenkeviaColors.cyanWash,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: RenkeviaColors.cyanDark),
              ),
              const SizedBox(height: 20),
              Text(eyebrow, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopRequired extends StatelessWidget {
  const _DesktopRequired();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RenkeviaColors.graphite,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BrandMark(),
                const SizedBox(height: 22),
                const Text(
                  'Institutional workspace requires a larger canvas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Open RENKEVIA at 1024px or wider to inspect synchronized evidence, graphs, and diffs safely.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFB8C4C2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
