enum PomodoroTheme {
  tree,
  fire,
  space,
  potion,
  hourglass,
  ocean,
  coffee,
  zen,
  battery,
  crystal,
  vinyl,
  candle,
  mountain,
  balloon,
  ufo,
  windmill,
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

  // Interval Break Variables
  final bool intervalBreaksEnabled;
  final int intervalBreakDurationMinutes;
  final bool isCurrentlyInIntervalBreak;
  final int intervalBreakRemainingSeconds;

  // Current focus goal (task title) launched from a task context menu
  final String focusTaskTitle;

  PomodoroMode get selectedMode => _selectedMode ?? PomodoroMode.focus;

  PomodoroState({
    this.focusMinutes = 45,
    this.remainingSeconds = 45 * 60,
    this.status = PomodoroStatus.idle,
    this.selectedTheme = PomodoroTheme.tree,
    PomodoroMode? selectedMode,
    this.customFocusMinutes = 45,
    this.customShortBreakMinutes = 1,
    this.customLongBreakMinutes = 15,
    this.completedPomodoros = 0,
    this.intervalBreaksEnabled = true,
    this.intervalBreakDurationMinutes = 5,
    this.isCurrentlyInIntervalBreak = false,
    this.intervalBreakRemainingSeconds = 0,
    this.focusTaskTitle = '',
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
    bool? intervalBreaksEnabled,
    int? intervalBreakDurationMinutes,
    bool? isCurrentlyInIntervalBreak,
    int? intervalBreakRemainingSeconds,
    String? focusTaskTitle,
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
      intervalBreaksEnabled: intervalBreaksEnabled ?? this.intervalBreaksEnabled,
      intervalBreakDurationMinutes: intervalBreakDurationMinutes ?? this.intervalBreakDurationMinutes,
      isCurrentlyInIntervalBreak: isCurrentlyInIntervalBreak ?? this.isCurrentlyInIntervalBreak,
      intervalBreakRemainingSeconds: intervalBreakRemainingSeconds ?? this.intervalBreakRemainingSeconds,
      focusTaskTitle: focusTaskTitle ?? this.focusTaskTitle,
    );
  }

  double get progress {
    final totalSeconds = focusMinutes * 60;
    if (totalSeconds == 0) return 0;
    return (1 - (remainingSeconds / totalSeconds)).clamp(0.0, 1.0);
  }
}
