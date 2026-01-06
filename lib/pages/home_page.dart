import 'package:flutter/material.dart';
import 'webview_page_fullscreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController =
      TextEditingController(); // 控制器用于获取输入的 URL

  @override
  void dispose() {
    _urlController.dispose(); // 页面销毁时释放控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0), // 添加页面边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 子元素从左对齐
          mainAxisAlignment: MainAxisAlignment.start, // 从顶部开始排列
          children: [
            const SizedBox(height: 20), // 添加顶部间距
            TextField(
              controller: _urlController, // 绑定控制器
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // 默认状态下的底部边框颜色
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue), // 输入框聚焦时的底部边框颜色
                ),
                labelText: 'Enter URL',
                // 输入框提示文本
                hintText: 'e.g. https://example.com',
                // 提示内容
                hintStyle: TextStyle(color: Colors.grey), // 提示文字样式
              ),
              keyboardType: TextInputType.url, // 设置键盘类型为 URL
            ),
            const SizedBox(height: 20), // 间隔
            ElevatedButton(
              onPressed: () {
                final url = _urlController.text; // 获取用户输入的 URL
                if (url.isNotEmpty &&
                    Uri.tryParse(url)?.hasAbsolutePath == true) {
                  // 验证 URL 的合法性
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPageFullScreen(url: url),
                    ),
                  );
                } else {
                  // 显示错误提示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid URL')),
                  );
                }
              },
              child: const Text('Load URL'),
            ),
            const SizedBox(height: 20), // 间隔
            ElevatedButton(
              onPressed: () {
                // 预定义的本地 URL
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WebViewPageFullScreen(url: 'http://192.168.2.75:5173'),
                  ),
                );
              },
              child: const Text('Local'),
            ),
            const SizedBox(height: 20), // 间隔
            ElevatedButton(
              onPressed: () {
                // 预定义的测试环境 URL
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        // WebViewPageFullScreen(url: 'http://124.222.191.23:281'),
                        WebViewPageFullScreen(url: 'https://www.efzxt.com/mtecp_pc/index.html#/quit/login'),
                  ),
                );
              },
              child: const Text('Fzxt'),
            ),
            const SizedBox(height: 20), // 间隔
            ElevatedButton(
              onPressed: () {
                // 预定义的生产环境 URL
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WebViewPageFullScreen(url: 'http://10.72.206.2:281'),
                  ),
                );
              },
              child: const Text('Production Environment'),
            ),
          ],
        ),
      ),
    );
  }
}
