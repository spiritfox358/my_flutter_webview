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
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要退出当前页面并返回首页吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // 不退出
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // 确定退出
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
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