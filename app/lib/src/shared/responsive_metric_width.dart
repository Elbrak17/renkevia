double responsiveMetricWidth(
  double viewportWidth, {
  required double desktopWidth,
}) {
  if (viewportWidth >= 600) return desktopWidth;
  if (viewportWidth < 360) return viewportWidth - 24;
  return (viewportWidth - 32) / 2;
}
