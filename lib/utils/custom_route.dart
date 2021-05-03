import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    @required WidgetBuilder builder,

    // Sobrecarga de construtor
    RouteSettings settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  // Sobrecarga de método
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Não faz nada, só retorna a página
    if (settings.name == '/') {
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
