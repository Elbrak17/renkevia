import 'package:flutter/material.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_fixture.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_sandbox_controller.dart';

abstract final class _LegacyColors {
  static const navy = Color(0xFF163A59);
  static const navyDark = Color(0xFF102B43);
  static const blue = Color(0xFF236A9B);
  static const blueWash = Color(0xFFE2EFF7);
  static const canvas = Color(0xFFE8EDF1);
  static const surface = Colors.white;
  static const ink = Color(0xFF1B2A36);
  static const muted = Color(0xFF5D6F7B);
  static const line = Color(0xFFCBD4DA);
  static const success = Color(0xFF287A52);
  static const successWash = Color(0xFFE4F2E9);
  static const warning = Color(0xFFA56912);
  static const warningWash = Color(0xFFFFF1D6);
  static const danger = Color(0xFFB43B34);
  static const dangerWash = Color(0xFFFBE4E2);
}

class LegacyEhrSandboxPage extends StatefulWidget {
  const LegacyEhrSandboxPage({super.key, this.standalone = false});

  final bool standalone;

  @override
  State<LegacyEhrSandboxPage> createState() => _LegacyEhrSandboxPageState();
}

class _LegacyEhrSandboxPageState extends State<LegacyEhrSandboxPage> {
  late final LegacyEhrSandboxController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = LegacyEhrSandboxController();
    _searchController = TextEditingController(text: 'EHR-OS-014');
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return _LegacyCompactCompanion(
                  controller: _controller,
                  standalone: widget.standalone,
                );
              }
              return Column(
                children: [
                  _LegacyTopBar(
                    controller: _controller,
                    standalone: widget.standalone,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const _LegacyNavigation(),
                        Expanded(
                          child: _LegacyWorkspace(
                            controller: _controller,
                            searchController: _searchController,
                            standalone: widget.standalone,
                          ),
                        ),
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

class _LegacyTopBar extends StatelessWidget {
  const _LegacyTopBar({required this.controller, required this.standalone});

  final LegacyEhrSandboxController controller;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      color: _LegacyColors.navyDark,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FA),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text(
              'N',
              style: TextStyle(
                color: _LegacyColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NORTHSTAR CLINICAL SYSTEM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Legacy Configuration Console • release 8.4',
                style: TextStyle(color: Color(0xFFAFC3D1), fontSize: 9),
              ),
            ],
          ),
          const Spacer(),
          const _LegacyBadge(
            label: 'FICTIONAL • NO PHI',
            icon: Icons.shield_outlined,
            color: Color(0xFF96D3BC),
          ),
          const SizedBox(width: 8),
          const _LegacyBadge(
            label: 'STAGING ENVIRONMENT',
            icon: Icons.science_outlined,
            color: Color(0xFFFFD37E),
          ),
          const SizedBox(width: 14),
          if (!standalone)
            IconButton(
              tooltip: 'Return to RENKEVIA',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            )
          else
            const _LegacyBadge(
              label: 'COMPUTER USE TARGET',
              icon: Icons.computer_outlined,
              color: Color(0xFFAFCDE0),
            ),
        ],
      ),
    );
  }
}

class _LegacyBadge extends StatelessWidget {
  const _LegacyBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelText = Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 8,
              letterSpacing: 0.45,
              fontWeight: FontWeight.w800,
            ),
          );
          if (constraints.hasBoundedWidth) {
            return Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(icon, size: 12, color: color),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(text: label),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelText.style,
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 5),
              labelText,
            ],
          );
        },
      ),
    );
  }
}

class _LegacyNavigation extends StatelessWidget {
  const _LegacyNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 205,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7F8),
        border: Border(right: BorderSide(color: _LegacyColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 16, 15, 8),
            child: Text(
              'CONFIGURATION MODULES',
              style: TextStyle(
                color: _LegacyColors.muted,
                fontSize: 8,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const _LegacyNavItem(
            icon: Icons.assignment_outlined,
            label: 'Order Sets',
            selected: true,
          ),
          const _LegacyNavItem(
            icon: Icons.medication_outlined,
            label: 'Medication Dictionary',
          ),
          const _LegacyNavItem(
            icon: Icons.account_tree_outlined,
            label: 'Clinical Rules',
          ),
          const _LegacyNavItem(
            icon: Icons.print_outlined,
            label: 'Labels & Forms',
          ),
          const _LegacyNavItem(
            icon: Icons.history_outlined,
            label: 'Change History',
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _LegacyColors.warningWash,
              border: Border.all(color: const Color(0xFFE8C98D)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_clock_outlined,
                      size: 14,
                      color: _LegacyColors.warning,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'STAGING ONLY',
                      style: TextStyle(
                        color: _LegacyColors.warning,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Production commit requires a named human approval outside this sandbox.',
                  style: TextStyle(
                    color: Color(0xFF725319),
                    fontSize: 8.5,
                    height: 1.35,
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

class _LegacyNavItem extends StatelessWidget {
  const _LegacyNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: selected ? _LegacyColors.blueWash : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: selected ? _LegacyColors.blue : Colors.transparent,
            width: 3,
          ),
          bottom: const BorderSide(color: Color(0xFFE1E6E9)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? _LegacyColors.blue : _LegacyColors.muted,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? _LegacyColors.navy : _LegacyColors.muted,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegacyWorkspace extends StatelessWidget {
  const _LegacyWorkspace({
    required this.controller,
    required this.searchController,
    required this.standalone,
  });

  final LegacyEhrSandboxController controller;
  final TextEditingController searchController;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _LegacyColors.canvas,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WorkspaceHeading(controller: controller),
            const SizedBox(height: 12),
            _SearchToolbar(
              controller: controller,
              searchController: searchController,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _LegacyMainPanel(
                      controller: controller,
                      standalone: standalone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 285,
                    child: _ActionTrace(controller: controller),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceHeading extends StatelessWidget {
  const _WorkspaceHeading({required this.controller});

  final LegacyEhrSandboxController controller;

  @override
  Widget build(BuildContext context) {
    final staged = controller.isStaged;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ORDER SET MAINTENANCE / STAGING',
                style: TextStyle(
                  color: _LegacyColors.blue,
                  fontSize: 8.5,
                  letterSpacing: 0.65,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                staged
                    ? 'Change staged — final commit withheld'
                    : 'Locate and stage an order-set revision',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: staged
                ? _LegacyColors.successWash
                : _LegacyColors.warningWash,
            border: Border.all(
              color: staged
                  ? _LegacyColors.success.withValues(alpha: 0.4)
                  : const Color(0xFFE2BF77),
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Icon(
                staged ? Icons.verified_outlined : Icons.info_outline_rounded,
                size: 14,
                color: staged ? _LegacyColors.success : _LegacyColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                staged ? 'PROOF CAPTURED' : 'SYNTHETIC FIXTURE',
                style: TextStyle(
                  color: staged ? _LegacyColors.success : _LegacyColors.warning,
                  fontSize: 8,
                  letterSpacing: 0.45,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchToolbar extends StatelessWidget {
  const _SearchToolbar({
    required this.controller,
    required this.searchController,
  });

  final LegacyEhrSandboxController controller;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final searching = controller.state == LegacySandboxState.searching;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _LegacyColors.surface,
        border: Border.all(color: _LegacyColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 112,
            child: Text(
              'Order set ID',
              style: TextStyle(
                color: _LegacyColors.ink,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                key: const Key('legacy-search-field'),
                controller: searchController,
                enabled: !controller.hasInspected,
                textInputAction: TextInputAction.search,
                onSubmitted: controller.search,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(),
                  hintText: 'Enter exact identifier',
                  prefixIcon: Icon(Icons.search_rounded, size: 17),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            child: FilledButton.icon(
              key: const Key('legacy-search-button'),
              onPressed: controller.hasInspected || searching
                  ? null
                  : () => controller.search(searchController.text),
              style: FilledButton.styleFrom(
                backgroundColor: _LegacyColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              icon: searching
                  ? const SizedBox.square(
                      dimension: 13,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.search_rounded, size: 16),
              label: Text(searching ? 'Searching…' : 'Find order set'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            child: OutlinedButton.icon(
              key: const Key('legacy-reset-button'),
              onPressed: controller.reset,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegacyMainPanel extends StatelessWidget {
  const _LegacyMainPanel({required this.controller, required this.standalone});

  final LegacyEhrSandboxController controller;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _LegacyColors.surface,
        border: Border.all(color: _LegacyColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: switch (controller.state) {
        LegacySandboxState.locate ||
        LegacySandboxState.searching => _LocatePanel(controller: controller),
        LegacySandboxState.result => _SearchResult(controller: controller),
        _ => _OrderSetDetail(controller: controller, standalone: standalone),
      },
    );
  }
}

class _LocatePanel extends StatelessWidget {
  const _LocatePanel({required this.controller});

  final LegacyEhrSandboxController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _LegacyColors.blueWash,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(
                Icons.manage_search_outlined,
                color: _LegacyColors.blue,
                size: 25,
              ),
            ),
            const SizedBox(height: 13),
            Text(
              controller.message ?? 'Locate a staging order set',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: controller.message == null
                    ? _LegacyColors.ink
                    : _LegacyColors.danger,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'This fictional console exposes no API. Every inspection and staging action must occur through the visible interface.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({required this.controller});

  final LegacyEhrSandboxController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _LegacyPanelHeader(
          title: 'Search results',
          detail: '1 exact match in STAGING',
        ),
        const _LegacyTableHeader(
          columns: ['IDENTIFIER', 'NAME', 'REVISION', 'STATE', 'ACTION'],
        ),
        Container(
          key: const Key('legacy-result-EHR-OS-014'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _LegacyColors.line)),
          ),
          child: Row(
            children: [
              const Expanded(child: _LegacyCell('EHR-OS-014', strong: true)),
              const Expanded(
                flex: 2,
                child: _LegacyCell('Adult IV therapy order set'),
              ),
              const Expanded(child: _LegacyCell('v14')),
              const Expanded(
                child: _LegacyStateLabel(
                  label: 'ACTIVE FIXTURE',
                  color: _LegacyColors.blue,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    key: const Key('legacy-open-order-set-button'),
                    onPressed: controller.inspectOrderSet,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderSetDetail extends StatelessWidget {
  const _OrderSetDetail({required this.controller, required this.standalone});

  final LegacyEhrSandboxController controller;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final driftBlocked = state == LegacySandboxState.driftBlocked;
    final compared = state == LegacySandboxState.compared;
    final prepared = state == LegacySandboxState.prepared;
    final staging = state == LegacySandboxState.staging;
    final staged = state == LegacySandboxState.staged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LegacyPanelHeader(
          title: 'EHR-OS-014 • Adult IV therapy order set',
          detail: staged
              ? 'Staged revision v0.8 • final write withheld'
              : 'Current revision v14 • inspected through visible UI',
          trailing: _LegacyStateLabel(
            label: staged
                ? 'AWAITING HUMAN APPROVAL'
                : (driftBlocked ? 'STATE DRIFT' : 'STAGING'),
            color: staged
                ? _LegacyColors.warning
                : (driftBlocked ? _LegacyColors.danger : _LegacyColors.blue),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OrderSetMetadata(controller: controller),
                const SizedBox(height: 11),
                if (driftBlocked)
                  _DriftBlock(controller: controller)
                else if (staged)
                  _StagedProof(proof: controller.proof!, standalone: standalone)
                else ...[
                  if (compared || prepared || staging)
                    const _PatchComparison()
                  else
                    const _CurrentConfiguration(),
                  const SizedBox(height: 12),
                  _DetailActions(controller: controller),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderSetMetadata extends StatelessWidget {
  const _OrderSetMetadata({required this.controller});

  final LegacyEhrSandboxController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F9),
        border: Border.all(color: _LegacyColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 8,
        children: [
          const _MetadataPair(label: 'SYSTEM ID', value: 'EHR-OS-014'),
          const _MetadataPair(label: 'CURRENT REVISION', value: 'v14'),
          const _MetadataPair(label: 'ENVIRONMENT', value: 'STAGING'),
          _MetadataPair(label: 'OBSERVED HASH', value: controller.screenHash),
          const _MetadataPair(label: 'EXPECTED HASH', value: 'B711-02EF'),
        ],
      ),
    );
  }
}

class _MetadataPair extends StatelessWidget {
  const _MetadataPair({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _LegacyColors.muted,
              fontSize: 7.5,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: _LegacyColors.ink,
              fontFamily: 'RenkeviaMono',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentConfiguration extends StatelessWidget {
  const _CurrentConfiguration();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _LegacyColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LegacySubHeader(
            title: 'Current visible configuration',
            label: 'REVISION v14',
          ),
          _ConfigRow(label: 'Default population branch', value: 'ADULT'),
          _ConfigRow(label: 'Exception reference', value: 'Not represented'),
          _ConfigRow(label: 'Change-control ticket', value: 'CHANGE-811'),
          _ConfigRow(
            label: 'Last visual inspection',
            value: 'Fixture baseline',
          ),
        ],
      ),
    );
  }
}

class _PatchComparison extends StatelessWidget {
  const _PatchComparison();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _LegacyColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _LegacySubHeader(
            title: 'Visual comparison with RENKEVIA Patch IR',
            label: 'CANDIDATE v0.8',
          ),
          const _LegacyTableHeader(
            columns: [
              'SECTION / FIELD',
              'CURRENT v14',
              'CANDIDATE v0.8',
              'SOURCE',
            ],
          ),
          for (final delta in legacyFieldDeltas)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _LegacyColors.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delta.field,
                          style: const TextStyle(
                            color: _LegacyColors.ink,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          delta.section,
                          style: const TextStyle(
                            color: _LegacyColors.muted,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _LegacyCell(delta.currentValue)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 5,
                      ),
                      color: _LegacyColors.successWash,
                      child: Text(
                        delta.candidateValue,
                        style: const TextStyle(
                          color: _LegacyColors.success,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _LegacyCell(delta.source, mono: true)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({required this.controller});

  final LegacyEhrSandboxController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final comparing = state == LegacySandboxState.comparing;
    final prepared = state == LegacySandboxState.prepared;
    final staging = state == LegacySandboxState.staging;
    return Row(
      children: [
        if (state == LegacySandboxState.inspected)
          OutlinedButton.icon(
            key: const Key('legacy-simulate-drift-button'),
            onPressed: controller.simulateScreenDrift,
            icon: const Icon(Icons.warning_amber_rounded, size: 16),
            label: const Text('Inject synthetic screen drift'),
          ),
        const Spacer(),
        if (state == LegacySandboxState.inspected || comparing)
          FilledButton.icon(
            key: const Key('legacy-compare-button'),
            onPressed: comparing ? null : controller.compareWithPatch,
            style: _legacyPrimaryButtonStyle(),
            icon: comparing
                ? const SizedBox.square(
                    dimension: 13,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.compare_arrows_rounded, size: 16),
            label: Text(
              comparing ? 'Rechecking screen state…' : 'Compare Patch IR v0.8',
            ),
          )
        else if (state == LegacySandboxState.compared)
          FilledButton.icon(
            key: const Key('legacy-prepare-button'),
            onPressed: controller.prepareStaging,
            style: _legacyPrimaryButtonStyle(),
            icon: const Icon(Icons.edit_note_outlined, size: 17),
            label: const Text('Prepare staging change'),
          )
        else if (prepared || staging)
          FilledButton.icon(
            key: const Key('legacy-stage-button'),
            onPressed: staging ? null : controller.stageChange,
            style: _legacyPrimaryButtonStyle(),
            icon: staging
                ? const SizedBox.square(
                    dimension: 13,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_as_outlined, size: 16),
            label: Text(
              staging ? 'Capturing proof…' : 'Stage change and capture proof',
            ),
          ),
      ],
    );
  }
}

ButtonStyle _legacyPrimaryButtonStyle() => FilledButton.styleFrom(
  backgroundColor: _LegacyColors.blue,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
);

class _DriftBlock extends StatelessWidget {
  const _DriftBlock({required this.controller});

  final LegacyEhrSandboxController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('legacy-drift-blocker'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _LegacyColors.dangerWash,
        border: Border.all(color: _LegacyColors.danger.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.block_outlined, color: _LegacyColors.danger, size: 20),
              SizedBox(width: 8),
              Text(
                'STAGING BLOCKED • SCREEN STATE CHANGED',
                style: TextStyle(
                  color: _LegacyColors.danger,
                  fontSize: 9.5,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.message ??
                'Observed screen state no longer matches inspection.',
            style: const TextStyle(
              color: _LegacyColors.ink,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: controller.reset,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset sealed fixture'),
          ),
        ],
      ),
    );
  }
}

class _StagedProof extends StatelessWidget {
  const _StagedProof({required this.proof, required this.standalone});

  final LegacyStagingProof proof;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _LegacyColors.successWash,
            border: Border.all(
              color: _LegacyColors.success.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: _LegacyColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STAGED • AWAITING HUMAN APPROVAL',
                      style: TextStyle(
                        color: _LegacyColors.success,
                        fontSize: 10,
                        letterSpacing: 0.55,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${proof.proofId} captured after state recheck. No final commit was performed.',
                      style: const TextStyle(
                        color: _LegacyColors.ink,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F9),
            border: Border.all(color: _LegacyColors.line),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Wrap(
            spacing: 22,
            runSpacing: 12,
            children: [
              _MetadataPair(label: 'PROOF ID', value: proof.proofId),
              _MetadataPair(label: 'INSPECTED', value: proof.inspectedHash),
              _MetadataPair(label: 'RECHECKED', value: proof.recheckedHash),
              _MetadataPair(label: 'STAGED', value: proof.stagedHash),
              _MetadataPair(label: 'SCREENSHOT', value: proof.screenshotHash),
              _MetadataPair(
                label: 'ACTIONS',
                value: '${proof.actionCount} visual',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const Key('legacy-final-commit-button'),
                onPressed: null,
                style: FilledButton.styleFrom(
                  disabledBackgroundColor: const Color(0xFFD7DDE1),
                  disabledForegroundColor: _LegacyColors.muted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                icon: const Icon(Icons.lock_outline_rounded, size: 17),
                label: const Text('Final production commit • named human only'),
              ),
            ),
            if (!standalone) ...[
              const SizedBox(width: 9),
              FilledButton.icon(
                key: const Key('legacy-return-proof-button'),
                onPressed: () => Navigator.of(context).pop(proof),
                style: _legacyPrimaryButtonStyle(),
                icon: const Icon(Icons.reply_rounded, size: 17),
                label: const Text('Return proof to RENKEVIA'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ActionTrace extends StatelessWidget {
  const _ActionTrace({required this.controller});

  final LegacyEhrSandboxController controller;

  @override
  Widget build(BuildContext context) {
    const steps = <(String, String, IconData)>[
      ('SEARCH', 'Locate EHR-OS-014', Icons.search_rounded),
      ('INSPECT', 'Read visible revision + hash', Icons.visibility_outlined),
      ('RECHECK', 'Confirm screen state unchanged', Icons.fingerprint_rounded),
      ('COMPARE', 'Match Patch IR v0.8 fields', Icons.compare_arrows_rounded),
      ('PREPARE', 'Prepare staging form', Icons.edit_note_outlined),
      ('STAGE', 'Stage and capture proof', Icons.camera_alt_outlined),
    ];
    final completed = controller.completedActions;
    return Container(
      decoration: BoxDecoration(
        color: _LegacyColors.surface,
        border: Border.all(color: _LegacyColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _LegacyPanelHeader(
            title: 'Visual action trace',
            detail: 'Stable labels for Computer Use',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (var index = 0; index < steps.length; index++)
                  _TraceStep(
                    code: steps[index].$1,
                    title: steps[index].$2,
                    icon: steps[index].$3,
                    complete: completed.contains(steps[index].$1),
                    active:
                        !completed.contains(steps[index].$1) &&
                        index == completed.length,
                    last: index == steps.length - 1,
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: controller.isStaged
                        ? _LegacyColors.warningWash
                        : const Color(0xFFF4F6F7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.pan_tool_alt_outlined,
                        size: 15,
                        color: controller.isStaged
                            ? _LegacyColors.warning
                            : _LegacyColors.muted,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          controller.isStaged
                              ? 'SAFE STOP • final commit is outside the Computer Use capability set.'
                              : 'All actions occur through this visible fictional interface. No structured EHR API exists.',
                          style: TextStyle(
                            color: controller.isStaged
                                ? const Color(0xFF725319)
                                : _LegacyColors.muted,
                            fontSize: 8.5,
                            height: 1.4,
                            fontWeight: controller.isStaged
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

class _TraceStep extends StatelessWidget {
  const _TraceStep({
    required this.code,
    required this.title,
    required this.icon,
    required this.complete,
    required this.active,
    required this.last,
  });

  final String code;
  final String title;
  final IconData icon;
  final bool complete;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = complete
        ? _LegacyColors.success
        : (active ? _LegacyColors.blue : _LegacyColors.muted);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 27,
            child: Column(
              children: [
                Container(
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.11),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.6)),
                  ),
                  child: Icon(
                    complete ? Icons.check_rounded : icon,
                    size: 12,
                    color: color,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 1, color: _LegacyColors.line),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      color: color,
                      fontSize: 7.5,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      color: _LegacyColors.ink,
                      fontSize: 9,
                      height: 1.25,
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

class _LegacyPanelHeader extends StatelessWidget {
  const _LegacyPanelHeader({
    required this.title,
    required this.detail,
    this.trailing,
  });

  final String title;
  final String detail;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F6F7),
        border: Border(bottom: BorderSide(color: _LegacyColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _LegacyColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _LegacyColors.muted,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _LegacySubHeader extends StatelessWidget {
  const _LegacySubHeader({required this.title, required this.label});

  final String title;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      color: const Color(0xFFF3F6F7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _LegacyColors.ink,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _LegacyStateLabel(label: label, color: _LegacyColors.blue),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _LegacyColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _LegacyColors.muted, fontSize: 9),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _LegacyColors.ink,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegacyTableHeader extends StatelessWidget {
  const _LegacyTableHeader({required this.columns});

  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: _LegacyColors.navy,
      child: Row(
        children: [
          for (var index = 0; index < columns.length; index++)
            Expanded(
              flex: columns.length == 5 && index == 1 ? 2 : 1,
              child: Text(
                columns[index],
                style: const TextStyle(
                  color: Color(0xFFC8D9E4),
                  fontSize: 7.5,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegacyCell extends StatelessWidget {
  const _LegacyCell(this.value, {this.strong = false, this.mono = false});

  final String value;
  final bool strong;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: strong ? _LegacyColors.ink : _LegacyColors.muted,
        fontFamily: mono ? 'RenkeviaMono' : null,
        fontSize: 8.5,
        height: 1.3,
        fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _LegacyStateLabel extends StatelessWidget {
  const _LegacyStateLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 7.5,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LegacyCompactCompanion extends StatelessWidget {
  const _LegacyCompactCompanion({
    required this.controller,
    required this.standalone,
  });

  final LegacyEhrSandboxController controller;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final stateLabel = controller.isStaged
        ? 'STAGED • HUMAN APPROVAL REQUIRED'
        : 'READ-ONLY COMPANION';
    final stateColor = controller.isStaged
        ? _LegacyColors.warning
        : _LegacyColors.blue;

    return SizedBox.expand(
      child: ColoredBox(
        key: const Key('legacy-compact-companion'),
        color: _LegacyColors.navyDark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF5FA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'N',
                            style: TextStyle(
                              color: _LegacyColors.navy,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NORTHSTAR CLINICAL SYSTEM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: 0.45,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Fictional legacy target • release 8.4',
                                style: TextStyle(
                                  color: Color(0xFFAFC3D1),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!standalone)
                          IconButton(
                            key: const Key('legacy-compact-close-button'),
                            tooltip: 'Return to RENKEVIA',
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _LegacyColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _LegacyStateLabel(
                                label: 'FICTIONAL • NO PHI',
                                color: _LegacyColors.success,
                              ),
                              _LegacyStateLabel(
                                label: 'STAGING ONLY',
                                color: _LegacyColors.warning,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Desktop operator surface',
                            style: TextStyle(
                              color: _LegacyColors.ink,
                              fontSize: 22,
                              height: 1.12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Northstar is the fictional no-API EHR that RENKEVIA inspects through Computer Use. Its dense configuration console runs at 900 px or wider; this compact surface preserves status and safety boundaries on every smaller device.',
                            style: TextStyle(
                              color: _LegacyColors.muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const _CompactLegacyFact(
                            icon: Icons.assignment_outlined,
                            label: 'TARGET ARTIFACT',
                            value: 'EHR-OS-014 • IV Carrier Protocol',
                          ),
                          const SizedBox(height: 9),
                          _CompactLegacyFact(
                            icon: Icons.visibility_outlined,
                            label: 'SESSION STATE',
                            value: stateLabel,
                            color: stateColor,
                          ),
                          const SizedBox(height: 9),
                          const _CompactLegacyFact(
                            icon: Icons.pan_tool_alt_outlined,
                            label: 'SAFE STOP',
                            value:
                                'Final commit disabled • approval remains human',
                            color: _LegacyColors.danger,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.screen_rotation_alt_outlined,
                          size: 16,
                          color: Color(0xFFAFCDE0),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Use a desktop window at 900 px or wider to run the visible Computer Use staging sequence.',
                            style: TextStyle(
                              color: Color(0xFFAFCDE0),
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactLegacyFact extends StatelessWidget {
  const _CompactLegacyFact({
    required this.icon,
    required this.label,
    required this.value,
    this.color = _LegacyColors.blue,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.26)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: _LegacyColors.ink,
                    fontSize: 10.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
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
