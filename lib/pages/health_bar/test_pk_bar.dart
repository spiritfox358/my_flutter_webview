import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:my_flutter_webview/pages/health_bar/widgets/pk_fog_overlay.dart';
import 'package:my_flutter_webview/pages/health_bar/widgets/pk_freeze_overlay.dart';

// ===========================================================================
// 🛠️ 测试沙盒页面：在这里随意测试和调整你的组件
// ===========================================================================

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TestPKScoreBarPage(),
  ));
}

// ================================================================
// 🛠️ 全局核心参数区：控制箭头的锐利/钝角程度
// ================================================================
const double kArrowSharpness = 9.0;

// ================================================================
class TestPKScoreBarPage extends StatefulWidget {
  const TestPKScoreBarPage({super.key});

  @override
  State<TestPKScoreBarPage> createState() => _TestPKScoreBarPageState();
}

class _TestPKScoreBarPageState extends State<TestPKScoreBarPage> {
  // 假数据状态
  int myScore = 1500;
  int oppScore = 1200;
  PKStatus currentStatus = PKStatus.playing;
  int secondsLeft = 180;

  // 🟢 修复1：加上独立的冰冻和迷雾变量
  bool myFrozen = false;
  bool oppFrozen = false;
  bool myFog = false;
  bool oppFog = false;

  final String myRoomId = "room_me_123";
  final String oppRoomId = "room_opp_456";
  Map<String, DateTime> critEndTimes = {};

  Timer? _globalTimer;

  @override
  void initState() {
    super.initState();
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft > 0 && currentStatus == PKStatus.playing) {
        if (mounted) setState(() => secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    super.dispose();
  }

  void _triggerCrit(bool isMe) {
    setState(() {
      critEndTimes = Map.from(critEndTimes);
      String targetRoom = isMe ? myRoomId : oppRoomId;
      critEndTimes[targetRoom] = DateTime.now().add(const Duration(seconds: 15));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E28),
      appBar: AppBar(
        title: const Text("PK 血条调试沙盒"),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                PKScoreBar(
                  myScore: myScore,
                  opponentScore: oppScore,
                  status: currentStatus,
                  secondsLeft: secondsLeft,
                  myRoomId: myRoomId,
                  critEndTimes: critEndTimes,
                  isMyFrozen: myFrozen,
                  isOppFrozen: oppFrozen,
                  isMyFog: myFog,         // 👈 传入我方迷雾状态
                  isOppFog: oppFog,       // 👈 传入敌方迷雾状态
                ),
                Positioned(
                  top: -18,
                  child: PKTimer(
                    secondsLeft: secondsLeft,
                    status: currentStatus,
                    myScore: myScore,
                    opponentScore: oppScore,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("控制台 (点击测试动画)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () => setState(() => myScore += 500),
                      child: const Text("我方 +500"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      onPressed: () => setState(() => oppScore += 500),
                      child: const Text("敌方 +500"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                      onPressed: () => setState(() {
                        secondsLeft = 10;
                        currentStatus = PKStatus.playing;
                      }),
                      child: const Text("🔥 倒计时 10s (狂暴)"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () => _triggerCrit(true),
                      child: const Text("我方暴击"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400]),
                      onPressed: () => setState(() {
                        myScore = 0; oppScore = 0; secondsLeft = 180; critEndTimes.clear();
                        myFrozen = false; oppFrozen = false; myFog = false; oppFog = false;
                      }),
                      child: const Text("重置"),
                    ),

                    // 🟢 修复2：独立的冰冻与迷雾按钮
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                      onPressed: () => setState(() => oppFrozen = !oppFrozen),
                      child: Text(oppFrozen ? "解冻敌方" : "🧊 冻住敌方"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700]),
                      onPressed: () => setState(() => myFrozen = !myFrozen),
                      child: Text(myFrozen ? "解冻我方" : "🧊 冻住我方"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                      onPressed: () => setState(() => oppFog = !oppFog),
                      child: Text(oppFog ? "取消敌方迷雾" : "🌫️ 迷雾敌方"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[900]),
                      onPressed: () => setState(() => myFog = !myFog),
                      child: Text(myFog ? "取消我方迷雾" : "🌫️ 迷雾我方"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum PKStatus { idle, matching, playing, punishment, coHost }

class PKScoreBar extends StatefulWidget {
  final int myScore;
  final int opponentScore;
  final PKStatus status;
  final int secondsLeft;
  final String myRoomId;
  final Map<String, DateTime> critEndTimes;

  final bool isMyFrozen;
  final bool isOppFrozen;
  final bool isMyFog;
  final bool isOppFog;

  const PKScoreBar({
    super.key,
    required this.myScore,
    required this.opponentScore,
    required this.status,
    required this.secondsLeft,
    required this.myRoomId,
    required this.critEndTimes,
    this.isMyFrozen = false,
    this.isOppFrozen = false,
    this.isMyFog = false,
    this.isOppFog = false,
  });

  @override
  State<PKScoreBar> createState() => PKScoreBarState();
}

class PKScoreBarState extends State<PKScoreBar> with TickerProviderStateMixin {
  Map<String, DateTime> _currentCritEndTimes = {};
  int _myCritSecondsLeft = 0;
  int _oppCritSecondsLeft = 0;

  final double critCardOffsetX = -14.0;
  final double critCardOffsetY = -5.0;
  final double scorePopTopOffset = 0.0;

  int _oldMyScore = 0;
  int _addedScore = 0;
  Duration _barAnimationDuration = const Duration(milliseconds: 1500);
  DateTime? _lastMyScoreTime;
  bool _isCombo = false;

  late AnimationController _popController;
  late Animation<double> _popScale;
  late Animation<double> _popOpacity;
  late AnimationController _flashController;
  late Animation<double> _flashValue;
  late AnimationController _comboTextScaleController;
  late Animation<double> _comboTextScale;

  late AnimationController _lightningController;
  late AnimationController _critBreathController;
  late Animation<double> _critBreathScale;

  late AnimationController _feverController;
  late Animation<double> _feverAnimation;

  Timer? _localCritTimer;

  bool get isFever => widget.secondsLeft <= 10 && widget.secondsLeft > 0 && widget.status == PKStatus.playing;

  @override
  void initState() {
    super.initState();
    _currentCritEndTimes = Map.from(widget.critEndTimes);
    _oldMyScore = widget.myScore;

    _popController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _popScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: const Interval(0.0, 0.1, curve: Curves.easeOutExpo)),
    );
    _popOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _popController, curve: const Interval(0.8, 1.0)));

    _flashController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _flashValue = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOutQuad));

    _comboTextScaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _comboTextScale = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(parent: _comboTextScaleController, curve: Curves.easeInOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _comboTextScaleController.reverse();
      });

    _lightningController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _critBreathController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _critBreathScale = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _critBreathController, curve: Curves.easeInOut));

    _feverController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _feverAnimation = CurvedAnimation(parent: _feverController, curve: Curves.easeOutBack);
    if (isFever) _feverController.value = 1.0;

    _checkCritTime();
    _startLocalCritTimer();
  }

  void _startLocalCritTimer() {
    _localCritTimer?.cancel();
    _localCritTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkCritTime();
    });
  }

  void _checkCritTime() {
    final now = DateTime.now();
    int myMax = 0;
    int oppMax = 0;

    _currentCritEndTimes.forEach((roomId, endTime) {
      final diff = endTime.difference(now).inSeconds;
      if (diff > 0) {
        if (roomId == widget.myRoomId) {
          myMax = diff;
        } else {
          if (diff > oppMax) oppMax = diff;
        }
      }
    });

    if (_myCritSecondsLeft != myMax || _oppCritSecondsLeft != oppMax) {
      setState(() {
        _myCritSecondsLeft = myMax;
        _oppCritSecondsLeft = oppMax;
      });
      _updateCritBreathAnimation();
    }
  }

  void _updateCritBreathAnimation() {
    if (_myCritSecondsLeft > 0) {
      if (!_critBreathController.isAnimating) _critBreathController.repeat(reverse: true);
    } else {
      if (_critBreathController.isAnimating) {
        _critBreathController.stop();
        _critBreathController.reset();
      }
    }
  }

  @override
  void didUpdateWidget(covariant PKScoreBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool wasFever = oldWidget.secondsLeft <= 10 && oldWidget.secondsLeft > 0 && oldWidget.status == PKStatus.playing;
    if (isFever && !wasFever) {
      _feverController.forward();
    } else if (!isFever && wasFever) {
      _feverController.reverse();
    }

    _currentCritEndTimes = Map.from(widget.critEndTimes);
    _checkCritTime();

    if (widget.myScore > _oldMyScore) {
      _addedScore = widget.myScore - _oldMyScore;
      final now = DateTime.now();
      final bool isComboNow = _lastMyScoreTime != null && now.difference(_lastMyScoreTime!) < const Duration(seconds: 3);
      _lastMyScoreTime = now;

      setState(() {
        _isCombo = isComboNow;
        if (isComboNow) {
          _barAnimationDuration = Duration.zero;
          _comboTextScaleController.forward(from: 0.0);
        } else {
          _barAnimationDuration = const Duration(milliseconds: 1500);
        }
      });
      _popController.reset();
      _popController.forward();
      _flashController.reset();
      _flashController.forward().then((_) => _flashController.reverse());

      if (_myCritSecondsLeft > 0) {
        _lightningController.forward(from: 0.0);
      }
    }
    _oldMyScore = widget.myScore;

    if (_myCritSecondsLeft > 0) {
      if (!_critBreathController.isAnimating) _critBreathController.repeat(reverse: true);
    } else {
      if (_critBreathController.isAnimating) {
        _critBreathController.stop();
        _critBreathController.reset();
      }
    }
  }

  @override
  void deactivate() {
    _feverController.stop();
    _critBreathController.stop();
    _lightningController.stop();
    _popController.stop();
    _flashController.stop();
    _comboTextScaleController.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _feverController.dispose();
    _popController.dispose();
    _flashController.dispose();
    _comboTextScaleController.dispose();
    _lightningController.dispose();
    _critBreathController.dispose();
    _localCritTimer?.cancel();
    super.dispose();
  }

  String _formatScore(int score) {
    if (score >= 1000000) return "${(score / 10000.0).toStringAsFixed(1)}万";
    return score.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == PKStatus.idle) return const SizedBox();

    final total = widget.myScore + widget.opponentScore;
    double targetRatio = total == 0 ? 0.5 : widget.myScore / total;

    bool isHighScore = widget.myScore >= 1000000 || widget.opponentScore >= 1000000;
    targetRatio = targetRatio.clamp(isHighScore ? 0.26 : 0.15, 0.85);

    final bool isRedWinning = widget.myScore >= widget.opponentScore;

    final Radius centerRadius = total == 0 ? Radius.zero : const Radius.circular(20);
    final double currentPopRightPadding = _myCritSecondsLeft > 0 ? 13.0 : 5.0;

    String myScoreText = _formatScore(widget.myScore);
    String oppScoreText = _formatScore(widget.opponentScore);

    if (isHighScore) {
      int diff = widget.myScore - widget.opponentScore;
      int absDiff = diff.abs();
      String diffStr = absDiff >= 1000000 ? "${(absDiff / 10000.0).toStringAsFixed(1)}万" : absDiff.toString();
      if (diff > 0)
        myScoreText = "领先 $diffStr";
      else if (diff < 0)
        myScoreText = "落后 $diffStr";
      else
        myScoreText = "平局";
      oppScoreText = "";
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: targetRatio),
          duration: _barAnimationDuration,
          curve: Curves.easeOutExpo,
          builder: (context, ratio, child) {
            final leftWidth = maxWidth * ratio;
            final rightWidth = maxWidth - leftWidth;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _feverController,
                      builder: (context, child) {
                        final double currentHeight = 18.0 + 6.0 * _feverAnimation.value;

                        return SizedBox(
                          width: maxWidth,
                          height: currentHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerLeft,
                            children: [
                              // --- 1. 蓝条 (底层背景) ---
                              Container(color: Colors.grey[800]),
                              Positioned(
                                right: 0,
                                width: rightWidth + 20.0,
                                top: 0,
                                bottom: 0,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF448AFF), Color(0xFF2962FF)])),
                                    ),

                                    // 🧊 敌方冰冻 / 迷雾
                                    if (widget.isOppFrozen) const Positioned.fill(child: PKFreezeOverlay()),
                                    if (widget.isOppFog) const Positioned.fill(child: PKFogOverlay()),

                                    Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        oppScoreText,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, height: 1.1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // --- 2. 红条 (带箭头剪裁遮罩) ---
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ClipPath(
                                  clipper: _FeverArrowClipper(
                                    feverValue: _feverAnimation.value,
                                    normalRadius: centerRadius,
                                    isRedWinning: isRedWinning,
                                  ),
                                  child: SizedBox(
                                    width: leftWidth,
                                    height: currentHeight,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                            decoration:
                                            const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF5252)]))),

                                        // 🧊 我方冰冻 / 迷雾
                                        if (widget.isMyFrozen) const Positioned.fill(child: PKFreezeOverlay()),
                                        if (widget.isMyFog) const Positioned.fill(child: PKFogOverlay()),

                                        if (total > 0)
                                          AnimatedBuilder(
                                            animation: _flashController,
                                            builder: (context, child) {
                                              final double t = _flashValue.value;
                                              final double intensity = ((_isCombo ? 1.0 : 0.75) + (0.15 * t)).clamp(0.0, 1.0);
                                              return Positioned(
                                                right: 0,
                                                top: 0,
                                                bottom: 0,
                                                width: 40.0 + (15.0 * t),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.centerRight,
                                                      end: Alignment.centerLeft,
                                                      stops: const [0.0, 0.4, 1.0],
                                                      colors: [
                                                        Colors.white.withOpacity(intensity),
                                                        Colors.white.withOpacity(intensity * 0.4),
                                                        Colors.white.withOpacity(0.0),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8, right: 12),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                myScoreText,
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, height: 1.1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // --- 3. 狂暴火焰交界特效 ---
                              Positioned(
                                left: leftWidth - 44,
                                top: -12,
                                bottom: -12,
                                width: 88,
                                child: PKDividerEffect(
                                  isZeroScore: total == 0,
                                  feverValue: _feverAnimation.value,
                                  isRedWinning: isRedWinning,
                                  barHeight: currentHeight,
                                  // 🟢 修复3：只在我方(左侧)被冻住时，才隐藏中间的气泡和岩浆！
                                  isFrozen: widget.isMyFrozen,
                                ),
                              ),

                              // --- 4. 加分飘字 ---
                              if (_popController.isAnimating || _popController.isCompleted)
                                Positioned(
                                  left: 0,
                                  top: scorePopTopOffset,
                                  bottom: -scorePopTopOffset,
                                  width: leftWidth,
                                  child: AnimatedBuilder(
                                    animation: _popController,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _popOpacity.value,
                                        child: Transform.scale(
                                          scale: _isCombo ? 1.0 : _popScale.value,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.only(right: currentPopRightPadding),
                                            child: AnimatedBuilder(
                                              animation: _comboTextScaleController,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: _comboTextScale.value,
                                                  child: Text(
                                                    "+$_addedScore",
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _oppCritSecondsLeft > 0 ? _buildCritLabel(false, _oppCritSecondsLeft) : const SizedBox(),
                      ],
                    ),
                  ],
                ),

                if (_myCritSecondsLeft > 0)
                  Positioned(
                    left: leftWidth + critCardOffsetX,
                    top: critCardOffsetY,
                    child: AnimatedBuilder(
                      animation: _critBreathController,
                      builder: (context, child) {
                        return Transform.scale(scale: _critBreathScale.value, child: child);
                      },
                      child: Image.network(
                        'https://fzxt-resources.oss-cn-beijing.aliyuncs.com/assets/mystery_shop/icon/%E6%9A%B4%E5%87%BB%E5%8D%A1_prop.png',
                        width: 28,
                        height: 28,
                        colorBlendMode: BlendMode.multiply,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCritLabel(bool isMe, int seconds) {
    if (!isMe) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isMe ? Alignment.centerLeft : Alignment.centerRight,
          end: isMe ? Alignment.centerRight : Alignment.centerLeft,
          colors: isMe ? [const Color(0xFFFF2E56), Colors.transparent] : [const Color(0xFF2962FF), Colors.transparent],
          stops: const [0.2, 1.0],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMe) const Icon(Icons.arrow_back_ios, size: 8, color: Colors.white),
          if (!isMe) const SizedBox(width: 4),
          Text(isMe ? "暴击卡生效中  ${seconds}s " : "暴击中... ", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
          if (isMe) const Icon(Icons.arrow_forward_ios, size: 8, color: Colors.white),
        ],
      ),
    );
  }
}

class _FeverArrowClipper extends CustomClipper<Path> {
  final double feverValue;
  final Radius normalRadius;
  final bool isRedWinning;

  _FeverArrowClipper({
    required this.feverValue,
    required this.normalRadius,
    required this.isRedWinning,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double indent = kArrowSharpness * feverValue;
    final double r = math.min(normalRadius.x, size.height / 2) * (1 - feverValue);

    final double cornerX = isRedWinning ? size.width - indent : size.width;
    final double tipX = isRedWinning ? size.width : size.width - indent;

    path.moveTo(0, 0);

    if (r > 0) {
      path.lineTo(cornerX - r, 0);
      path.arcToPoint(Offset(cornerX, r), radius: Radius.circular(r), clockwise: true);
    } else {
      path.lineTo(cornerX, 0);
    }

    path.lineTo(tipX, size.height / 2);

    if (r > 0) {
      path.lineTo(cornerX, size.height - r);
      path.arcToPoint(Offset(cornerX - r, size.height), radius: Radius.circular(r), clockwise: true);
    } else {
      path.lineTo(cornerX, size.height);
    }

    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _FeverArrowClipper oldClipper) {
    return oldClipper.feverValue != feverValue || oldClipper.isRedWinning != isRedWinning;
  }
}

class PKDividerEffect extends StatefulWidget {
  final bool isZeroScore;
  final double feverValue;
  final bool isRedWinning;
  final double barHeight;
  final bool isFrozen;

  const PKDividerEffect({
    super.key,
    required this.isZeroScore,
    required this.feverValue,
    required this.isRedWinning,
    required this.barHeight,
    this.isFrozen = false,
  });

  @override
  State<PKDividerEffect> createState() => _PKDividerEffectState();
}

class _PKDividerEffectState extends State<PKDividerEffect> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;
  final math.Random _random = math.Random();

  final List<_PKParticle> _particles = [];
  final List<_PKFeverFragment> _feverFragments = [];

  final double safeOffset = 15.0;
  final double spawnRate = 0.5;
  final double speedMin = 20.0;
  final double speedMax = 50.0;
  final double jumpPower = 30.0;
  final double sizeMin = 2.0;
  final double sizeMax = 5.0;
  final double lifeTime = 0.5;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (_lastTime == Duration.zero) {
        _lastTime = elapsed;
        return;
      }
      final double dt = (elapsed - _lastTime).inMilliseconds / 1000.0;
      _lastTime = elapsed;
      _updateAllEffects(dt);
    });
    _ticker.start();
  }

  void _updateAllEffects(double dt) {
    if (widget.isFrozen) {
      if (_particles.isNotEmpty || _feverFragments.isNotEmpty) {
        _particles.clear();
        _feverFragments.clear();
        if (mounted) setState(() {});
      }
      return;
    }

    if (widget.feverValue == 0) {
      if (_random.nextDouble() < 0.15) {
        if (widget.isZeroScore) {
          _particles.add(_createParticle(isLeft: true));
          _particles.add(_createParticle(isLeft: false));
        } else {
          _particles.add(_createParticle(isLeft: true));
        }
      }
    }
    for (var p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt * p.decayRate;
    }
    _particles.removeWhere((p) => p.life <= 0);

    if (widget.feverValue > 0) {
      if (_random.nextDouble() < (spawnRate * widget.feverValue)) {
        _feverFragments.add(_createFeverFragment());
      }
    }
    for (var f in _feverFragments) {
      f.x += f.vx * dt;
      f.y += f.vy * dt;
      f.life -= dt * f.decayRate;
    }
    _feverFragments.removeWhere((f) => f.life <= 0);

    if (mounted) setState(() {});
  }

  _PKParticle _createParticle({required bool isLeft}) {
    final double startX = widget.isZeroScore ? 0.0 : -8.0;
    final double yRange = widget.isZeroScore ? 8.0 : 4.5;
    final double startY = _random.nextDouble() * (yRange * 2) - yRange;
    final double baseVx = _random.nextDouble() * 15 + 10;
    final double vx = (isLeft ? -1 : 1) * baseVx;
    final double vy = _random.nextDouble() * 4 - 2;

    return _PKParticle(
      x: startX,
      y: startY,
      vx: vx,
      vy: vy,
      size: _random.nextDouble() * 1.0 + 0.5,
      color: Colors.white,
      life: 1.0,
      decayRate: _random.nextDouble() * 1.2 + 0.6,
    );
  }

  _PKFeverFragment _createFeverFragment() {
    final double indent = kArrowSharpness * widget.feverValue;
    final double startX = widget.isRedWinning ? -(indent + safeOffset) : (indent + safeOffset);
    final double spawnRangeY = widget.barHeight * 0.85;
    final double startY = (_random.nextDouble() - 0.5) * spawnRangeY;

    final double baseVx = _random.nextDouble() * (speedMax - speedMin) + speedMin;
    final double vx = widget.isRedWinning ? -baseVx : baseVx;
    final double vy = (_random.nextDouble() - 0.5) * jumpPower;

    return _PKFeverFragment(
      x: startX,
      y: startY,
      vx: vx,
      vy: vy,
      size: _random.nextDouble() * (sizeMax - sizeMin) + sizeMin,
      life: 1.0,
      decayRate: _random.nextDouble() * 0.6 + lifeTime,
      isOrange: _random.nextBool(),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _PKDividerPainter(
          particles: _particles,
          feverFragments: _feverFragments,
          isZeroScore: widget.isZeroScore,
          feverValue: widget.feverValue,
          isRedWinning: widget.isRedWinning,
          barHeight: widget.barHeight,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _PKFeverFragment {
  double x, y, vx, vy, size, life, decayRate;
  bool isOrange;
  _PKFeverFragment({required this.x, required this.y, required this.vx, required this.vy, required this.size, required this.life, required this.decayRate, required this.isOrange});
}

class _PKParticle {
  double x, y, vx, vy, size, life, decayRate;
  Color color;
  _PKParticle({required this.x, required this.y, required this.vx, required this.vy, required this.size, required this.life, required this.decayRate, required this.color});
}

class _PKDividerPainter extends CustomPainter {
  final List<_PKParticle> particles;
  final List<_PKFeverFragment> feverFragments;
  final bool isZeroScore;
  final double feverValue;
  final bool isRedWinning;
  final double barHeight;

  _PKDividerPainter({
    required this.particles,
    required this.feverFragments,
    required this.isZeroScore,
    required this.feverValue,
    required this.isRedWinning,
    required this.barHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTRB(-500, 0, size.width + 500, size.height));

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    if (feverValue == 0) {
      if (isZeroScore) {
        final glowPaint = Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..strokeWidth = 3.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
        final corePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5;
        const double barHeightHalf = 8.5;
        canvas.drawLine(Offset(centerX, centerY - barHeightHalf), Offset(centerX, centerY + barHeightHalf), glowPaint);
        canvas.drawLine(Offset(centerX, centerY - barHeightHalf), Offset(centerX, centerY + barHeightHalf), corePaint);
      }
    } else {
      final double indent = kArrowSharpness * feverValue;
      final double halfH = barHeight / 2;
      final double trailLen = 70.0 * feverValue;

      final double midX = isRedWinning ? centerX : centerX - indent;
      final double baseX = isRedWinning ? centerX - indent : centerX;
      final double backX = isRedWinning ? baseX - trailLen : baseX + trailLen;

      final Color factionColor = isRedWinning ? const Color(0xFFFF5252) : const Color(0xFF2962FF);
      final Color arrowYellow = const Color(0xFFFFD54F);

      Path beamPath = Path();
      beamPath.moveTo(backX, centerY - halfH);
      beamPath.lineTo(baseX, centerY - halfH);
      beamPath.lineTo(midX, centerY);
      beamPath.lineTo(baseX, centerY + halfH);
      beamPath.lineTo(backX, centerY + halfH);
      beamPath.close();

      final double totalLen = trailLen + indent;
      final double yellowStop = totalLen > 0 ? (indent / totalLen) : 0.2;

      ui.Shader beamShader = ui.Gradient.linear(
        Offset(midX, centerY),
        Offset(backX, centerY),
        [
          Colors.white,
          arrowYellow,
          factionColor.withOpacity(0.8 * feverValue),
          factionColor.withOpacity(0.0),
        ],
        [0.0, yellowStop, yellowStop + (1.0 - yellowStop) * 0.4, 1.0],
      );
      canvas.drawPath(beamPath, Paint()..shader = beamShader..style = PaintingStyle.fill);

      canvas.save();
      canvas.clipPath(beamPath);

      for (var f in feverFragments) {
        double fade = f.life.clamp(0.0, 1.0);
        final double opacity = (fade * feverValue).clamp(0.0, 1.0);
        final double currentRadius = f.size * (0.3 + 0.7 * fade);
        final Color spotColor = f.isOrange ? const Color(0xFFFF8F00) : const Color(0xFFFFD54F);

        final haloPaint = Paint()
          ..color = spotColor.withOpacity(opacity * 0.95)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

        canvas.drawCircle(Offset(centerX + f.x, centerY + f.y), currentRadius, haloPaint);
      }
      canvas.restore();
    }

    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.life.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0.5);
      canvas.drawCircle(Offset(centerX + p.x, centerY + p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PKDividerPainter oldDelegate) => true;
}

class PKTimer extends StatelessWidget {
  final int secondsLeft;
  final PKStatus status;
  final int myScore;
  final int opponentScore;

  const PKTimer({super.key, required this.secondsLeft, required this.status, required this.myScore, required this.opponentScore});

  String _formatTime(int totalSeconds) {
    if (totalSeconds < 0) return "00:00";
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isRedBg = (secondsLeft <= 10 && status == PKStatus.playing) || status == PKStatus.punishment;

    return CustomPaint(
      painter: _TrapezoidPainter(color: isRedBg ? const Color(0xFFFF1744).withOpacity(0.3) : Colors.grey.withOpacity(0.85)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (status != PKStatus.punishment && status != PKStatus.coHost) ...[
              const Text("P",
                  style: TextStyle(color: Color(0xFFFF2E56), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 12, height: 1.0)),
              const SizedBox(width: 0),
              const Text("K",
                  style: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 12, height: 1.0)),
              const SizedBox(width: 6),
            ],
            Text(
              status == PKStatus.punishment
                  ? "惩罚时间 ${_formatTime(secondsLeft)}"
                  : status == PKStatus.coHost
                  ? "连线中 ${_formatTime(secondsLeft)}"
                  : _formatTime(secondsLeft),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrapezoidPainter extends CustomPainter {
  final Color color;

  _TrapezoidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    const double inset = 6.0;
    const double r = 5.0;
    final double safeR = r.clamp(0.0, size.height / 2);
    final double dx = inset * (safeR / size.height);
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - inset + dx, safeR);
    path.quadraticBezierTo(size.width - inset, 0, size.width - inset - safeR, 0);
    path.lineTo(inset + safeR, 0);
    path.quadraticBezierTo(inset, 0, inset - dx, safeR);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrapezoidPainter oldDelegate) => color != oldDelegate.color;
}