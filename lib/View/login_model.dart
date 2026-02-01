class LoginModel {
  String? _token;
  String? _email;

  String? get token => _token;
  String? get email => _email;

  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty) {
      _email = email;
      _token = 'fake_token_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      throw Exception('Credenciales inválidas');
    }
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
  }

  void clear() {
    _token = null;
    _email = null;
  }
}
