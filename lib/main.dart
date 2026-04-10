import 'package:flutter/material.dart';
import 'package:my_flutter_webview/pages/entrance/effect_preview_page.dart';
import 'package:my_flutter_webview/pages/pk_result.dart';
import 'package:my_flutter_webview/pages/health_bar/test_pk_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Sandbox',
      debugShowCheckedModeBanner: false,
      // 直播相关的 UI 通常在纯黑背景下效果最好，所以这里默认全局使用暗色主题
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.blue,
      ),
      home: const SandboxHomePage(),
    );
  }
}

class SandboxHomePage extends StatelessWidget {
  const SandboxHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI 调试沙盒'),
        backgroundColor: Colors.grey[900],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNavButton(
            context,
            title: '1. 测试 PK 九宫格样式 (DynamicPKBattleView)',
            targetPage: const PkResultPage(),
          ),
          const SizedBox(height: 16),
          _buildNavButton(
            context,
            title: '2. 测试顶部红蓝血条 (PKScoreBar) - 待开发',
            targetPage: const TestPKScoreBarPage(),
          ),
          const SizedBox(height: 16),
          _buildNavButton(
            context,
            title: '3. 测试弹幕聊天区 - 待开发',
            targetPage: const Scaffold(body: Center(child: Text("待添加"))),
          ),
          const SizedBox(height: 16),
          _buildNavButton(
            context,
            title: '测试进场特效滑入滑出',
            targetPage: const EffectPreviewPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, {required String title, required Widget targetPage}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
      },
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}