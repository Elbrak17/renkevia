import 'package:flutter_test/flutter_test.dart';
import 'package:renkevia/src/features/workspace/demo_run_controller.dart';
import 'package:renkevia/src/features/workspace/workspace_deep_link.dart';

void main() {
  test('maps presentation deep links to the four product surfaces', () {
    expect(
      workspaceSectionFromUri(Uri.parse('https://demo.test/')),
      WorkspaceSection.responseRoom,
    );
    expect(
      workspaceSectionFromUri(Uri.parse('https://demo.test/?surface=patch')),
      WorkspaceSection.patchStudio,
    );
    expect(
      workspaceSectionFromUri(Uri.parse('https://demo.test/?surface=simulate')),
      WorkspaceSection.simulationLab,
    );
    expect(
      workspaceSectionFromUri(Uri.parse('https://demo.test/?surface=evidence')),
      WorkspaceSection.evidenceVault,
    );
  });

  test('unknown presentation deep links fail safely to Response Room', () {
    expect(
      workspaceSectionFromUri(Uri.parse('https://demo.test/?surface=legacy')),
      WorkspaceSection.responseRoom,
    );
  });
}
