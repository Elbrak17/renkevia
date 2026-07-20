{{flutter_js}}
{{flutter_build_config}}

// Keep the demo fully self-contained in restricted judging environments.
// Flutter otherwise resolves CanvasKit from a Google CDN at runtime.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: 'canvaskit/',
  },
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  },
});
