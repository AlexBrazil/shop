/*
AJUDA NO FIREBASE
https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  // Para o formulário
  GlobalKey<FormState> _form = GlobalKey();

  final Map<String, String> _authData = {'email': '', 'password': ''};
  // Temos que ter acesso a valor digitado antes de submeter o formulário,
  // por isso necessitamos de 'TextEditingController'
  final _passwordController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;
  bool _isLoading = false;

  Future<void> _submit() async {
    // Se o formulário estiver com algum erro nos dados preenchidos
    if (!_form.currentState.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // Ao chamar ...currentState.save() em cada TextFormField é acionado o método
    // onSave, o qual neste caso irá setar os dados dentro do MAP _authData
    _form.currentState.save();

    // Provider para autenticação
    Auth auth = Provider.of(context, listen: false);

    if (_authMode == AuthMode.Login) {
      await auth.login(_authData['email'], _authData['password']);
    } else {
      await auth.signup(_authData['email'], _authData['password']);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        width: deviceSize.width * 0.75,
        height: _authMode == AuthMode.Login ? 290 : 371,
        padding: EdgeInsets.all(16.0),
        child: Form(
          // Com essa key consigo controlar todas as validações deste Form
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
                onSaved: (value) => _authData['email'] = value,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty || value.length < 5) {
                    return 'Informe uma senha com no mínimo 5 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _authData['password'] = value,
              ),
              if (_authMode == AuthMode.Signup)
                TextFormField(
                  //controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Confirmar Senha'),
                  obscureText: true,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                          if (value != _passwordController.text) {
                            return 'A senha de confirmação está diferente';
                          }
                          return null;
                        }
                      : null,
                ),
              Spacer(),
              if (_isLoading)
                CircularProgressIndicator()
              else
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).primaryTextTheme.button.color,
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  onPressed: _submit,
                  child: Text(
                      _authMode == AuthMode.Login ? "ENTRAR" : "REGISTRAR"),
                ),
              FlatButton(
                onPressed: _switchAuthMode,
                child: Text(
                  "ALTERNAR PARA ${_authMode == AuthMode.Login ? "REGISTRAR" : "LOGIN"}",
                ),
                textColor: Theme.of(context).primaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
