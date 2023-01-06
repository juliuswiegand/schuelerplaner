import 'package:flutter/material.dart';

Color farbeVerdunkeln(Color farbe, [double staerke = .1]) {
  assert(staerke >= 0 && staerke <= 1);

  final hsl = HSLColor.fromColor(farbe);
  final hslDark = hsl.withLightness((hsl.lightness - staerke).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color farbeErhellen(Color farbe, [double staerke = .1]) {
  assert(staerke >= 0 && staerke <= 1);

  final hsl = HSLColor.fromColor(farbe);
  final hslLight = hsl.withLightness((hsl.lightness + staerke).clamp(0.0, 1.0));

  return hslLight.toColor();
}