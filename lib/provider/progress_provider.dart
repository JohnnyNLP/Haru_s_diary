import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider with ChangeNotifier {
  ProgressProvider(this._isProgress);

  // 로딩 인디케이터 관리
  bool? _isProgress;
  bool? get isProgress => _isProgress;
  void setProgress(bool value) {
    print('ProgressProvider.setProgress: $value');
    _isProgress = value;
    notifyListeners();
  }

  // 프롬프트 템플릿 관리
  SharedPreferences? _prefs;
  SharedPreferences? get prefs => _prefs;
  void setUserPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final chatPrompt =
        await FirebaseFirestore.instance.collection('prompt').doc('chat').get();
    _prefs!.setString('chatTemplate', chatPrompt.data()!['prompt']);
    final imformalPrompt = await FirebaseFirestore.instance
        .collection('prompt')
        .doc('informal')
        .get();
    _prefs!.setString('imformalTemplate', imformalPrompt.data()!['prompt']);
  }

  // 가상 메시지 관리
  List<Map<String, dynamic>> chatDocs = [];
  void addFakeMessage(Map<String, dynamic> fakeChatMap) {
    chatDocs.insert(0, fakeChatMap);
    notifyListeners();
  }

  void removeFakeMessage() {
    chatDocs.clear();
    notifyListeners();
  }
}
