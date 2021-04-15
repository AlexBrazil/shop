import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/auth_exception.dart';

class Auth with ChangeNotifier {
  DateTime _expiryDate;
  String _token;

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

    print(responseBody);

    // response.body retorna um json que é convertido em um MAP <String, Object>
    // sendo que a chave é 'error' e o valor é um outro MAP com o código do erro
    // e a mensagem
    if (responseBody['error'] != null) {
      throw AuthException(responseBody['error']['message']);
    } else {
      // Na resposta Firebase enviará um MAP com o idToken e o expriresIn (tempo em segundos
      // para a validade do token)
      _token = responseBody["idToken"];
      // Adicionado a data atual o tempo de expiração, obtendo assim a data de expiração
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseBody["expiresIn"]),
        ),
      );
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
}
