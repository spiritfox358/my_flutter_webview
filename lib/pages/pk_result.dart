import 'dart:async';
import 'package:flutter/material.dart';

// 定义 PK 提示的不同阶段
enum PKOverlayStep { none, pointsAdded, rankProgress }

class PkResultPage extends StatefulWidget {
  // =========================================================
  // 👇 生产环境参数：保持不变 👇
  // =========================================================
  final bool isVictory;
  final int addedPoints;
  final int addedPkValue;
  final String rankName;
  final double currentPoints;
  final double maxPoints;
  final String rankImageUrl;
  final int displayDuration;

  const PkResultPage({
    Key? key,
    this.isVictory = true,
    this.addedPoints = 150,
    this.addedPkValue = 1200,
    this.rankName = '钻1星',
    this.currentPoints = 447.19,
    this.maxPoints = 18000,
    this.rankImageUrl = 'https://fzxt-resources.oss-cn-beijing.aliyuncs.com/assets/live/pk_rank/%E9%92%BB%E7%9F%B3%E4%BA%94%E6%98%9F.png',
    this.displayDuration = 10,
  }) : super(key: key);

  @override
  State<PkResultPage> createState() => _PkResultPageState();
}

class _PkResultPageState extends State<PkResultPage> {
  // 当前展示阶段
  PKOverlayStep _currentStep = PKOverlayStep.none;

  // 接收外部传来的参数到内部状态
  late bool _isVictory = widget.isVictory;
  late String _rankName = widget.rankName;
  late double _currentPoints = widget.currentPoints;
  late double _maxPoints = widget.maxPoints;
  late int _addedPoints = widget.addedPoints;
  late int _addedPkValue = widget.addedPkValue;
  late String _rankImageUrl = widget.rankImageUrl;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _triggerPKEndSequence(_isVictory));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 触发 PK 结束的序列动画
  void _triggerPKEndSequence(bool isVictory) {
    if (_currentStep != PKOverlayStep.none) return;

    setState(() {
      _isVictory = isVictory;
      _currentStep = PKOverlayStep.pointsAdded;
    });

    _timer = Timer(Duration(seconds: widget.displayDuration), () {
      if (!mounted) return;
      setState(() {
        _currentStep = PKOverlayStep.rankProgress;
      });

      _timer = Timer(Duration(seconds: widget.displayDuration), () {
        if (!mounted) return;
        setState(() {
          _currentStep = PKOverlayStep.none;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // 底层：控制按钮（仅用于开发测试）
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _triggerPKEndSequence(true),
                  child: const Text("模拟 PK 胜利"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _triggerPKEndSequence(false),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("模拟 PK 失败"),
                ),
              ],
            ),
          ),

          // 顶层：悬浮提示框
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOut),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: _buildOverlayContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 发光边框线
  Widget _buildGradientLine() {
    return Container(
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent, // 1. 起始：完全透明
            Colors.lightBlueAccent.withOpacity(0.7), // 2. 中间：完全不透明 (改为了1.0更亮)
            Colors.lightBlueAccent.withOpacity(0.7), // 3. 中间延续：完全不透明 (新增一个点，保持亮度)
            Colors.transparent, // 4. 结束：完全透明
          ],
          // 👇 关键修改：定义每个颜色在 0.0 到 1.0 之间的位置
          // 0.0 = 最左边, 1.0 = 最右边
          stops: const [
            0.0, // 0% 处开始透明
            0.30, // 35% 处才变成完全不透明 (之前渐变区域变长了)
            0.70, // 65% 处依然保持完全不透明 (中间高亮区域占据了 35%~65%，共30%的宽度)
            1.0, // 100% 处结束透明
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.lightBlueAccent.withOpacity(0.5),
        //     blurRadius: 4,
        //     spreadRadius: 0,
        //   ),
        // ],
      ),
    );
  }

  // 极简实体背景框组件
  Widget _buildSolidCenterContainer({required Key key, required Widget child}) {
    final double halfScreenWidth = MediaQuery.of(context).size.width * 0.5;

    return SizedBox(
      key: key,
      width: halfScreenWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.80),
                  Colors.black.withOpacity(0.80),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.15, 0.85, 1.0],
              ),
            ),
            child: child,
          ),
          Positioned(top: 0, left: 0, right: 0, child: _buildGradientLine()),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildGradientLine()),
        ],
      ),
    );
  }

  // 精致发光的段位图片
  Widget _buildRankImage({double height = 40}) {
    return Container(
      decoration: BoxDecoration(
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.lightBlueAccent.withOpacity(0),
          //     blurRadius: 10,
          //     spreadRadius: 2,
          //   ),
          // ],
          ),
      child: Image.network(
        _rankImageUrl,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => SizedBox(height: height),
      ),
    );
  }

  // ★ 核心修改：构建带有向外渐变透明短线的标题
  Widget _buildTitleWithLines(String title) {
    // 增加了一个 isLeft 参数来控制渐变的方向
    Widget glowingLine({required bool isLeft}) {
      return Container(
        width: 30, // 短线宽度
        height: 1.5, // 短线高度
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // 如果是左边的线，从透明过渡到青色；如果是右边的线，从青色过渡到透明
            colors:
                isLeft ? [Colors.transparent, const Color(0xFF00FFFF).withAlpha(150)] : [const Color(0xFF00FFFF).withAlpha(150), Colors.transparent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: const Color(0xFF00FFFF).withAlpha(100),
          //     blurRadius: 4,
          //     spreadRadius: 0,
          //   ),
          // ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        glowingLine(isLeft: true), // 左侧向左透明
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        glowingLine(isLeft: false), // 右侧向右透明
      ],
    );
  }

  // 核心内容组件
  Widget _buildOverlayContent() {
    switch (_currentStep) {
      case PKOverlayStep.none:
        return const SizedBox.shrink(key: ValueKey('none'));

      // 阶段一：胜利大字 + 积分明细
      case PKOverlayStep.pointsAdded:
        return Column(
          key: const ValueKey('points_added_full'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isVictory ? "胜 利" : "失 败",
              style: TextStyle(
                color: _isVictory ? const Color(0xFFFFD700) : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
            ),
            const SizedBox(height: 4),
            _buildSolidCenterContainer(
              key: const ValueKey('points_panel'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 使用升级后的渐变短线标题
                  _buildTitleWithLines('积分'),
                  const SizedBox(height: 4),

                  Text(
                    _isVictory ? "+$_addedPoints" : "+0",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 0.5, color: Colors.white12),
                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("PK值", style: TextStyle(color: Colors.white54, fontSize: 10)),
                      Text(_isVictory ? "+$_addedPkValue" : "+0", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),

                  const SizedBox(height: 2),
                  const Text(
                    "钻石及以上段位仅在巅峰赛获取积分",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );

      // 阶段二：段位图片 (在外部) + 段位名称 + 进度条组件
      case PKOverlayStep.rankProgress:
        return Column(
          key: const ValueKey('rank_progress_full_with_outside_image'),
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRankImage(height: 80),
            const SizedBox(height: 8),
            _buildSolidCenterContainer(
              key: const ValueKey('rank_progress_container'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _rankName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _currentPoints / _maxPoints,
                      minHeight: 2,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF81B4FF)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_currentPoints.toStringAsFixed(2)} / ${_maxPoints.toInt()}",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
