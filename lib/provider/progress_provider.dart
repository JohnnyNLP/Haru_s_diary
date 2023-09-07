import 'package:flutter/foundation.dart';

class ProgressProvider with ChangeNotifier {
  bool? _isProgress;
  bool? get isProgress => _isProgress;
  ProgressProvider(this._isProgress);

  void setProgress(bool value) {
    print('ProgressProvider.setProgress: $value');
    _isProgress = value;
    notifyListeners();
  }
}
