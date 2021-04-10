import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/auth_exception.dart';

class Auth with ChangeNotifier {
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
