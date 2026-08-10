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

  void setMode(PomodoroMode mode) {
    if (_state.status == PomodoroStatus.running) {
      _timer?.cancel();
    }
    int minutes = 25;
    if (mode == PomodoroMode.shortBreak) {
      minutes = 5;
    } else if (mode == PomodoroMode.longBreak) {
      minutes = 15;
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
        stopTimer();
        _state = _state.copyWith(status: PomodoroStatus.finished);
        notifyListeners();
        // Here we could trigger a notification/sound
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
    int minutes = 25;
    if (_state.selectedMode == PomodoroMode.shortBreak) {
      minutes = 5;
    } else if (_state.selectedMode == PomodoroMode.longBreak) {
      minutes = 15;
    }

    _state = PomodoroState(
      focusMinutes: minutes,
      remainingSeconds: minutes * 60,
      status: PomodoroStatus.idle,
      selectedTheme: _state.selectedTheme,
      selectedMode: _state.selectedMode,
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
