// ===========================================================================
// 🧊 完美修复版：冰冻卡特效组件 (增加清晰可见的真实多芒星霜花)
// ===========================================================================
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PKFreezeOverlay extends StatefulWidget {
  const PKFreezeOverlay({super.key});

  @override
  State<PKFreezeOverlay> createState() => _PKFreezeOverlayState();
}

class _PKFreezeOverlayState extends State<PKFreezeOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 寒气呼吸动画，制造冰冻忽明忽暗的质感
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double breathOpacity = 0.6 + (_controller.value * 0.4);
          return ClipRect(
            child: CustomPaint(
              painter: _IcePainter(opacity: breathOpacity),
            ),
          );
        },
      ),
    );
  }
}

class _IcePainter extends CustomPainter {
  final double opacity;

  _IcePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    // 安全拦截：防止画布宽度异常导致死循环
    if (size.width <= 0 || size.width.isInfinite || size.height <= 0 || size.height.isInfinite) {
      return;
    }

    final double w = size.width;
    final double h = size.height;
    // 💡 固定随机种子，保证每次冰的形状是固定的物理结晶，只做透明度呼吸
    final random = math.Random(888);

    // 1. 绘制极寒渐变底色
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomRight,
        [
          Colors.white.withOpacity(0.4 * opacity),
          const Color(0xFF80DEEA).withOpacity(0.4 * opacity),
          const Color(0xFF00B0FF).withOpacity(0.15),
          Colors.white.withOpacity(0.4 * opacity),
        ],
        const [0.0, 0.3, 0.7, 1.0],
      );
    canvas.drawRect(rect, bgPaint);

    // 2. 绘制极度锐利的冰刺 (锯齿状)
    final Paint iceSpikePaint = Paint()
      ..color = Colors.white.withOpacity(0.85 * opacity)
      ..style = PaintingStyle.fill;

    Path topIce = Path()..moveTo(0, 0);
    double currentX = 0;
    while (currentX < w) {
      currentX += random.nextDouble() * 12.0 + 4.0;
      double spikeHeight = random.nextDouble() * 9.0 + 3.0;
      topIce.lineTo(currentX - (random.nextDouble() * 5 + 2), spikeHeight);
      topIce.lineTo(currentX, 0);
    }
    topIce.lineTo(w, 0);
    topIce.close();

    Path bottomIce = Path()..moveTo(0, h);
    currentX = 0;
    while (currentX < w) {
      currentX += random.nextDouble() * 12.0 + 4.0;
      double spikeHeight = random.nextDouble() * 9.0 + 3.0;
      bottomIce.lineTo(currentX - (random.nextDouble() * 5 + 2), h - spikeHeight);
      bottomIce.lineTo(currentX, h);
    }
    bottomIce.lineTo(w, h);
    bottomIce.close();

    canvas.drawPath(topIce, iceSpikePaint);
    canvas.drawPath(bottomIce, iceSpikePaint);

    // 3. 绘制凌厉的冰裂纹
    final Paint crackPaint = Paint()
      ..color = Colors.white.withOpacity(0.65 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeJoin = StrokeJoin.miter;

    Path crackPath = Path();
    crackPath.moveTo(0, 0);
    crackPath.lineTo(15, 8);
    crackPath.lineTo(22, 4);
    crackPath.lineTo(38, 14);
    crackPath.moveTo(15, 8);
    crackPath.lineTo(18, 15);
    crackPath.moveTo(w, h);
    crackPath.lineTo(w - 20, h - 5);
    crackPath.lineTo(w - 28, h - 14);
    crackPath.lineTo(w - 45, h - 8);
    canvas.drawPath(crackPath, crackPaint);

    // ==========================================
    // 4. ⭐ 真正清晰可见的霜花结晶 (Frost Blooms)
    // ==========================================
    final Paint frostPaint = Paint()
      ..color = Colors.white.withOpacity(0.85 * opacity)
      ..style = PaintingStyle.fill;

    // 散布 15 朵清晰的冰花晶体
    for (int i = 0; i < 15; i++) {
      double cx = random.nextDouble() * w;
      double cy = random.nextDouble() * h;

      // 💡 尺寸大幅度放大！半径在 4 到 9 像素之间 (直径8~18像素，绝对肉眼可见)
      double frostSize = random.nextDouble() * 5.0 + 4.0;

      canvas.save();
      canvas.translate(cx, cy);
      // 给每朵霜花一个随机的倾斜角度
      canvas.rotate(random.nextDouble() * math.pi);

      // 绘制主干：一个锐利的四芒星
      Path frost = Path();
      frost.moveTo(0, -frostSize);
      frost.lineTo(frostSize * 0.15, -frostSize * 0.15);
      frost.lineTo(frostSize, 0);
      frost.lineTo(frostSize * 0.15, frostSize * 0.15);
      frost.lineTo(0, frostSize);
      frost.lineTo(-frostSize * 0.15, frostSize * 0.15);
      frost.lineTo(-frostSize, 0);
      frost.lineTo(-frostSize * 0.15, -frostSize * 0.15);
      frost.close();
      canvas.drawPath(frost, frostPaint);

      // 绘制分支：旋转 45度 (pi/4)，再画一个稍微小一点、略透明的四芒星，叠加形成完美的雪花/霜花结构
      canvas.rotate(math.pi / 4);
      Path frostInner = Path();
      double innerSize = frostSize * 0.65;
      frostInner.moveTo(0, -innerSize);
      frostInner.lineTo(innerSize * 0.15, -innerSize * 0.15);
      frostInner.lineTo(innerSize, 0);
      frostInner.lineTo(innerSize * 0.15, innerSize * 0.15);
      frostInner.lineTo(0, innerSize);
      frostInner.lineTo(-innerSize * 0.15, innerSize * 0.15);
      frostInner.lineTo(-innerSize, 0);
      frostInner.lineTo(-innerSize * 0.15, -innerSize * 0.15);
      frostInner.close();

      canvas.drawPath(
          frostInner,
          Paint()..color = Colors.white.withOpacity(0.5 * opacity)..style = PaintingStyle.fill
      );

      canvas.restore();
    }

    // 5. 坚硬的镜面高光 (产生厚冰的固体质感)
    Path glarePath = Path();
    glarePath.moveTo(w * 0.15, h);
    glarePath.lineTo(w * 0.35, 0);
    glarePath.lineTo(w * 0.45, 0);
    glarePath.lineTo(w * 0.25, h);
    glarePath.close();

    canvas.drawPath(
        glarePath,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(w * 0.25, 0),
            Offset(w * 0.35, h),
            [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.5 * opacity), Colors.white.withOpacity(0.0)],
            const [0.0, 0.5, 1.0],
          ));
  }

  @override
  bool shouldRepaint(covariant _IcePainter oldDelegate) => oldDelegate.opacity != opacity;
}