double responsiveMetricWidth(
  double viewportWidth, {
  required double desktopWidth,
  bool twoColumn = true,
}) {
  if (viewportWidth >= 600) return desktopWidth;
  if (!twoColumn || viewportWidth < 360) return viewportWidth - 24;
  return (viewportWidth - 32) / 2;
}
