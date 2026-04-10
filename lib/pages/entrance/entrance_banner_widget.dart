import 'package:flutter/material.dart';

class EntranceBannerWidget extends StatefulWidget {
  final String avatarUrl;
  final String userName;
  final VoidCallback onComplete;

  const EntranceBannerWidget({
    super.key,
    required this.avatarUrl,
    required this.userName,
    required this.onComplete,
  });

  @override
  State<EntranceBannerWidget> createState() => _EntranceBannerWidgetState();
}

class _EntranceBannerWidgetState extends State<EntranceBannerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideInAnimation;
  late Animation<double> _slideOutAnimation;

  @override
  void initState() {
    super.initState();

    // 总时长 5 秒
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));

    // 🚀 动效升级：快出，慢停！
    // 使用 easeOutExpo：起步极快（像子弹射出），然后极其平滑、缓慢地停在目标位置。
    _slideInAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.2, curve: Curves.easeOutExpo)
      ),
    );

    // 滑出动效：从静止开始慢慢加速，然后极快地飞出屏幕 (easeInExpo)
    _slideOutAnimation = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.8, 1.0, curve: Curves.easeInExpo)
      ),
    );

    _controller.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double offsetX = 0;

        if (_controller.value <= 0.2) {
          offsetX = _slideInAnimation.value * screenWidth;
        } else if (_controller.value >= 0.8) {
          offsetX = _slideOutAnimation.value * screenWidth;
        } else {
          offsetX = 0;
        }

        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0), // 边缘留白
              child: _buildBannerUI(),
            ),
          ),
        );
      },
    );
  }

  // 🎨 UI 升级：图层穿插的立体胶囊设计
  Widget _buildBannerUI() {
    const double avatarSize = 48.0;   // 头像稍微放大，更有主次感
    const double capsuleHeight = 34.0; // 背景胶囊比头像稍细，形成错落美感

    return SizedBox(
      height: avatarSize,
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.none, // 允许溢出叠加
        children: [
          // 1. 底层：渐变背景胶囊
          Container(
            // 左侧 margin 留出头像一半的位置，让头像正好压在胶囊头上
            margin: const EdgeInsets.only(left: avatarSize / 2),
            // padding 左侧避开被头像挡住的区域
            padding: const EdgeInsets.only(left: (avatarSize / 2) + 8, right: 32.0),
            height: capsuleHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF4D81).withOpacity(0.95), // 亮粉色头部
                  const Color(0xFFFF4D81).withOpacity(0.0),  // 尾部渐变消失，融入背景
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(capsuleHeight / 2),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      // 给文字加一点非常轻微的阴影，防背景泛白时看不清
                      Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2)
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  "进入了直播间",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // 2. 顶层：圆形头像，压在胶囊之上
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.0), // 纯白描边，非常提气质
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4D81).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3), // 头像下方加一点粉色弥散阴影
                )
              ],
              image: DecorationImage(
                image: NetworkImage(widget.avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}