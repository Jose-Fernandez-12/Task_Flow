enum PomodoroTheme {
  tree,
  fire,
  space,
  potion,
}

enum PomodoroStatus {
  idle,
  running,
  paused,
  finished,
}

enum PomodoroMode {
  focus,
  shortBreak,
  longBreak,
}

class PomodoroState {
  final int focusMinutes;
  final int remainingSeconds;
  final PomodoroStatus status;
  final PomodoroTheme selectedTheme;
  final PomodoroMode? _selectedMode;
  final int customFocusMinutes;
  final int customShortBreakMinutes;
  final int customLongBreakMinutes;
  final int completedPomodoros;

  PomodoroMode get selectedMode => _selectedMode ?? PomodoroMode.focus;

  PomodoroState({
    this.focusMinutes = 45,
    this.remainingSeconds = 45 * 60,
    this.status = PomodoroStatus.idle,
    this.selectedTheme = PomodoroTheme.tree,
    PomodoroMode? selectedMode,
    this.customFocusMinutes = 45,
    this.customShortBreakMinutes = 5,
    this.customLongBreakMinutes = 15,
    this.completedPomodoros = 0,
  }) : _selectedMode = selectedMode ?? PomodoroMode.focus;

  PomodoroState copyWith({
    int? focusMinutes,
    int? remainingSeconds,
    PomodoroStatus? status,
    PomodoroTheme? selectedTheme,
    PomodoroMode? selectedMode,
    int? customFocusMinutes,
    int? customShortBreakMinutes,
    int? customLongBreakMinutes,
    int? completedPomodoros,
  }) {
    return PomodoroState(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedMode: selectedMode ?? _selectedMode,
      customFocusMinutes: customFocusMinutes ?? this.customFocusMinutes,
      customShortBreakMinutes: customShortBreakMinutes ?? this.customShortBreakMinutes,
      customLongBreakMinutes: customLongBreakMinutes ?? this.customLongBreakMinutes,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
    );
  }

  double get progress {
    final totalSeconds = focusMinutes * 60;
    if (totalSeconds == 0) return 0;
    return (1 - (remainingSeconds / totalSeconds)).clamp(0.0, 1.0);
  }
}
