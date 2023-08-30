import 'package:flutter/foundation.dart';

class ProgressProvider with ChangeNotifier {
  bool _isProgress = false;

  bool get isProgress => _isProgress;

  void setProgress(bool value) {
    _isProgress = value;
    notifyListeners();
  }
}
