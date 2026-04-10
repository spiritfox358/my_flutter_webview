// ===========================================================================
// 🌫️ 完美修复版：迷雾卡特效组件 (修复渐变报错与潜在卡死风险)
// ===========================================================================
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PKFogOverlay extends StatefulWidget {
  const PKFogOverlay({super.key});

  @override
  State<PKFogOverlay> createState() => _PKFogOverlayState();
}

class _PKFogOverlayState extends State<PKFogOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 迷雾缓慢飘动的动画：6秒一个完整循环
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 6000));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IgnorePointer 防止挡住底下血条的点击事件
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ClipRect(
            child: CustomPaint(
              // 💡 删除了 size: Size.infinite，杜绝无限大死循环问题
              painter: _FogPainter(progress: _controller.value),
            ),
          );
        },
      ),
    );
  }
}

class _FogPainter extends CustomPainter {
  final double progress; // 0.0 到 1.0 循环
  _FogPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 安全拦截
    if (size.width <= 0 || size.width.isInfinite || size.height <= 0 || size.height.isInfinite) return;

    final w = size.width;
    final h = size.height;

    // 1. 铺一层暗色压抑的渐变底色 (用于遮挡底下的分数)
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        rect.centerLeft, rect.centerRight,
        [
          const Color(0xFF1E1E28).withOpacity(0.85), // 深灰黑色
          const Color(0xFF2C2C3A).withOpacity(0.95), // 浓雾中心
          const Color(0xFF1E1E28).withOpacity(0.85), // 深灰黑色
        ],
        // ⭐ 修复报错：加上了对应的 3 个坐标节点！
        const [0.0, 0.5, 1.0],
      );
    canvas.drawRect(rect, bgPaint);

    // 2. 准备绘制漂浮的烟雾团 (极度模糊的叠加圆)
    final Paint lightFogPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);

    final Paint darkFogPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25.0);

    // 3. 绘制两层以不同方向、不同速度移动的雾气
    // 后景雾气：向右慢速飘动
    _drawFogLayer(canvas, w, h, progress, speedMult: 1.0, paint: darkFogPaint, count: 4, seed: 123);
    // 前景雾气：向左快速飘动，产生交错的流体感
    _drawFogLayer(canvas, w, h, progress, speedMult: -1.5, paint: lightFogPaint, count: 5, seed: 456);
  }

  // 绘制单层循环滚动的雾气
  void _drawFogLayer(
      Canvas canvas, double w, double h, double progress,
      {required double speedMult, required Paint paint, required int count, required int seed}
      ) {
    final random = math.Random(seed);

    for (int i = 0; i < count; i++) {
      // 随机生成巨大的雾团
      double radius = random.nextDouble() * 25.0 + 35.0;
      double startY = random.nextDouble() * h;
      double startX = random.nextDouble() * w;

      // 计算无缝滚动的 X 坐标
      // 加上 radius * 2 是为了保证雾团完全移出屏幕后再从另一边出来
      double cycleWidth = w + radius * 2;
      double dx;
      if (speedMult > 0) {
        dx = (startX + progress * cycleWidth * speedMult) % cycleWidth - radius;
      } else {
        // 反向移动
        dx = (startX + (1.0 - progress) * cycleWidth * speedMult.abs()) % cycleWidth - radius;
      }

      // 雾团不仅水平移动，还会伴随极其轻微的上下浮动
      double dy = startY + math.sin(progress * math.pi * 2 + i) * 8.0;

      // 把圆压扁一点，使其看起来像水平拖拽的云雾 (椭圆)
      canvas.save();
      canvas.translate(dx, dy);
      canvas.scale(1.5, 0.8);
      canvas.drawCircle(Offset.zero, radius, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FogPainter oldDelegate) => oldDelegate.progress != progress;
}