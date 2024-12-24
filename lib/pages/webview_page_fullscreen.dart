import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:image_picker/image_picker.dart';

class WebViewPageFullScreen extends StatefulWidget {
  final String url; // 接收 URL 参数
  const WebViewPageFullScreen({super.key, required this.url});

  @override
  _WebViewPageFullScreenState createState() => _WebViewPageFullScreenState();
}

class _WebViewPageFullScreenState extends State<WebViewPageFullScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // 隐藏状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
    // 配置文件选择器
    setupFilePicker();
  }

  void setupFilePicker() {
    if (Platform.isAndroid) {
      final controller = _controller.platform as AndroidWebViewController;
      controller.setOnShowFileSelector((FileSelectorParams params) async {
        final picker = ImagePicker();
        // 弹出选择来源对话框
        final ImageSource? source = await showDialog<ImageSource>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('选择图片来源'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  child: Text('拍照'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  child: Text('相册'),
                ),
              ],
            );
          },
        );
        // 如果用户未选择，返回空
        if (source == null) return [];

        // 选择文件或拍照
        final XFile? file = await picker.pickImage(source: source);
        if (file == null) return []; // 用户未选择文件或拍照取消

        print("Selected file path: ${file.path}");

        // 返回文件路径
        return [Uri.file(file.path).toString()];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}