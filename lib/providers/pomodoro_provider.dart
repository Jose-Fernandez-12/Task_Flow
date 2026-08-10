import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pomodoro_state.dart';

class PomodoroProvider with ChangeNotifier {
  PomodoroState _state = PomodoroState();
  Timer? _timer;

  PomodoroState get state => _state;

  void setTheme(PomodoroTheme theme) {
    _state = _state.copyWith(selectedTheme: theme);
    notifyListeners();
  }

  void updateCustomDurations({int? focus, int? shortBreak, int? longBreak}) {
    final newFocus = focus ?? _state.customFocusMinutes;
    final newShort = shortBreak ?? _state.customShortBreakMinutes;
    final newLong = longBreak ?? _state.customLongBreakMinutes;

    int currentMins = newFocus;
    if (_state.selectedMode == PomodoroMode.shortBreak) {
      currentMins = newShort;
    } else if (_state.selectedMode == PomodoroMode.longBreak) {
      currentMins = newLong;
    }

    _timer?.cancel();
    _state = _state.copyWith(
      customFocusMinutes: newFocus,
      customShortBreakMinutes: newShort,
      customLongBreakMinutes: newLong,
      focusMinutes: currentMins,
      remainingSeconds: currentMins * 60,
      status: PomodoroStatus.idle,
    );
    notifyListeners();
  }

  void setMode(PomodoroMode mode) {
    if (_state.status == PomodoroStatus.running) {
      _timer?.cancel();
    }
    int minutes = _state.customFocusMinutes;
    if (mode == PomodoroMode.shortBreak) {
      minutes = _state.customShortBreakMinutes;
    } else if (mode == PomodoroMode.longBreak) {
      minutes = _state.customLongBreakMinutes;
    }

    _state = _state.copyWith(
      selectedMode: mode,
      focusMinutes: minutes,
      remainingSeconds: minutes * 60,
      status: PomodoroStatus.idle,
    );
    notifyListeners();
  }

  void startTimer() {
    if (_state.status == PomodoroStatus.running) return;

    _state = _state.copyWith(status: PomodoroStatus.running);
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.remainingSeconds > 0) {
        _state = _state.copyWith(remainingSeconds: _state.remainingSeconds - 1);
        notifyListeners();
      } else {
        _timer?.cancel();
        int nextCompleted = _state.completedPomodoros;
        if (_state.selectedMode == PomodoroMode.focus) {
          nextCompleted++;
        }
        _state = _state.copyWith(
          status: PomodoroStatus.finished,
          completedPomodoros: nextCompleted,
        );
        notifyListeners();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _state = _state.copyWith(status: PomodoroStatus.paused);
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    int minutes = _state.customFocusMinutes;
    if (_state.selectedMode == PomodoroMode.shortBreak) {
      minutes = _state.customShortBreakMinutes;
    } else if (_state.selectedMode == PomodoroMode.longBreak) {
      minutes = _state.customLongBreakMinutes;
    }

    _state = _state.copyWith(
      focusMinutes: minutes,
      remainingSeconds: minutes * 60,
      status: PomodoroStatus.idle,
    );
    notifyListeners();
  }

  String get formattedTime {
    int minutes = _state.remainingSeconds ~/ 60;
    int seconds = _state.remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
