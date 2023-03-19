import 'dart:async';

class DelayedActionHandler<T> {
  final Duration delay;
  void Function(T) action;
  Timer timer;

  DelayedActionHandler(this.delay, this.action)
      : timer = Timer(Duration.zero, () {});

  void call(T value) {
    timer.cancel();
    timer = Timer(delay, () => action(value));
  }
}
