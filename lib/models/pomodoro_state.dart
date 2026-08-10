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

  PomodoroMode get selectedMode => _selectedMode ?? PomodoroMode.focus;

  PomodoroState({
    this.focusMinutes = 25,
    this.remainingSeconds = 25 * 60,
    this.status = PomodoroStatus.idle,
    this.selectedTheme = PomodoroTheme.tree,
    PomodoroMode? selectedMode,
  }) : _selectedMode = selectedMode ?? PomodoroMode.focus;

  PomodoroState copyWith({
    int? focusMinutes,
    int? remainingSeconds,
    PomodoroStatus? status,
    PomodoroTheme? selectedTheme,
    PomodoroMode? selectedMode,
  }) {
    return PomodoroState(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedMode: selectedMode ?? _selectedMode,
    );
  }

  double get progress {
    final totalSeconds = focusMinutes * 60;
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }
}
