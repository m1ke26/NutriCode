import 'dart:math';
import 'package:flutter/material.dart';

// ── Fixed green gradient (always the same) ────────────────────────────
const kGradientStart = Color(0xFF1B998B);
const kGradientEnd   = Color(0xFF15796E);

const kAppGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kGradientStart, kGradientEnd],
);

// ── Pattern model ─────────────────────────────────────────────────────
class AppPattern {
  final String name;
  final IconData icon;
  final CustomPainter? Function() createPainter; // null → no overlay

  const AppPattern({
    required this.name,
    required this.icon,
    required this.createPainter,
  });
}

// ── 5 patterns ────────────────────────────────────────────────────────
final List<AppPattern> appPatterns = [
  AppPattern(name: 'Original',    icon: Icons.lens_rounded,           createPainter: () => null),
  AppPattern(name: 'Marinho',     icon: Icons.waves_rounded,          createPainter: () => _MarinhoPainter()),
  AppPattern(name: 'Chuva',       icon: Icons.water_drop_rounded,     createPainter: () => _RainPainter()),
  AppPattern(name: 'Bambu',       icon: Icons.grass_rounded,          createPainter: () => _BambuPainter()),
  AppPattern(name: 'Constelação', icon: Icons.auto_awesome_rounded,   createPainter: () => _ConstellationPainter()),
];

// ── Helper widget: apply gradient + optional pattern ──────────────────
class PatternSurface extends StatelessWidget {
  final int patternIndex;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;

  const PatternSurface({
    super.key,
    required this.patternIndex,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final painter = appPatterns[patternIndex].createPainter();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: kAppGradient,
        borderRadius: borderRadius,
      ),
      child: painter != null
          ? Stack(children: [
              Positioned.fill(child: ClipRRect(
                borderRadius: borderRadius ?? BorderRadius.zero,
                child: CustomPaint(painter: painter),
              )),
              ?child,
            ])
          : child,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Painters
// ══════════════════════════════════════════════════════════════════════

// ── 1. Marinho — waves, fish, bubbles & seaweed ───────────────────────
class _MarinhoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(17);

    // ── Flowing wave bands ──────────────────────────────────────────────
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const numWaves = 6;
    for (int w = 0; w < numWaves; w++) {
      final baseY      = size.height * (0.10 + w * 0.16);
      final amplitude  = rng.nextDouble() * 9 + 5.0;
      final wavelength = rng.nextDouble() * 50 + 55.0;
      final phase      = rng.nextDouble() * pi * 2;
      final alpha      = 0.10 + rng.nextDouble() * 0.12;
      final thick      = rng.nextDouble() * 1.0 + 0.8;

      wavePaint
        ..color      = Colors.white.withValues(alpha: alpha)
        ..strokeWidth = thick;

      final path = Path();
      bool started = false;
      for (double x = 0; x <= size.width; x += 1.5) {
        final y = baseY + amplitude * sin((x / wavelength) * pi * 2 + phase);
        if (!started) { path.moveTo(x, y); started = true; }
        else           { path.lineTo(x, y); }
      }
      canvas.drawPath(path, wavePaint);
    }

    // ── Bubbles (outline + faint fill) ─────────────────────────────────
    final bubbleFill = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    final bubbleStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 24; i++) {
      final bx = rng.nextDouble() * size.width;
      final by = rng.nextDouble() * size.height;
      final br = rng.nextDouble() * 6.5 + 2.0;
      canvas.drawCircle(Offset(bx, by), br, bubbleFill);
      canvas.drawCircle(Offset(bx, by), br, bubbleStroke);
      // Tiny highlight glint
      final glintPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bx - br * 0.3, by - br * 0.3), br * 0.22, glintPaint);
    }

    // ── Fish silhouettes ────────────────────────────────────────────────
    final fishPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      final fx    = rng.nextDouble() * size.width;
      final fy    = rng.nextDouble() * size.height;
      final scale = rng.nextDouble() * 0.55 + 0.45;
      final dir   = rng.nextBool() ? 1.0 : -1.0;
      fishPaint.color = Colors.white.withValues(alpha: rng.nextDouble() * 0.10 + 0.14);
      _drawFish(canvas, fishPaint, Offset(fx, fy), scale, dir);
    }

    // ── Seaweed strands ────────────────────────────────────────────────
    final seaweedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 6; i++) {
      final sx      = rng.nextDouble() * size.width;
      final strandH = rng.nextDouble() * 45 + 35.0;
      final sAlpha  = rng.nextDouble() * 0.08 + 0.10;
      seaweedPaint.color = Colors.white.withValues(alpha: sAlpha);
      _drawSeaweed(canvas, seaweedPaint, sx, size.height, strandH, rng);
    }
  }

  // ── Fish: streamlined body + forked tail ─────────────────────────────
  void _drawFish(Canvas c, Paint p, Offset o, double s, double dir) {
    c.save();
    c.translate(o.dx, o.dy);
    c.scale(dir, 1.0);

    // Body
    final body = Path()
      ..moveTo(-11 * s, 0)
      ..quadraticBezierTo(-5 * s, -7 * s,  7 * s, -4 * s)
      ..quadraticBezierTo(13 * s,  0,       7 * s,  4 * s)
      ..quadraticBezierTo(-5 * s,  7 * s, -11 * s,  0)
      ..close();

    // Forked tail
    final tail = Path()
      ..moveTo(-9 * s,  0)
      ..lineTo(-17 * s, -7 * s)
      ..lineTo(-14 * s,  0)
      ..lineTo(-17 * s,  7 * s)
      ..close();

    c.drawPath(body, p);
    c.drawPath(tail, p);

    // Eye dot
    final eyePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    c.drawCircle(Offset(5 * s, -1.5 * s), 1.5 * s, eyePaint);

    c.restore();
  }

  // ── Seaweed: wavy upward strand ───────────────────────────────────────
  void _drawSeaweed(Canvas c, Paint p, double x, double baseY, double height, Random rng) {
    final path = Path()..moveTo(x, baseY);
    final segments = (height / 8).round();
    for (int i = 1; i <= segments; i++) {
      final progress = i / segments;
      final waveX    = sin(progress * pi * 3) * 6;
      path.lineTo(x + waveX, baseY - height * progress);
    }
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── 2. Chuva — layered diagonal rain ─────────────────────────────────
class _RainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const angle = pi / 5.5; // ~33°
    final dx = sin(angle);
    final dy = cos(angle);

    // Heavy drops — thick, long
    final heavy = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const heavyLen    = 20.0;
    const heavySpaceX = 20.0;
    const heavySpaceY = 32.0;

    for (double x = -heavyLen * 2; x < size.width + heavyLen; x += heavySpaceX) {
      for (double y = -heavyLen; y < size.height + heavyLen * 2; y += heavySpaceY) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + dx * heavyLen, y + dy * heavyLen),
          heavy,
        );
      }
    }

    // Light drizzle — offset grid, thinner & shorter
    final light = Paint()
      ..color = Colors.white.withValues(alpha: 0.11)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    const lightLen    = 10.0;
    const lightSpaceX = 14.0;
    const lightSpaceY = 22.0;

    for (double x = -lightLen * 2 + 7; x < size.width + lightLen; x += lightSpaceX) {
      for (double y = -lightLen + 16; y < size.height + lightLen * 2; y += lightSpaceY) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + dx * lightLen, y + dy * lightLen),
          light,
        );
      }
    }

    // Occasional teardrop shapes — larger isolated drops
    final drop = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final rng = Random(11);
    for (int i = 0; i < 10; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      _drawTeardrop(canvas, drop, Offset(x, y), rng.nextDouble() * 3 + 3);
    }
  }

  void _drawTeardrop(Canvas c, Paint p, Offset o, double r) {
    final path = Path()
      ..moveTo(o.dx, o.dy - r * 1.6)
      ..cubicTo(o.dx + r, o.dy - r, o.dx + r, o.dy + r * 0.3, o.dx, o.dy + r)
      ..cubicTo(o.dx - r, o.dy + r * 0.3, o.dx - r, o.dy - r, o.dx, o.dy - r * 1.6)
      ..close();
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── 3. Bambu — dense bamboo forest with sprouting leaves ──────────────
class _BambuPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    const numStalks = 11;

    for (int i = 0; i < numStalks; i++) {
      // Distribute stalks, some overlap for depth
      final baseX   = (size.width / (numStalks - 1)) * i + (rng.nextDouble() - 0.5) * 16;
      final stalkW  = rng.nextDouble() * 5 + 5.0;   // 5 – 10 px wide
      final segH    = rng.nextDouble() * 12 + 26.0;  // 26 – 38 px per segment
      final offsetY = rng.nextDouble() * segH;
      final alpha   = rng.nextDouble() * 0.10 + 0.12;

      final stalkPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stalkW
        ..strokeCap = StrokeCap.butt;

      final nodePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha + 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      // Draw segments from top to bottom
      for (double y = -segH + offsetY; y < size.height + segH; y += segH) {
        // Stalk segment
        canvas.drawLine(
          Offset(baseX, y),
          Offset(baseX, y + segH - 2),
          stalkPaint,
        );
        // Node ring
        final nodeW = stalkW + 5;
        canvas.drawLine(
          Offset(baseX - nodeW / 2, y + segH - 2),
          Offset(baseX + nodeW / 2, y + segH - 2),
          nodePaint,
        );
        // Leaves at ~every other node (alternate sides)
        if (rng.nextDouble() > 0.35) {
          final dir = (i % 2 == 0) ? 1.0 : -1.0;
          _drawBambooLeaf(canvas, Offset(baseX, y + segH - 2), dir, alpha + 0.06, rng);
        }
        if (rng.nextDouble() > 0.55) {
          // Occasionally a second leaf on the opposite side
          final dir = (i % 2 == 0) ? -1.0 : 1.0;
          _drawBambooLeaf(canvas, Offset(baseX, y + segH - 2), dir, alpha + 0.03, rng);
        }
      }
    }
  }

  void _drawBambooLeaf(Canvas c, Offset origin, double dir, double alpha, Random rng) {
    final leafPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final len   = rng.nextDouble() * 14 + 18.0; // 18–32px
    final droop = rng.nextDouble() * 6 + 4.0;   // how much it curves down

    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
          origin.dx + dir * len * 0.55, origin.dy - 7,
          origin.dx + dir * len,         origin.dy + droop)
      ..quadraticBezierTo(
          origin.dx + dir * len * 0.55, origin.dy + droop * 0.5,
          origin.dx, origin.dy)
      ..close();

    c.drawPath(path, leafPaint);
    // Center vein
    c.drawLine(
      origin,
      Offset(origin.dx + dir * len, origin.dy + droop),
      veinPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── 4. Constelação — rich star field with sparkles ────────────────────
class _ConstellationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 0.7;
    final brightDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.60)
      ..style = PaintingStyle.fill;
    final dimDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final sparkPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    final rng = Random(23);

    // Generate stars with varying radii
    final List<Offset> positions = [];
    final List<double> radii = [];
    for (int i = 0; i < 26; i++) {
      positions.add(Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
      ));
      radii.add(rng.nextDouble() * 2.4 + 0.8); // 0.8 – 3.2 px
    }

    // Constellation lines between nearby stars
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        if ((positions[i] - positions[j]).distance < 85) {
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }

    // Draw stars
    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      final r   = radii[i];

      if (r > 2.2) {
        // Bright star: filled circle + 4-point sparkle cross
        canvas.drawCircle(pos, r, brightDot);
        final arm = r * 2.8;
        canvas.drawLine(Offset(pos.dx - arm, pos.dy), Offset(pos.dx + arm, pos.dy), sparkPaint);
        canvas.drawLine(Offset(pos.dx, pos.dy - arm), Offset(pos.dx, pos.dy + arm), sparkPaint);
        // Diagonal mini-arms
        final diag = arm * 0.55;
        canvas.drawLine(Offset(pos.dx - diag, pos.dy - diag), Offset(pos.dx + diag, pos.dy + diag), sparkPaint);
        canvas.drawLine(Offset(pos.dx + diag, pos.dy - diag), Offset(pos.dx - diag, pos.dy + diag), sparkPaint);
      } else {
        canvas.drawCircle(pos, r, dimDot);
      }
    }

    // Extra tiny background dust dots
    for (int i = 0; i < 14; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.6,
        dimDot,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
