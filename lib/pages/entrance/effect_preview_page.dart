// ==========================================
// 🎬 2. 专门的进场特效预览页 (你新写的页面)
// ==========================================
import 'package:flutter/material.dart';
import 'entrance_banner_widget.dart';

class EffectPreviewPage extends StatefulWidget {
  const EffectPreviewPage({super.key});

  @override
  State<EffectPreviewPage> createState() => _EffectPreviewPageState();
}

class _EffectPreviewPageState extends State<EffectPreviewPage> {
  bool _showEntrance = false;

  @override
  void initState() {
    super.initState();
    // 💡 页面刚加载 0.5 秒后自动显示特效，体验更好
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showEntrance = true;
        });
      }
    });
  }

  void _onEntranceComplete() {
    // 特效播放完毕，将其从视图树中移除
    setState(() {
      _showEntrance = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('进场特效预览'),
        backgroundColor: Colors.grey[900],
      ),
      body: Stack(
        children: [
          // 背景层测试内容
          Center(
            child: Text(
              '模拟直播间公屏或视频背景',
              style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.3)),
            ),
          ),

          // 🚀 进场特效层
          if (_showEntrance)
            Positioned(
              top: 150, // 控制它在屏幕中偏上的位置
              left: 0,
              right: 0,
              child: EntranceBannerWidget(
                avatarUrl: 'https://fzxt-resources.oss-cn-beijing.aliyuncs.com/assets/avatar/1235_1771835203238.jpg',
                userName: '神秘大佬',
                onComplete: _onEntranceComplete,
              ),
            ),

          // 右下角提供一个重新播放按钮，方便调试
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () {
                if (!_showEntrance) {
                  setState(() {
                    _showEntrance = true;
                  });
                }
              },
              backgroundColor: const Color(0xFFFF4D81),
              icon: const Icon(Icons.replay, color: Colors.white),
              label: const Text('重新进场', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}