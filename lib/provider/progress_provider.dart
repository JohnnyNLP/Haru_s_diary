import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider with ChangeNotifier {
  bool? _isProgress;
  bool? get isProgress => _isProgress;
  SharedPreferences? _prefs;
  SharedPreferences? get prefs => _prefs;

  ProgressProvider(this._isProgress);

  void setProgress(bool value) {
    print('ProgressProvider.setProgress: $value');
    _isProgress = value;
    notifyListeners();
  }

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
}
