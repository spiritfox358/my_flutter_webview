import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:image_picker/image_picker.dart';

class WebViewPageFullScreen extends StatefulWidget {
  final String url;
  const WebViewPageFullScreen({super.key, required this.url});

  @override
  State<WebViewPageFullScreen> createState() => _WebViewPageFullScreenState();
}

class _WebViewPageFullScreenState extends State<WebViewPageFullScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF155ABF),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    setupFilePicker();
  }

  // 弹出退出确认对话框
  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // 点击背景不关闭，强制用户选择
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 圆角
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 高度自适应内容
            children: [
              // 顶部图标
              const Icon(
                Icons.exit_to_app_rounded,
                color: Color(0xFF155ABF),
                size: 48,
              ),
              const SizedBox(height: 16),
              // 标题
              const Text(
                '确认退出',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // 内容描述
              const Text(
                '您确定要离开当前页面并返回首页吗？未保存的内容可能会丢失。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              // 按钮行
              Row(
                children: [
                  // 取消按钮
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF155ABF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(color: Color(0xFF155ABF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 确定按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF155ABF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        '确定退出',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ??
        false;
  }

  void setupFilePicker() {
    if (Platform.isAndroid) {
      final controller = _controller.platform as AndroidWebViewController;
      controller.setOnShowFileSelector((FileSelectorParams params) async {
        final picker = ImagePicker();
        final ImageSource? source = await showDialog<ImageSource>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('选择图片来源'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, ImageSource.camera), child: const Text('拍照')),
              TextButton(onPressed: () => Navigator.pop(context, ImageSource.gallery), child: const Text('相册')),
            ],
          ),
        );
        if (source == null) return [];
        final XFile? file = await picker.pickImage(source: source);
        if (file == null) return [];
        return [Uri.file(file.path).toString()];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 拦截所有返回操作
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1. 先检查 WebView 内部是否可以回退（比如从网页二级页面回到一级页面）
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          // 2. 如果已经在网页首页，点击返回键则弹出确认框
          if (context.mounted) {
            bool shouldPop = await _showExitConfirmation(context);
            if (shouldPop) {
              // 用户点击了“确定”，退出到 Flutter 的 HomePage
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF155ABF),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                color: Colors.white,
                child: WebViewWidget(controller: _controller),
              ),
              if (_isLoading)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF155ABF)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}