import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';
import 'package:renkevia/src/features/evidence_vault/evidence_vault_page.dart';
import 'package:renkevia/src/features/patch_studio/patch_studio_page.dart';
import 'package:renkevia/src/features/response_room/response_room_page.dart';
import 'package:renkevia/src/features/simulation_lab/simulation_lab_page.dart';
import 'package:renkevia/src/features/workspace/demo_run_controller.dart';
import 'package:renkevia/src/shared/renkevia_brand.dart';
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
                return _MobileWorkspace(controller: controller);
              }
              final compact = constraints.maxWidth < 1260;
              return Row(
                children: [
                  _NavigationRail(controller: controller, compact: compact),
                  Expanded(
                    child: Column(
                      children: [
                        _CommandBar(controller: controller),
                        if (controller.lastGatewayError case final error?)
                          _GatewayErrorBanner(message: error),
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

class _MobileWorkspace extends StatelessWidget {
  const _MobileWorkspace({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = WorkspaceSection.values.indexOf(controller.section);
    return SafeArea(
      child: Column(
        children: [
          _MobileCommandBar(controller: controller),
          if (controller.lastGatewayError case final error?)
            _GatewayErrorBanner(message: error),
          Expanded(child: _SectionBody(controller: controller)),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: RenkeviaColors.surface,
              border: Border(top: BorderSide(color: RenkeviaColors.hairline)),
            ),
            child: NavigationBar(
              key: const Key('mobile-workspace-navigation'),
              height: 72,
              selectedIndex: selectedIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (index) =>
                  controller.selectSection(WorkspaceSection.values[index]),
              destinations: const [
                NavigationDestination(
                  key: Key('mobile-nav-response-room'),
                  icon: Icon(Icons.hub_outlined),
                  selectedIcon: Icon(Icons.hub_rounded),
                  label: 'Impact',
                  tooltip: 'Impact review',
                ),
                NavigationDestination(
                  key: Key('mobile-nav-patch-studio'),
                  icon: Icon(Icons.difference_outlined),
                  selectedIcon: Icon(Icons.difference_rounded),
                  label: 'Plan',
                  tooltip: 'Change plan',
                ),
                NavigationDestination(
                  key: Key('mobile-nav-simulation-lab'),
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'Test',
                  tooltip: 'Safety checks',
                ),
                NavigationDestination(
                  key: Key('mobile-nav-evidence-vault'),
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2_rounded),
                  label: 'Approve',
                  tooltip: 'Approval record',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileCommandBar extends StatelessWidget {
  const _MobileCommandBar({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final sectionLabel = switch (controller.section) {
      WorkspaceSection.responseRoom => 'Impact review',
      WorkspaceSection.patchStudio => 'Change plan',
      WorkspaceSection.simulationLab => 'Safety checks',
      WorkspaceSection.evidenceVault => 'Approval record',
    };
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: RenkeviaColors.surface,
        border: Border(bottom: BorderSide(color: RenkeviaColors.hairline)),
      ),
      child: Row(
        children: [
          const RenkeviaMark(size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RENKEVIA',
                  maxLines: 1,
                  style: TextStyle(
                    color: RenkeviaColors.ink,
                    fontSize: 12,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$sectionLabel • Northstar UH',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: RenkeviaColors.inkMuted,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          StatusPill(
            label: controller.executionModeLabel == 'LIVE GPT-5.6'
                ? 'LIVE'
                : (controller.isConnectedCore ? 'CONNECTED' : 'DEMO'),
            icon: controller.isConnectedCore
                ? Icons.cable_rounded
                : Icons.replay_outlined,
            foreground: controller.isConnectedCore
                ? RenkeviaColors.cyanDark
                : RenkeviaColors.violet,
            background: controller.isConnectedCore
                ? RenkeviaColors.cyanWash
                : const Color(0xFFEDEBF6),
          ),
          const SizedBox(width: 7),
          const Tooltip(
            message: 'Synthetic scenario • no patient data',
            child: Icon(
              Icons.shield_outlined,
              color: RenkeviaColors.cyanDark,
              size: 20,
            ),
          ),
          IconButton(
            key: const Key('mobile-reset-fixture'),
            onPressed: controller.resetFixture,
            tooltip: 'Restart guided review',
            icon: const Icon(Icons.restart_alt_rounded, size: 20),
          ),
        ],
      ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1000;
          return Row(
            children: [
              Icon(_sectionIcon(controller.section), size: 18),
              const SizedBox(width: 9),
              Text(
                _sectionLabel(controller.section),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: 12),
              if (!compact) ...[const _DividerDot(), const SizedBox(width: 12)],
              Expanded(
                child: Text(
                  compact
                      ? 'Northstar UH'
                      : 'Northstar University Hospital • shortage review',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RenkeviaColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              StatusPill(
                label: compact ? 'SYNTHETIC' : 'SYNTHETIC • NO PATIENT DATA',
                icon: Icons.shield_outlined,
                foreground: RenkeviaColors.cyanDark,
                background: RenkeviaColors.cyanWash,
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: compact
                    ? (controller.executionModeLabel == 'LIVE GPT-5.6'
                          ? 'LIVE'
                          : (controller.isConnectedCore ? 'CONNECTED' : 'DEMO'))
                    : controller.executionModeLabel,
                icon: controller.isConnectedCore
                    ? Icons.cable_rounded
                    : Icons.replay_outlined,
                foreground: controller.isConnectedCore
                    ? RenkeviaColors.cyanDark
                    : RenkeviaColors.violet,
                background: controller.isConnectedCore
                    ? RenkeviaColors.cyanWash
                    : const Color(0xFFEDEBF6),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: controller.resetFixture,
                tooltip: 'Restart guided review',
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
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GatewayErrorBanner extends StatelessWidget {
  const _GatewayErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        key: const Key('gateway-error-banner'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        color: RenkeviaColors.dangerWash,
        child: Row(
          children: [
            const Icon(
              Icons.gpp_bad_outlined,
              color: RenkeviaColors.danger,
              size: 17,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: RenkeviaColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
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
                  ? const Center(
                      child: RenkeviaMark(size: 38, foreground: Colors.white),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: RenkeviaWordmark(onDark: true),
                      ),
                    ),
            ),
            if (!compact)
              const Padding(
                padding: EdgeInsets.fromLTRB(19, 3, 19, 15),
                child: Text(
                  'ONE CHANGE • EVERY DEPENDENCY',
                  style: TextStyle(
                    color: Color(0xFF8FA2A0),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            _NavItem(
              compact: compact,
              selected: controller.section == WorkspaceSection.responseRoom,
              icon: Icons.hub_outlined,
              label: 'Impact review',
              detail: 'Understand who & what changes',
              onTap: () =>
                  controller.selectSection(WorkspaceSection.responseRoom),
            ),
            _NavItem(
              compact: compact,
              selected: controller.section == WorkspaceSection.patchStudio,
              icon: Icons.difference_outlined,
              label: 'Change plan',
              detail: 'Synchronize every system',
              onTap: () =>
                  controller.selectSection(WorkspaceSection.patchStudio),
            ),
            _NavItem(
              compact: compact,
              selected: controller.section == WorkspaceSection.simulationLab,
              icon: Icons.grid_view_outlined,
              label: 'Safety checks',
              detail: 'Test patient pathways',
              onTap: () =>
                  controller.selectSection(WorkspaceSection.simulationLab),
            ),
            _NavItem(
              compact: compact,
              selected: controller.section == WorkspaceSection.evidenceVault,
              icon: Icons.inventory_2_outlined,
              label: 'Approval record',
              detail: 'Review proof & rollback',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_clock_outlined,
                          color: RenkeviaColors.amber,
                          size: 15,
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'HUMAN DECISION REQUIRED',
                            maxLines: 2,
                            style: TextStyle(
                              color: RenkeviaColors.amber,
                              fontSize: 10,
                              height: 1.25,
                              letterSpacing: 0.7,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'RENKEVIA can prepare and verify changes. Only a named person can approve them.',
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
                            fontSize: 10,
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

String _sectionLabel(WorkspaceSection section) => switch (section) {
  WorkspaceSection.responseRoom => 'Impact review',
  WorkspaceSection.patchStudio => 'Change plan',
  WorkspaceSection.simulationLab => 'Safety checks',
  WorkspaceSection.evidenceVault => 'Approval record',
};

IconData _sectionIcon(WorkspaceSection section) => switch (section) {
  WorkspaceSection.responseRoom => Icons.hub_outlined,
  WorkspaceSection.patchStudio => Icons.difference_outlined,
  WorkspaceSection.simulationLab => Icons.fact_check_outlined,
  WorkspaceSection.evidenceVault => Icons.approval_outlined,
};

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return switch (controller.section) {
      WorkspaceSection.responseRoom => ResponseRoomPage(controller: controller),
      WorkspaceSection.patchStudio => PatchStudioPage(controller: controller),
      WorkspaceSection.simulationLab => SimulationLabPage(
        controller: controller,
      ),
      WorkspaceSection.evidenceVault => EvidenceVaultPage(
        controller: controller,
      ),
    };
  }
}
