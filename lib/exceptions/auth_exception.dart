// Ao implementar exception as classes abstratas devem ser implementadas
class AuthException implements Exception {
  static const Map<String, String> errors = {
    "EMAIL_EXISTS": " O endereço de e-mail já está sendo usado por outra conta",
    "OPERATION_NOT_ALLOWED": " Login de senha desabilitado para este projeto",
    "TOO_MANY_ATTEMPTS_TRY_LATER":
        "Bloqueamos todas as solicitações deste dispositivo devido a atividade incomum. Tente mais tarde",
    "EMAIL_NOT_FOUND": "E-mail não cadastrado",
    "INVALID_PASSWORD": "Senha inválida para este e-mail",
    "USER_DISABLED": "A conta do usuário foi desabilitada por um administrador",
  };

  final String key;
  const AuthException(this.key);

  @override
  String toString() {
    if (errors.containsKey(key)) {
      return errors[key];
    } else {
      return "Ocorreu um erro desconhecido na autenticação";
    }
  }
}
