import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: GodRayDemoPage()));
}

// 演示页面
class GodRayDemoPage extends StatelessWidget {
  const GodRayDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 背景图片层 (使用你提供的图片作为背景)
          Image.network(
            // 这里替换成你实际的图片地址，我先用一个占位符代替演示
            'https://fzxt-resources.oss-cn-beijing.aliyuncs.com/assets/live/bg/bg_3.png',
            // 'https://fzxt-resources.oss-cn-beijing.aliyuncs.com/assets/live/bg/bg_4.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // 如果图片加载失败，显示一个深色背景以便观察光效
              return Container(color: const Color(0xFF2A2A2A));
            },
          ),

          // 2. 光照特效层 (叠加在背景之上)
          const WarmGodRayEffect(),
        ],
      ),
    );
  }
}

/// 暖色丁达尔光效组件
class WarmGodRayEffect extends StatefulWidget {
  const WarmGodRayEffect({super.key});

  @override
  State<WarmGodRayEffect> createState() => _WarmGodRayEffectState();
}

class _WarmGodRayEffectState extends State<WarmGodRayEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 添加一个非常缓慢的“呼吸”动画，让光线看起来是活的，更真实
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 IgnorePointer 确保光效层不会拦截用户的触摸事件
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WarmGodRayPainter(
              // 动画值在 0.0 到 1.0 之间波动，我们用它微调整体透明度
              breathValue: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _WarmGodRayPainter extends CustomPainter {
  final double breathValue;

  _WarmGodRayPainter({required this.breathValue});

  // 定义暖光的主色调 (米黄色/淡金色)
  final Color warmLightColor = const Color(0xFFFFF5E1);

  @override
  void paint(Canvas canvas, Size size) {
    // 关键点 1: 使用 BlendMode.screen (滤色模式)
    // 这会让光线的颜色与背景叠加变亮，模拟真实光照，而不是覆盖背景。
    final Paint paint = Paint()..blendMode = BlendMode.screen;

    // 光源原点设置在左上角屏幕外
    final Offset sourceOrigin = Offset(-size.width * 0.2, -size.height * 0.2);

    // --- 步骤 A: 绘制环境辉光 (Atmosphere Glow) ---
    // 模拟光源附近空气被照亮的大片朦胧区域
    final glowPaint = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5, // 光晕范围很大
        colors: [
          // 核心较亮，带有暖意
          warmLightColor.withOpacity(0.4 + 0.1 * breathValue),
          // 向外扩散变暖黄
          const Color(0xFFFFD54F).withOpacity(0.15),
          // 边缘完全透明
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);


    // --- 步骤 B: 绘制丁达尔光束 (God Rays) ---

    // 关键点 2: 高斯模糊 (MaskFilter.blur)
    // 这是制造朦胧感的关键，数值越大，边缘越柔和。
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);

    // 定义几束光线的参数：[基础角度, 扩散宽度, 长度比例, 基础透明度]
    // 参数随机一些，模拟自然的不规则感
    final List<List<double>> rayConfigs = [
      [0.35, 0.12, 1.1, 0.18], // 主光束
      [0.55, 0.08, 0.9, 0.12], // 细长光束
      [0.75, 0.15, 0.8, 0.10], // 较宽较淡的光束
      [0.20, 0.05, 1.0, 0.15], // 顶部边缘光束
    ];

    for (var config in rayConfigs) {
      double baseAngle = config[0];
      double spreadWidth = config[1];
      double lengthScale = config[2];
      double baseOpacity = config[3];

      // 根据呼吸动画微调每束光的透明度
      double currentOpacity = baseOpacity + (0.03 * breathValue);

      // 为每束光设置线性渐变：从光源处亮，向远处逐渐消失
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          warmLightColor.withOpacity(currentOpacity),
          warmLightColor.withOpacity(0.0), // 尾部透明
        ],
        stops: const [0.1, 0.8], // 让渐变在中间部分发生，两头更柔和
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      // 计算光束梯形路径
      Path path = Path();
      path.moveTo(sourceOrigin.dx, sourceOrigin.dy);

      // 计算光束的终点（射向右下万）
      double rayLength = size.height * lengthScale * 1.8;

      // 计算光束终点的两个角，形成一个发散的梯形
      double x1 = sourceOrigin.dx + rayLength * math.cos(baseAngle - spreadWidth);
      double y1 = sourceOrigin.dy + rayLength * math.sin(baseAngle - spreadWidth);

      double x2 = sourceOrigin.dx + rayLength * math.cos(baseAngle + spreadWidth);
      double y2 = sourceOrigin.dy + rayLength * math.sin(baseAngle + spreadWidth);

      path.lineTo(x1, y1);
      path.lineTo(x2, y2);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WarmGodRayPainter oldDelegate) {
    // 当呼吸动画值变化时重绘
    return oldDelegate.breathValue != breathValue;
  }
}