import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(debugShowCheckedModeBanner: false, home: AuthScreen());
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegister = false;

  Future<void> _submit() async {
    final uri = Uri.parse(
      'https://your-vercel-backend.vercel.app/api/${_isRegister ? 'register' : 'login'}',
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'password': _passwordController.text,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatAssistant(userName: _nameController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Đăng nhập/Đăng ký thất bại'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isRegister ? 'Đăng ký' : 'Đăng nhập')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Tên người dùng'),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Mật khẩu'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: Text(_isRegister ? 'Đăng ký' : 'Đăng nhập'),
          ),
          TextButton(
            onPressed: () => setState(() => _isRegister = !_isRegister),
            child: Text(
              _isRegister
                  ? 'Đã có tài khoản? Đăng nhập'
                  : 'Chưa có tài khoản? Đăng ký',
            ),
          ),
        ],
      ),
    ),
  );
}

class ChatAssistant extends StatefulWidget {
  final String userName;
  ChatAssistant({required this.userName});

  @override
  _ChatAssistantState createState() => _ChatAssistantState();
}

class _ChatAssistantState extends State<ChatAssistant> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "";
  List<String> messages = [];

  Future<void> _sendMessage(String msg) async {
    final uri = Uri.parse('https://your-vercel-backend.vercel.app/api/chat');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': msg, 'user': widget.userName}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        messages.add("🧑 ${widget.userName}: $msg");
        messages.add("🤖 Trợ lý: ${result['reply']}");
      });
      await _flutterTts.speak(result['reply']);
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() => _text = val.recognizedWords);
            if (val.hasConfidenceRating && val.confidence > 0) {
              _sendMessage(_text);
              _speech.stop();
              setState(() => _isListening = false);
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("Xin chào, ${widget.userName}")),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(8),
            children: messages.map((m) => Text(m)).toList(),
          ),
        ),
        Row(
          children: [
            IconButton(icon: Icon(Icons.mic), onPressed: _startListening),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: "Nhập tin nhắn..."),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                _sendMessage(_controller.text);
                _controller.clear();
              },
            ),
          ],
        ),
      ],
    ),
  );
}
