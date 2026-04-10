import 'package:flutter/material.dart';

import 'common_widget/natural_sunlight.dart';
import 'common_widget/sunlight_overlay.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NaturalSunlight(
      // 套在最外层
      child: Scaffold(
        backgroundColor: Colors.black, // 假设深色背景，光照效果更明显
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              // 你的背景图
              // image: NetworkImage("https://fzxt-resources.oss-cn-beijing.aliyuncs.com/assets/live/bg/bg_4.png"),
              image: NetworkImage("https://fzxt-resources.oss-cn-beijing.aliyuncs.com/assets/live/bg/bg_3.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: Text("页面内容", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}