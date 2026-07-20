import 'package:flutter_test/flutter_test.dart';
import 'package:renkevia/src/shared/responsive_metric_width.dart';

void main() {
  test('uses a two-column metric grid on standard mobile widths', () {
    expect(responsiveMetricWidth(390, desktopWidth: 198), 179);
    expect(responsiveMetricWidth(360, desktopWidth: 212), 164);
  });

  test('uses a full-width metric below the safe two-column threshold', () {
    expect(responsiveMetricWidth(359, desktopWidth: 198), 335);
    expect(responsiveMetricWidth(320, desktopWidth: 212), 296);
  });

  test('preserves each feature metric width outside mobile mode', () {
    expect(responsiveMetricWidth(600, desktopWidth: 198), 198);
    expect(responsiveMetricWidth(1440, desktopWidth: 212), 212);
  });
}
