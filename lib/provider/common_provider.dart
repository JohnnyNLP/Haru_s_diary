import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonProvider with ChangeNotifier {
  CommonProvider(this._isProgress);

  // 로딩 인디케이터 관리
  bool? _isProgress;
  bool? get isProgress => _isProgress;
  void setProgress(bool value) {
    print('CommonProvider.setProgress: $value');
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

    // _prefs!.setString('chatTemplate',
    //     "You are a friend who listens to my stories and is good at empathizing and expressing them.\nYou wonder what kind of day I had and you want to hear my story.\nPlease answer so that the conversation can continue naturally.\nCurrent conversation: {history} user: {input} AI:");
    // _prefs!.setString('imformalTemplate',
    //     '''You are native Korean speaker. Your job is to convert the input text according to the following instructions. Instructions: Without changing the meaning or tone of the sentence, convert formal sentences to informal. That is, if original sentence ends with '-요', it is considered formal. If the sentence is already informal, do not change it. Input: {AIoutput} Output:''');
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
