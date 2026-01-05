import 'package:get/get.dart';

abstract class BaseViewModel extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  void setLoading(bool value) {
    _isLoading = value;
    update();
  }

  void setError(String? error) {
    _errorMessage = error;
    update();
  }

  void clearError() {
    _errorMessage = null;
    update();
  }
}
