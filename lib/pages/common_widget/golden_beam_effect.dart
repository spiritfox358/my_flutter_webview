import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: GoldenBeamDemoPage()));
}

class GoldenBeamDemoPage extends StatefulWidget {
  const GoldenBeamDemoPage({super.key});

  @override
  State<GoldenBeamDemoPage> createState() => _GoldenBeamDemoPageState();
}

class _GoldenBeamDemoPageState extends State<GoldenBeamDemoPage> {
  // --- 控制参数状态 ---
  double _speed = 1.0;          // 速度倍率
  double _beamCount = 10;       // 光束数量
  double _beamWidth = 10.0;     // 基础口径
  Color _beamColor = const Color(0xFFFFD700); // 默认金色

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 背景层 (使用 RepaintBoundary 隔离，防止被动画层带动重绘)
          RepaintBoundary(
            child: Image.network(
              'https://fzxt-resources.oss-cn-beijing.aliyuncs.com/assets/live/bg/bg_4.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // 2. 动态光束层
          // 传入所有控制参数
          GoldenBeamEffect(
            speed: _speed,
            beamCount: _beamCount.toInt(),
            baseWidth: _beamWidth,
            color: _beamColor,
          ),

          // 3. 悬浮控制面板 (UI 层)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("光束控制台 (调试模式)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // 颜色选择
                  Row(
                    children: [
                      _buildColorBtn(const Color(0xFFFFD700), "金"),
                      _buildColorBtn(Colors.white, "白"),
                      _buildColorBtn(const Color(0xFF00FFFF), "蓝"),
                      _buildColorBtn(const Color(0xFFFF0055), "红"),
                    ],
                  ),
                  const Divider(color: Colors.white24),

                  // 数量控制
                  _buildSlider("数量: ${_beamCount.toInt()}", _beamCount, 1, 50, (v) => setState(() => _beamCount = v)),

                  // 速度控制
                  _buildSlider("速度: ${_speed.toStringAsFixed(1)}x", _speed, 0.1, 5.0, (v) => setState(() => _speed = v)),

                  // 口径控制
                  _buildSlider("口径: ${_beamWidth.toStringAsFixed(1)}", _beamWidth, 2.0, 30.0, (v) => setState(() => _beamWidth = v)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: _beamColor,
            inactiveColor: Colors.white24,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildColorBtn(Color color, String label) {
    bool isSelected = _beamColor == color;
    return GestureDetector(
      onTap: () => setState(() => _beamColor = color),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)] : null,
        ),
      ),
    );
  }
}

class GoldenBeamEffect extends StatefulWidget {
  final double speed;
  final int beamCount;
  final double baseWidth;
  final Color color;

  const GoldenBeamEffect({
    super.key,
    required this.speed,
    required this.beamCount,
    required this.baseWidth,
    required this.color,
  });

  @override
  State<GoldenBeamEffect> createState() => _GoldenBeamEffectState();
}

class _GoldenBeamEffectState extends State<GoldenBeamEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 基础单位设为1秒，通过 value 累加控制速度
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 使用一个累计的时间变量，而不是依赖 controller.value 的循环
  // 这样调整速度时，动画会平滑过渡，不会跳变
  double _simulationTime = 0.0;
  double _lastTimestamp = 0.0;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // <--- 性能优化核心：隔离重绘
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 计算平滑的时间增量
          double now = DateTime.now().millisecondsSinceEpoch / 1000.0;
          if (_lastTimestamp == 0) _lastTimestamp = now;
          double dt = now - _lastTimestamp;
          _lastTimestamp = now;

          // 根据外部传入的 speed 累加时间
          // 基础速度除以 30，还原之前“慢速呼吸”的质感
          _simulationTime += dt * (widget.speed / 30.0);

          return CustomPaint(
            painter: _GoldenBeamPainter(
              progress: _simulationTime, // 传入累计时间
              beamCount: widget.beamCount,
              baseWidth: widget.baseWidth,
              color: widget.color,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _GoldenBeamPainter extends CustomPainter {
  final double progress; // 这里接收的是累计时间 (0.0 -> 无穷大)
  final int beamCount;
  final double baseWidth;
  final Color color;

  _GoldenBeamPainter({
    required this.progress,
    required this.beamCount,
    required this.baseWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..blendMode = BlendMode.screen;

    // 起点
    final Offset sourceOrigin = Offset(-50, size.height * 0.23);
    // 终点方向
    final Offset targetDirection = Offset(size.width, size.height * 0.60);

    double mainAngle = math.atan2(
      targetDirection.dy - sourceOrigin.dy,
      targetDirection.dx - sourceOrigin.dx,
    );

    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    for (int i = 0; i < beamCount; i++) {
      // 这里的 progress 已经包含了速度因子，是一个持续增长的 double
      // 直接放入 sin 中即可，无需担心周期重置问题，因为 sin 是周期函数

      // 1. 主要波动
      double mainWave = math.sin(progress * math.pi * 2 + (i * 0.4));

      // 2. 呼吸波动
      double breathingWave = math.sin(progress * math.pi * 2 + (i * 0.2) + math.pi / 4);

      // --- 角度计算 ---
      // 根据光束数量动态调整分散间距，数量越多，间距越密，防止散得太开
      double dynamicSpreadFactor = 0.55 / math.max(beamCount, 5);
      double baseSpread = (i - beamCount / 2) * dynamicSpreadFactor;

      double currentSpread = baseSpread * (1.0 + breathingWave * 0.12);
      double currentAngle = mainAngle + currentSpread + (mainWave * 0.007);

      // --- 口径计算 ---
      // 使用传入的 baseWidth
      double calculatedStartWidth = baseWidth + (i % 5) * 2.5 + (i % 2) * 1.5;
      double currentStartWidth = calculatedStartWidth * (1.0 + breathingWave * 0.06);

      double length = size.width * 2.5;

      // --- 透明度计算 ---
      double alpha = 0.04 + ((mainWave + 1) / 2) * 0.07;

      paint.shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withOpacity(alpha),
          color.withOpacity(alpha * 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width * 1.2, size.height));

      _drawRay(canvas, sourceOrigin, currentAngle, currentStartWidth, length, paint);
    }
  }

  void _drawRay(Canvas canvas, Offset origin, double angle, double startWidth, double length, Paint paint) {
    Path path = Path();

    double dx = math.cos(angle + math.pi / 2);
    double dy = math.sin(angle + math.pi / 2);

    Offset p1 = Offset(origin.dx - dx * startWidth, origin.dy - dy * startWidth);
    Offset p2 = Offset(origin.dx + dx * startWidth, origin.dy + dy * startWidth);

    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);

    // 终点扩散随起点动态调整
    double endWidth = startWidth * 7.0;

    Offset endCenter = Offset(
        origin.dx + math.cos(angle) * length,
        origin.dy + math.sin(angle) * length
    );

    Offset p3 = Offset(endCenter.dx + dx * endWidth, endCenter.dy + dy * endWidth);
    Offset p4 = Offset(endCenter.dx - dx * endWidth, endCenter.dy - dy * endWidth);

    path.lineTo(p3.dx, p3.dy);
    path.lineTo(p4.dx, p4.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldenBeamPainter oldDelegate) {
    // 只要有参数变化，就必须重绘
    return oldDelegate.progress != progress ||
        oldDelegate.beamCount != beamCount ||
        oldDelegate.baseWidth != baseWidth ||
        oldDelegate.color != color;
  }
}