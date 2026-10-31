import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const OcrApp());
}

class OcrApp extends StatelessWidget {
  const OcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日本語 OCR 学習アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const OcrHomePage(),
    );
  }
}

class OcrHomePage extends StatefulWidget {
  const OcrHomePage({super.key});

  @override
  State<OcrHomePage> createState() => _OcrHomePageState();
}

class _OcrHomePageState extends State<OcrHomePage> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.japanese,
  );

  XFile? _image;
  Uint8List? _imageBytes;
  String _recognizedText = '';
  String? _errorMessage;
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      setState(() {
        _errorMessage = 'Google ML Kit OCRはAndroid/iOSで実行してください。';
      });
      return;
    }

    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (!mounted || image == null) return;
      final imageBytes = await image.readAsBytes();
      if (!mounted) return;

      setState(() {
        _image = image;
        _imageBytes = imageBytes;
        _recognizedText = '';
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = '画像を選択できませんでした: $error');
    }
  }

  Future<void> _recognizeText() async {
    final image = _image;
    if (image == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final result = await _textRecognizer.processImage(inputImage);
      if (!mounted) return;
      setState(() => _recognizedText = result.text);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = '文字を読み取れませんでした: $error');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日本語 OCR')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '画像から文字を読み取る',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('画像を選択して、Google ML Kitで日本語を認識します。'),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _isProcessing ? null : _pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('画像を選ぶ'),
            ),
            if (_image != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isProcessing ? null : _recognizeText,
                icon: const Icon(Icons.document_scanner_outlined),
                label: Text(_isProcessing ? '読み取り中...' : '日本語を読み取る'),
              ),
            ],
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_recognizedText.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('認識結果', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SelectableText(
                _recognizedText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ] else if (_image != null &&
                !_isProcessing &&
                _errorMessage == null) ...[
              const SizedBox(height: 16),
              const Text('読み取った文字はここに表示されます。'),
            ],
            if (kIsWeb) ...[
              const SizedBox(height: 24),
              const Text(
                'この画面はAndroid/iOS向けです。現在のChromeではGoogle ML Kitを実行できません。',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
