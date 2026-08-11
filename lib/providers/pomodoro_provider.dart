import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pomodoro_state.dart';
import '../services/notification_service.dart';

class PomodoroProvider with ChangeNotifier {
  PomodoroState _state = PomodoroState();
  Timer? _timer;

  PomodoroState get state => _state;

  void setTheme(PomodoroTheme theme) {
    _state = _state.copyWith(selectedTheme: theme);
    notifyListeners();
  }

  void setFocusTask(String title) {
    _state = _state.copyWith(focusTaskTitle: title);
    notifyListeners();
  }

  void clearFocusTask() {
    _state = _state.copyWith(focusTaskTitle: '');
    notifyListeners();
  }

  void toggleIntervalBreaks(bool value) {
    _state = _state.copyWith(intervalBreaksEnabled: value);
    notifyListeners();
  }

  void setIntervalBreakDuration(int minutes) {
    _state = _state.copyWith(intervalBreakDurationMinutes: minutes);
    notifyListeners();
  }

  List<int> getBreakTriggers() {
    if (!_state.intervalBreaksEnabled) return [];
    if (_state.selectedMode != PomodoroMode.focus && _state.selectedMode != PomodoroMode.longBreak) return [];

    int totalMinutes = _state.focusMinutes;
    if (totalMinutes <= 35) return [];

    List<int> triggers = [];
    if (totalMinutes >= 45 && totalMinutes <= 60) {
      // 1 break at the middle
      triggers.add((totalMinutes * 60) ~/ 2);
    } else if (totalMinutes == 90) {
      // 2 breaks (at 60m and 30m remaining)
      triggers.add(60 * 60);
      triggers.add(30 * 60);
    } else if (totalMinutes >= 120) {
      // 3 breaks (at 90m, 60m, 30m remaining)
      triggers.add(90 * 60);
      triggers.add(60 * 60);
      triggers.add(30 * 60);
    }
    return triggers;
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

    int currentRemaining = _state.remainingSeconds;
    if (currentRemaining <= 0 || _state.status == PomodoroStatus.finished) {
      int minutes = _state.customFocusMinutes;
      if (_state.selectedMode == PomodoroMode.shortBreak) {
        minutes = _state.customShortBreakMinutes;
      } else if (_state.selectedMode == PomodoroMode.longBreak) {
        minutes = _state.customLongBreakMinutes;
      }
      currentRemaining = minutes * 60;
    }

    _state = _state.copyWith(
      status: PomodoroStatus.running,
      remainingSeconds: currentRemaining,
    );
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.isCurrentlyInIntervalBreak) {
        if (_state.intervalBreakRemainingSeconds > 0) {
          _state = _state.copyWith(intervalBreakRemainingSeconds: _state.intervalBreakRemainingSeconds - 1);
          notifyListeners();
        } else {
          // Descanso terminado, continuar
          _playAlarm('¡Descanso terminado!', 'Es hora de volver a concentrarse.');
          _state = _state.copyWith(
            isCurrentlyInIntervalBreak: false,
            remainingSeconds: _state.remainingSeconds > 0 ? _state.remainingSeconds - 1 : 0,
          );
          notifyListeners();
        }
      } else {
        if (_state.remainingSeconds > 0) {
          int nextSecond = _state.remainingSeconds - 1;
          List<int> triggers = getBreakTriggers();
          
          if (triggers.contains(nextSecond)) {
            _playAlarm('¡Pausa Activa!', 'Tómate un descanso, te lo has ganado.');
            _state = _state.copyWith(
              remainingSeconds: nextSecond,
              isCurrentlyInIntervalBreak: true,
              intervalBreakRemainingSeconds: _state.intervalBreakDurationMinutes * 60,
            );
          } else {
            _state = _state.copyWith(remainingSeconds: nextSecond);
          }
          notifyListeners();
        } else {
          _timer?.cancel();
          _playAlarm('Sesión completada', '¡Gran trabajo completando este Pomodoro!');
          _state = _state.copyWith(
            status: PomodoroStatus.finished,
            completedPomodoros: _state.completedPomodoros + 1,
            isCurrentlyInIntervalBreak: false,
          );
          notifyListeners();
        }
      }
    });
  }

  void _playAlarm(String title, String body) async {
    NotificationService.showPomodoroAlert(title, body);
    SystemSound.play(SystemSoundType.alert);
    for (int i = 0; i < 4; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 250));
    }
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
      isCurrentlyInIntervalBreak: false,
      intervalBreakRemainingSeconds: 0,
    );
    notifyListeners();
  }

  String get formattedTime {
    int currentSeconds = _state.isCurrentlyInIntervalBreak 
        ? _state.intervalBreakRemainingSeconds 
        : _state.remainingSeconds;
    int minutes = currentSeconds ~/ 60;
    int seconds = currentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
