import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color color;

  Badge({@required this.child, @required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    // Para colocar um elemento em cima do outro
    return Stack(
      alignment: Alignment.center,
      // São empilhados na ordem abaixo, onde os primeiros da lista
      // ficam embaixo
      children: [
        child, // elemento recebido no construtor
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color != null ? color : Theme.of(context).accentColor,
            ),
            constraints: BoxConstraints(minHeight: 16, minWidth: 16),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        )
      ],
    );
  }
}
