import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kamus_aplikasi/theme/app_theme.dart';

double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final light = math.max(la, lb);
  final dark = math.min(la, lb);
  return (light + 0.05) / (dark + 0.05);
}

void main() {
  group('tema gelap', () {
    final scheme = AppTheme.dark().colorScheme;

    test('tidak memakai hitam atau putih murni', () {
      expect(scheme.surface, isNot(const Color(0xFF000000)));
      expect(scheme.onSurface, isNot(const Color(0xFFFFFFFF)));
      expect(scheme.surface.computeLuminance(), greaterThan(0.005));
      expect(scheme.onSurface.computeLuminance(), lessThan(0.95));
    });

    test('teks utama tetap terbaca (kontras >= 4.5:1)', () {
      expect(_contrastRatio(scheme.onSurface, scheme.surface), greaterThanOrEqualTo(4.5));
      expect(
        _contrastRatio(scheme.onSurfaceVariant, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(_contrastRatio(scheme.primary, scheme.surface), greaterThanOrEqualTo(4.5));
      expect(
        _contrastRatio(scheme.onSecondaryContainer, scheme.secondaryContainer),
        greaterThanOrEqualTo(4.5),
      );
      expect(_contrastRatio(scheme.onPrimary, scheme.primary), greaterThanOrEqualTo(4.5));
    });

    test('permukaan bertingkat naik perlahan dan tidak menyilaukan', () {
      final ladder = <Color>[
        scheme.surface,
        scheme.surfaceContainerLowest,
        scheme.surfaceContainerLow,
        scheme.surfaceContainer,
        scheme.surfaceContainerHigh,
        scheme.surfaceContainerHighest,
      ];

      for (var i = 1; i < ladder.length; i++) {
        expect(
          ladder[i].computeLuminance(),
          greaterThan(ladder[i - 1].computeLuminance()),
          reason: 'permukaan ke-$i harus lebih terang dari sebelumnya',
        );
      }
      expect(scheme.surfaceContainerHighest.computeLuminance(), lessThan(0.35));
    });
  });

  group('tema terang', () {
    final scheme = AppTheme.light().colorScheme;

    test('kartu tetap paling terang di atas latar krem', () {
      expect(
        scheme.surfaceContainerLowest.computeLuminance(),
        greaterThan(scheme.surface.computeLuminance()),
      );
      expect(_contrastRatio(scheme.onSurface, scheme.surface), greaterThanOrEqualTo(4.5));
    });
  });
}
