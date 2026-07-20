import 'package:renkevia/src/features/workspace/demo_run_controller.dart';

WorkspaceSection workspaceSectionFromUri(Uri uri) {
  return switch (uri.queryParameters['surface']) {
    'patch' => WorkspaceSection.patchStudio,
    'simulate' => WorkspaceSection.simulationLab,
    'evidence' => WorkspaceSection.evidenceVault,
    _ => WorkspaceSection.responseRoom,
  };
}
