import 'dart:math' as math;
import 'package:flutter/material.dart';

class SunlightOverlay extends StatefulWidget {
  final Widget child;
  final bool enable;

  const SunlightOverlay({
    super.key,
    required this.child,
    this.enable = true,
  });

  @override
  State<SunlightOverlay> createState() => _SunlightOverlayState();
}

class _SunlightOverlayState extends State<SunlightOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 让光线有轻微的呼吸感，更加逼真
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) return widget.child;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. 底层页面内容
        widget.child,

        // 2. 光照层 (使用 IgnorePointer 防止拦截点击事件)
        IgnorePointer(
          child: Stack(
            children: [
              // --- A. 主光束 (照亮整体) ---
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-1.2, -1.2), // 从左上角屏幕外射入
                      end: const Alignment(0.8, 0.8),     // 射向右下角
                      colors: [
                        Colors.white.withOpacity(0.4), // 光源核心最亮
                        Colors.white.withOpacity(0.1), // 中间过渡
                        Colors.transparent,            // 边缘消失
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // --- B. 散射光 (God Rays) ---
              // 使用 CustomPaint 画出几束明显的“光路”
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _LightRayPainter(
                        opacity: 0.2 + 0.1 * _controller.value, // 呼吸透明度
                      ),
                    );
                  },
                ),
              ),

              // --- C. 混合模式层 (让光看起来是“叠加”上去的，而不是白色的遮罩) ---
              // 注意：BlendMode 在深色背景上效果最好
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-1.0, -1.0), // 左上角
                      radius: 1.5,
                      colors: [
                        const Color(0xFFFFF9C4).withOpacity(0.15), // 暖黄色光晕
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 🎨 自定义画笔：画出几束明显的射线
class _LightRayPainter extends CustomPainter {
  final double opacity;

  _LightRayPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen; // 滤色模式，增加亮度

    // 光源原点 (屏幕左上角外面一点)
    const Offset origin = Offset(-50, -50);

    // 定义几束光线的路径
    final List<Path> rays = [];

    // 光束 1 (宽)
    Path path1 = Path();
    path1.moveTo(origin.dx, origin.dy);
    path1.lineTo(size.width * 0.4, size.height * 0.6);
    path1.lineTo(size.width * 0.6, size.height * 0.4);
    path1.close();

    // 渐变填充
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(opacity),
        Colors.white.withOpacity(0.0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path1, paint);

    // 光束 2 (窄长)
    Path path2 = Path();
    path2.moveTo(origin.dx + 20, origin.dy);
    path2.lineTo(size.width * 0.8, size.height * 0.9);
    path2.lineTo(size.width * 0.9, size.height * 0.8);
    path2.close();

    // 使用稍微不同的透明度
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(opacity * 0.6),
        Colors.white.withOpacity(0.0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _LightRayPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}