import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // 初始化 WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // 设置 JavaScript 模式
      ..loadRequest(Uri.parse('https://www.bilibili.com')); // 加载网页
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView Page'),
      ),
      body: WebViewWidget(
        controller: _controller, // 使用 WebViewController 控制 WebView
      ),
    );
  }
}