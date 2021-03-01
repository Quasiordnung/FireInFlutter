import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

class CFlame extends StatefulWidget {
  _CFlameState createState() => _CFlameState();
}

class _CFlameState extends State<CFlame> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  CCanvas canvas = CCanvas();
  void initState() {
    animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
  }

  void update() {
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget child) {
            return Stack(
              children: [
                Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: MouseRegion(
                      onHover: (PointerEvent event) {
                        canvas.moveFlame(
                            Offset(event.position.dx, event.position.dy));
                      },
                      child: CustomPaint(
                        foregroundPainter: canvas,
                      ),
                    )),
                Container(
                  width: 0,
                  height: animationController.value,
                ),
              ],
            );
          },
        ));
  }
}

class CCanvas extends CustomPainter {
  Flame flame = Flame(Offset(400, 400), 2, Offset(0, -2.7), 20, 80);
  @override
  void paint(Canvas canvas, Size size) {
    flame.update();
    flame.draw(canvas, size);
  }

  void moveFlame(Offset offset) {
    flame.moveTo(offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Flame {
  RadialGradient fireGradient =
      RadialGradient(colors: [Colors.red[900], Colors.orange]);
  RadialGradient smokeGradient = RadialGradient(
      colors: [Color.fromARGB(30, 0, 0, 0), Color.fromARGB(50, 60, 60, 60)]);

  Paint firePaint;
  Paint smokePaint;
  List<Particle> flameParticleList = [];
  List<Particle> smokeParticleList = [];
  int particlesPerTick;
  Offset startPoint;
  Offset flameDirection;
  double scatteringAngle;
  int size;

  Flame(this.startPoint, this.particlesPerTick, this.flameDirection,
      int scatteringAngle, this.size) {
    this.scatteringAngle = scatteringAngle * (3.14159 / 180);

    Rect rect = Rect.fromPoints(
        Offset(startPoint.dx - size, startPoint.dy - size),
        Offset(startPoint.dx + size, startPoint.dy + size));

    firePaint = Paint()
      ..shader = fireGradient.createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 13);

    smokePaint = Paint()
      ..shader = smokeGradient.createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);
  }

  void moveTo(Offset offset) {
    startPoint = offset;

    Rect rect = Rect.fromPoints(
        Offset(startPoint.dx - size, startPoint.dy - size),
        Offset(startPoint.dx + size, startPoint.dy + size));

    firePaint.shader = fireGradient.createShader(rect);
    smokePaint.shader = smokeGradient.createShader(rect);
  }

  void update() {
    for (Particle flameParticle in flameParticleList) {
      flameParticle.update();
      if (flameParticle.radius <= 0) {
        flameParticleList.remove(flameParticle);
      }
    }

    for (Particle smokeParticle in smokeParticleList) {
      smokeParticle.update();
      if (smokeParticle.radius >= 50) {
        smokeParticleList.remove(smokeParticle);
      }
    }

    for (int i = 0; i < particlesPerTick; i++) {
      if (Random().nextInt(4) > 2) {
        flameParticleList.add(spawnParticle(0));
        if (Random().nextInt(4) > 2) {
          smokeParticleList.add(spawnParticle(1));
        }
      }
    }
  }

  void draw(Canvas canvas, Size size) {
    for (Particle smokeParticle in smokeParticleList) {
      canvas.drawCircle(Offset(smokeParticle.x, smokeParticle.y),
          smokeParticle.radius, smokePaint);
    }

    for (Particle flameParticle in flameParticleList) {
      RadialGradient light = RadialGradient(colors: [
        Color.fromARGB(
            ((5 * (1 - flameParticle.radius / flameParticle.initRadius))
                .toInt()),
            80,
            80,
            0),
        Color.fromARGB(45, 0, 0, 0),
      ]);
      double dx = size.width / 2 - flameParticle.x;
      double dy = size.height / 2 - flameParticle.y;
      Rect lightRect = Rect.fromPoints(
          Offset(0 - dx, 0 - dy), Offset(size.width - dx, size.height - dy));
      canvas.drawCircle(
          Offset(flameParticle.x, flameParticle.y),
          30000,
          Paint()
            ..shader = light.createShader(lightRect)
            ..blendMode = BlendMode.multiply);
    }
    for (Particle flameParticle in flameParticleList) {
      canvas.drawCircle(Offset(flameParticle.x, flameParticle.y),
          flameParticle.radius, firePaint);
    }
  }

  Particle spawnParticle(int selector) {
    if (Random().nextInt(2) > 0) {
      scatteringAngle = -scatteringAngle;
    }
    return Particle(
        startPoint.dx,
        startPoint.dy,
        (flameDirection.dx * cos(Random().nextDouble() * scatteringAngle / 2) +
            flameDirection.dy *
                sin(Random().nextDouble() * -scatteringAngle / 2)),
        flameDirection.dx * sin(Random().nextDouble() * scatteringAngle / 2) +
            flameDirection.dy *
                cos(Random().nextDouble() * scatteringAngle / 2),
        30,
        selector == 0
            ? Random().nextDouble() * 0.1 + 0.35
            : -(Random().nextDouble() * 0.05 + 0.08));
  }
}

class Particle {
  Particle(this.x, this.y, this.dx, this.dy, this.radius, this.decreaseRadius) {
    this.initRadius = radius;
  }
  double initRadius;
  double radius;
  double x;
  double y;
  double dx;
  double dy;
  double decreaseRadius;
  void update() {
    x += dx;
    y += dy;
    radius -= decreaseRadius;
  }
}
