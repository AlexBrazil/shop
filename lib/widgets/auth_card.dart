/*
AJUDA NO FIREBASE
https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  // Para o formulário
  GlobalKey<FormState> _form = GlobalKey();

  final Map<String, String> _authData = {'email': '', 'password': ''};
  // Temos que ter acesso a valor digitado antes de submeter o formulário,
  // por isso necessitamos de 'TextEditingController'
  final _passwordController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;
  bool _isLoading = false;
  // Variável usada para mostrar ou ocultar os caracteres da senha
  bool _isObscure = true;

  // Criando animação
  AnimationController _controller;
  Animation<double> _opacityAnimation;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      /* vsync usa uma classe do tipo TickerProvider - este provider é chamado
      toda vez que houver uma atualização de quadro, em torno de 60 X por minuto
      Com ele fazemos a sincronia da animação
      Para tornar uma classe do tipo TickerProvider usamos um mixin:
      SingleTickerProviderStateMixin (single pq é uma única animação)
      */
      // Usamos this pro a classe tem mixin de SingleTickerProviderStateMixin
      vsync: this,
      duration: Duration(
        // Se em 1 seg tem 60 quados - (60 * 300) / 1000 = 18 quadros
        milliseconds: 300,
      ),
    );
    // Após inicializado o controle devemos inicializar a animação
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        // Velocidade constante do começo ao final - linear
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        // Velocidade constante do começo ao final - linear
        curve: Curves.linear,
      ),
    );

    /*
    Como usamos AnimatedContainer isso não é necessário
    _opacityAnimation.addListener(() {
      setState(() {
        // Não precisa fazer nada aqui, é só para adicionar um Listener que
        // escuta a mudança de _heigthAnimation e chama SetState
      });
    });
    */
  }

  //Como criamos manualmente a animação, é bom chamar dispose
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String msg) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Ocorreu um erro!"),
              content: Text(msg),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Fechar"),
                )
              ],
            ));
  }

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

    try {
      if (_authMode == AuthMode.Login) {
        await auth.login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await auth.signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      print("o erro foi: $error");
      // Um erro genérico
      _showErrorDialog("Ocorreu um erro inesperado");
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
      // Toca a animação para a frente
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      // Toca a animação para trás
      _controller.reverse();
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Check if a String is a valid email.
  /// Return true if it is valid.
  bool isEmailValid(String email) {
    // Null or empty string is invalid
    if (email == null || email.isEmpty) {
      return false;
    }

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(email)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        width: deviceSize.width * 0.75,
        height: _authMode == AuthMode.Login ? 290 : 371,
        //height: _heigthAnimation.value.height,
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
                  //if (value.isEmpty || !value.contains('@')) {
                  if (!isEmailValid(value)) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
                onSaved: (value) => _authData['email'] = value,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                obscureText: _isObscure,
                validator: (value) {
                  if (value.isEmpty || value.length < 5) {
                    return 'Informe uma senha com no mínimo 5 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _authData['password'] = value,
              ),
              AnimatedContainer(
                // Algo tem que alterar de valor para que AnimatedContainer detecte
                // e anime, vamos então usar constraints, zarando quando em Login e
                // colocando o tamanho total quando em Cadastro
                constraints: BoxConstraints(
                  //BoxConstraints muda a altura de forma abrupta, mas AnimatedContainer
                  //fara a animação desta mudança
                  minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                  maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                ),
                duration: Duration(milliseconds: 300),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextFormField(
                      //controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                      ),
                      obscureText: _isObscure,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'A senha de confirmação está diferente';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                ),
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
