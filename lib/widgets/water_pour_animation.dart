import 'dart:math';
import 'package:flutter/material.dart';

/// Widget que dibuja la animación de líquido fluyendo entre dos tubos
/// cuando el tubo origen se inclina para verter
class WaterPourAnimation extends StatelessWidget {
  final Offset fromPosition; // Centro superior del tubo origen
  final Offset toPosition; // Centro superior del tubo destino
  final Color waterColor;
  final double progress; // 0.0 a 1.0
  final double tubeWidth;
  final double pourDirection; // 1.0 = derecha, -1.0 = izquierda

  const WaterPourAnimation({
    super.key,
    required this.fromPosition,
    required this.toPosition,
    required this.waterColor,
    required this.progress,
    required this.tubeWidth,
    required this.pourDirection,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaterPourPainter(
        fromPosition: fromPosition,
        toPosition: toPosition,
        waterColor: waterColor,
        progress: progress,
        tubeWidth: tubeWidth,
        pourDirection: pourDirection,
      ),
      size: Size.infinite,
    );
  }
}

class _WaterPourPainter extends CustomPainter {
  final Offset fromPosition;
  final Offset toPosition;
  final Color waterColor;
  final double progress;
  final double tubeWidth;
  final double pourDirection;

  _WaterPourPainter({
    required this.fromPosition,
    required this.toPosition,
    required this.waterColor,
    required this.progress,
    required this.tubeWidth,
    required this.pourDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.1) return; // Esperar a que el tubo empiece a inclinarse

    // Usar la dirección pasada desde el widget padre (basada en índices de tubos)
    final direction = pourDirection;

    // Ancho del chorro
    final streamWidth = tubeWidth * 0.3;

    // Calcular la inclinación actual del tubo
    double tiltProgress;
    if (progress < 0.15) {
      tiltProgress = progress / 0.15;
    } else if (progress < 0.85) {
      tiltProgress = 1.0;
    } else {
      tiltProgress = (1.0 - progress) / 0.15;
    }

    // Punto de salida del líquido (borde del tubo inclinado)
    // El tubo se inclina desde su base, así que el borde superior se mueve
    final tiltAngle = direction * tiltProgress * 0.6;
    final tubeHeight = tubeWidth * 2.5;

    // Calcular el punto de salida basado en la inclinación
    // fromPosition ya viene con la elevación aplicada por el Transform del tubo

    // Calcular la distancia entre tubos
    final tubeDistance = (toPosition.dx - fromPosition.dx).abs();
    final areAdjacent = tubeDistance < tubeWidth * 1.8; // Tubos pegados o muy cerca

    // Ajustar offsets según si los tubos están pegados o no
    double exitOffsetX;
    double horizontalOffset;

    if (areAdjacent) {
      // Tubos pegados: reducir offsets para que el líquido caiga más directo
      exitOffsetX = sin(tiltAngle) * tubeHeight * 0.15;
      horizontalOffset = direction * tubeWidth * 0.2;
    } else {
      // Tubos separados: offsets normales
      exitOffsetX = sin(tiltAngle) * tubeHeight * 0.3;
      horizontalOffset = direction * tubeWidth * 0.35;
    }

    // Offset vertical pequeño por la inclinación
    final exitOffsetY = (1 - cos(tiltAngle)) * tubeHeight * 0.1;

    final pourExitPoint = Offset(
      fromPosition.dx + exitOffsetX + horizontalOffset,
      fromPosition.dy + exitOffsetY + 5, // Justo en la boca del tubo
    );

    // Punto de entrada al tubo destino
    final entryPoint = Offset(toPosition.dx, toPosition.dy + 5);

    // Solo dibujar el chorro cuando el tubo está suficientemente inclinado
    if (tiltProgress > 0.3) {
      final pourProgress = ((tiltProgress - 0.3) / 0.7).clamp(0.0, 1.0);

      // Calcular el progreso del vertido basado en la fase general
      double streamProgress;
      if (progress < 0.2) {
        streamProgress = 0;
      } else if (progress < 0.85) {
        streamProgress = ((progress - 0.2) / 0.65).clamp(0.0, 1.0);
      } else {
        // Fase de retorno - el chorro se reduce
        streamProgress = ((1.0 - progress) / 0.15).clamp(0.0, 1.0);
      }

      if (streamProgress > 0) {
        _drawPouringStream(
          canvas,
          pourExitPoint,
          entryPoint,
          streamWidth,
          streamProgress,
          pourProgress,
        );
      }
    }
  }

  void _drawPouringStream(
    Canvas canvas,
    Offset exitPoint,
    Offset entryPoint,
    double streamWidth,
    double streamProgress,
    double intensity,
  ) {
    // Colores del gradiente
    final gradientColors = [
      waterColor.withOpacity(0.95),
      waterColor,
      waterColor.withOpacity(0.85),
    ];

    // Detectar si los tubos están muy cerca (adyacentes)
    final horizontalDistance = (entryPoint.dx - exitPoint.dx).abs();
    final areClose = horizontalDistance < streamWidth * 3;

    // Punto de control para la curva (crea el arco natural del agua cayendo)
    final midX = (exitPoint.dx + entryPoint.dx) / 2;
    final controlPoint = Offset(
      midX,
      // Para tubos cercanos, hacer la curva más directa (menos arco)
      exitPoint.dy + (entryPoint.dy - exitPoint.dy) * (areClose ? 0.5 : 0.3),
    );

    // Generar puntos a lo largo de la curva
    final points = <Offset>[];
    final numPoints = 30;

    for (int i = 0; i <= numPoints; i++) {
      final t = (i / numPoints) * streamProgress;
      final x = _quadraticBezier(exitPoint.dx, controlPoint.dx, entryPoint.dx, t);
      final y = _quadraticBezier(exitPoint.dy, controlPoint.dy, entryPoint.dy, t);
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    // Crear el path del chorro con bordes suaves
    final path = Path();
    final leftPoints = <Offset>[];
    final rightPoints = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Calcular dirección tangente
      Offset tangent;
      if (i == 0) {
        tangent = points.length > 1 ? points[1] - points[0] : const Offset(0, 1);
      } else if (i == points.length - 1) {
        tangent = points[i] - points[i - 1];
      } else {
        tangent = points[i + 1] - points[i - 1];
      }

      final length = sqrt(tangent.dx * tangent.dx + tangent.dy * tangent.dy);
      if (length == 0) continue;

      final normal = Offset(-tangent.dy / length, tangent.dx / length);

      // Variar el ancho del chorro:
      // - Más ancho al inicio (saliendo del tubo)
      // - Se estrecha mientras cae
      // - Ligeramente más ancho al final (impacto)
      final t = i / points.length;
      double widthFactor;
      if (t < 0.2) {
        widthFactor = 1.0 - t * 0.5; // Empieza ancho
      } else if (t < 0.8) {
        widthFactor = 0.9 - (t - 0.2) * 0.3; // Se estrecha
      } else {
        widthFactor = 0.6 + (t - 0.8) * 0.5; // Se ensancha al impactar
      }

      // Añadir ondulación para efecto de fluido
      final wave = sin(i * 0.5 + progress * 10) * 0.1;
      widthFactor += wave;

      final halfWidth = (streamWidth / 2) * widthFactor * intensity;

      leftPoints.add(point + normal * halfWidth);
      rightPoints.add(point - normal * halfWidth);
    }

    if (leftPoints.isEmpty) return;

    // Construir el path
    path.moveTo(leftPoints.first.dx, leftPoints.first.dy);

    // Lado izquierdo con curvas suaves
    for (int i = 1; i < leftPoints.length; i++) {
      if (i % 3 == 0 && i + 1 < leftPoints.length) {
        path.quadraticBezierTo(
          leftPoints[i].dx,
          leftPoints[i].dy,
          (leftPoints[i].dx + leftPoints[i + 1].dx) / 2,
          (leftPoints[i].dy + leftPoints[i + 1].dy) / 2,
        );
      } else {
        path.lineTo(leftPoints[i].dx, leftPoints[i].dy);
      }
    }

    // Punta del chorro
    final lastPoint = points.last;
    path.quadraticBezierTo(
      lastPoint.dx,
      lastPoint.dy + streamWidth * 0.3,
      rightPoints.last.dx,
      rightPoints.last.dy,
    );

    // Lado derecho en reversa con curvas
    for (int i = rightPoints.length - 2; i >= 0; i--) {
      if (i % 3 == 0 && i > 0) {
        path.quadraticBezierTo(
          rightPoints[i].dx,
          rightPoints[i].dy,
          (rightPoints[i].dx + rightPoints[i - 1].dx) / 2,
          (rightPoints[i].dy + rightPoints[i - 1].dy) / 2,
        );
      } else {
        path.lineTo(rightPoints[i].dx, rightPoints[i].dy);
      }
    }

    path.close();

    // Pintar el chorro principal
    final bounds = path.getBounds();
    final mainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ).createShader(bounds)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, mainPaint);

    // Añadir brillo
    _drawStreamHighlight(canvas, points, streamWidth, intensity);

    // Añadir gotas
    if (streamProgress > 0.5) {
      _drawDroplets(canvas, points, streamWidth, streamProgress);
    }

    // Splash al entrar al tubo
    if (streamProgress > 0.8) {
      _drawSplash(canvas, entryPoint, streamWidth, (streamProgress - 0.8) / 0.2, intensity);
    }
  }

  void _drawStreamHighlight(Canvas canvas, List<Offset> points, double streamWidth, double intensity) {
    if (points.length < 3) return;

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final highlightPath = Path();
    highlightPath.moveTo(
      points.first.dx - streamWidth * 0.15,
      points.first.dy,
    );

    for (int i = 1; i < points.length ~/ 2; i++) {
      highlightPath.lineTo(
        points[i].dx - streamWidth * 0.15 * (1 - i / points.length),
        points[i].dy,
      );
    }

    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawDroplets(Canvas canvas, List<Offset> points, double streamWidth, double progress) {
    final random = Random(42);
    final dropletPaint = Paint()
      ..color = waterColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Gotas pequeñas alrededor del chorro
    for (int i = 0; i < 5; i++) {
      final pointIndex = (random.nextDouble() * points.length * 0.8).toInt();
      if (pointIndex >= points.length) continue;

      final basePoint = points[pointIndex];
      final offsetX = (random.nextDouble() - 0.5) * streamWidth * 1.5;
      final offsetY = random.nextDouble() * 10;
      final radius = 1.5 + random.nextDouble() * 2;

      canvas.drawCircle(
        Offset(basePoint.dx + offsetX, basePoint.dy + offsetY),
        radius,
        dropletPaint,
      );
    }
  }

  void _drawSplash(Canvas canvas, Offset position, double streamWidth, double splashProgress, double intensity) {
    if (intensity < 0.5) return;

    // Ondas circulares
    for (int i = 0; i < 2; i++) {
      final waveDelay = i * 0.3;
      final waveProgress = (splashProgress - waveDelay).clamp(0.0, 1.0);
      if (waveProgress <= 0) continue;

      final radius = streamWidth * (0.3 + waveProgress * 0.8);
      final opacity = (1 - waveProgress) * 0.4 * intensity;

      final wavePaint = Paint()
        ..color = waterColor.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * (1 - waveProgress);

      canvas.drawCircle(position, radius, wavePaint);
    }

    // Pequeñas gotas salpicando hacia arriba
    if (splashProgress > 0.1 && splashProgress < 0.6) {
      final splashPaint = Paint()
        ..color = waterColor.withOpacity(0.5 * intensity)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 3; i++) {
        final angle = -pi / 2 + (i - 1) * 0.4; // Hacia arriba
        final distance = streamWidth * 0.4 * splashProgress;
        final splashX = position.dx + cos(angle) * distance;
        final splashY = position.dy + sin(angle) * distance;
        final radius = 2.0 * (1 - splashProgress * 0.8);

        if (radius > 0.5) {
          canvas.drawCircle(Offset(splashX, splashY), radius, splashPaint);
        }
      }
    }
  }

  double _quadraticBezier(double p0, double p1, double p2, double t) {
    return pow(1 - t, 2) * p0 + 2 * (1 - t) * t * p1 + pow(t, 2) * p2;
  }

  @override
  bool shouldRepaint(covariant _WaterPourPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.fromPosition != fromPosition ||
           oldDelegate.toPosition != toPosition ||
           oldDelegate.waterColor != waterColor ||
           oldDelegate.pourDirection != pourDirection;
  }
}
