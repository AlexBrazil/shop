import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/auth_exception.dart';

class Auth with ChangeNotifier {
  String _userId;
  DateTime _expiryDate;
  String _token;
  Timer _logoutTimer;

  // Método que retorna o token caso este seja válido e esteja dentro do prazo
  // de sua validade
  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    } else {
      return null;
    }
  }

  bool get isAuth {
    // Aqui estamos acssando o getter token e não a proriedade _token
    return token != null;
  }

  String get userId {
    return isAuth ? _userId : null;
  }

  // urlSegment é o que vai diferencial a URL para signInWithPassword (login) e signUp (cadastro)
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBoIKDpRdXKrHOGqDxTO02Njol572RuFoo';
    final response = await http.post(
      url,
      body: json.encode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );

    final responseBody = json.decode(response.body);

    // response.body retorna um json que é convertido em um MAP <String, Object>
    // sendo que a chave é 'error' e o valor é um outro MAP com o código do erro
    // e a mensagem
    if (responseBody['error'] != null) {
      throw AuthException(responseBody['error']['message']);
    } else {
      // Na resposta Firebase enviará um MAP com o idToken e o expriresIn (tempo em segundos
      // para a validade do token)
      _token = responseBody["idToken"];
      _userId = responseBody["localId"];
      // Adicionado a data atual o tempo de expiração, obtendo assim a data de expiração
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseBody["expiresIn"]),
        ),
      );
      // Este método cria um cronômetro de começa a contar o tempo para deslogar
      _autoLogout();
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_logoutTimer != null) {
      _logoutTimer.cancel();
      _logoutTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_logoutTimer != null) {
      _logoutTimer.cancel();
    }
    // calcula o tempo que falra para expirar o token
    final timeToLogout = _expiryDate.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);
  }
}
