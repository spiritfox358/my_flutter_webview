import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class NaturalSunlight extends StatefulWidget {
  final Widget child;

  const NaturalSunlight({super.key, required this.child});

  @override
  State<NaturalSunlight> createState() => _NaturalSunlightState();
}

class _NaturalSunlightState extends State<NaturalSunlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 模拟光线的自然呼吸感 (缓慢忽明忽暗)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. 底层内容
        widget.child,

        // 2. 光照层 (不拦截点击)
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  // A. 环境光晕 (Atmosphere Glow) - 模拟空气中的散射
                  Positioned(
                    top: -100,
                    left: -100,
                    width: 500,
                    height: 500,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.2,
                          colors: [
                            Colors.white.withOpacity(0.3 + 0.1 * _controller.value), // 核心亮
                            const Color(0xFFFFE0B2).withOpacity(0.1), // 边缘暖黄
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // B. 丁达尔光束 (God Rays) - 使用自定义画笔 + 高斯模糊
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GodRayPainter(
                        progress: _controller.value,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GodRayPainter extends CustomPainter {
  final double progress;

  _GodRayPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 技巧：使用 BlendMode.screen 或 plus 让光线与背景自然叠加变亮
    // 而不是覆盖背景
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen;

    // 光源原点 (屏幕左上角外)
    final Offset origin = const Offset(-80, -80);

    // 定义几束光线的参数 (角度偏移, 宽度, 长度比例, 基础透明度)
    // 通过调整这些参数，可以让光线看起来杂乱自然
    final List<List<double>> rays = [
      [0.2, 0.15, 0.9, 0.15], // [角度, 宽度, 长度, 透明度]
      [0.35, 0.1, 0.7, 0.10],
      [0.5, 0.2, 0.8, 0.12],
      [0.65, 0.08, 0.6, 0.08],
      [0.8, 0.15, 0.75, 0.10],
    ];

    for (var ray in rays) {
      // 动态呼吸效果
      double opacity = ray[3] + (0.05 * math.sin(progress * math.pi));

      // 设置渐变色 (从白到透明)
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(0.0), // 尾部完全透明
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      // 关键点：添加高斯模糊 (MaskFilter)
      // 这会让光束边缘变得朦胧，像真正的烟雾光
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

      // 计算光束路径 (扇形/梯形)
      Path path = Path();
      path.moveTo(origin.dx, origin.dy);

      // 利用三角函数计算光束落点
      double angle = ray[0]; // 基础角度
      double width = ray[1]; // 光束扩散宽度
      double length = size.height * ray[2] * 1.5; // 光束长度

      // 计算终点的两个角
      double x1 = origin.dx + length * math.cos(angle - width);
      double y1 = origin.dy + length * math.sin(angle - width);

      double x2 = origin.dx + length * math.cos(angle + width);
      double y2 = origin.dy + length * math.sin(angle + width);

      path.lineTo(x1, y1);
      path.lineTo(x2, y2);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GodRayPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}