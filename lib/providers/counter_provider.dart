import 'package:flutter/material.dart';

class CounterState {
  int _value = 1;
  void inc() => _value++;
  void dec() => _value--;
  int get value => _value;

  bool diff(CounterState old) {
    return old == null || old._value != _value;
  }
}

class CounterProvider extends InheritedWidget {
  final CounterState state = CounterState();
  CounterProvider({Widget myChild}) : super(child: myChild);

  static CounterProvider of(BuildContext context) {
    // Poderia ser sem GENERICS - context.dependOnInheritedWidgetOfExactType()
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>();
  }

  @override
  // Deve notificar se acontecer uma mudança de estado?
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
