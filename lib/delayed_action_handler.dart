import 'dart:async';

/// A utility class that handles the execution of a delayed action.
class DelayedActionHandler {
  /// The delay before the action is executed.
  final Duration delay;

  Timer? _timer;
  Function()? _action;

  /// Creates a new instance of [DelayedActionHandler] with the given [delay].
  ///
  /// [delay] is the duration of the delay before the action is executed.
  DelayedActionHandler(this.delay);

  /// Executes the given [action] after the specified delay.
  ///
  /// If another action is already scheduled, it will be cancelled and replaced by this one.
  ///
  /// The [action] function takes no arguments and returns no value.
  void executeDelayed(Function() action) {
    cancelDelayed();
    _action = action;
    _timer = Timer(delay, _performAction);
  }

  /// Cancels any scheduled action.
  void cancelDelayed() {
    _timer?.cancel();
    _timer = null;
    _action = null;
  }

  /// Performs the scheduled action.
  ///
  /// If no action is scheduled, this method does nothing.
  void _performAction() {
    _action?.call();
    _action = null;
  }
}
