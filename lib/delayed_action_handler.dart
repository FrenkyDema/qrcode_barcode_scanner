import 'dart:async';

class DelayedActionHandler {
  final Duration delay;
  Timer? _timer;
  Function()? _action;

  DelayedActionHandler(this.delay);

  void executeDelayed(Function() action) {
    cancelDelayed();
    _action = action;
    _timer = Timer(delay, _performAction);
  }

  void cancelDelayed() {
    _timer?.cancel();
    _timer = null;
    _action = null;
  }

  void _performAction() {
    _action?.call();
    _action = null;
  }
}
