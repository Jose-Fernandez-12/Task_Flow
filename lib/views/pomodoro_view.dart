import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../models/pomodoro_state.dart';
import '../theme/app_theme.dart';
import '../widgets/pomodoro_animation_widget.dart';
import '../widgets/pomodoro_settings_modal.dart';

class PomodoroView extends StatelessWidget {
  const PomodoroView({Key? key}) : super(key: key);

  String _getThemeName(PomodoroTheme theme) {
    switch (theme) {
      case PomodoroTheme.tree:
        return 'Bosque';
      case PomodoroTheme.fire:
        return 'Fogata';
      case PomodoroTheme.space:
        return 'Espacio';
      case PomodoroTheme.potion:
        return 'Poción';
    }
  }

  IconData _getThemeIcon(PomodoroTheme theme) {
    switch (theme) {
      case PomodoroTheme.tree:
        return Icons.park;
      case PomodoroTheme.fire:
        return Icons.whatshot;
      case PomodoroTheme.space:
        return Icons.rocket_launch;
      case PomodoroTheme.potion:
        return Icons.science;
    }
  }

  void _showSettings(BuildContext context, PomodoroProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PomodoroSettingsModal(
        state: provider.state,
        onSave: (focus, shortB, longB) {
          provider.updateCustomDurations(
            focus: focus,
            shortBreak: shortB,
            longBreak: longB,
          );
        },
      ),
    );
  }

  void _handleModeChange(BuildContext context, PomodoroProvider provider, PomodoroMode targetMode) {
    final state = provider.state;
    if (state.selectedMode == targetMode) return;

    if (state.status == PomodoroStatus.running || state.status == PomodoroStatus.paused) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Cambiar de modo?'),
          content: const Text('Se reiniciará la sesión actual y perderás el progreso transcurrido.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                provider.setMode(targetMode);
              },
              child: const Text('Reiniciar'),
            ),
          ],
        ),
      );
    } else {
      provider.setMode(targetMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: Consumer<PomodoroProvider>(
        builder: (context, provider, child) {
          final state = provider.state;
          final progress = state.progress;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // Mode Selector Row + Settings Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: colors.borderSoft),
                            ),
                            child: Row(
                              children: [
                                _buildModeTab(
                                  context,
                                  provider,
                                  PomodoroMode.focus,
                                  'Enfoque (${state.customFocusMinutes}m)',
                                  colors,
                                ),
                                _buildModeTab(
                                  context,
                                  provider,
                                  PomodoroMode.shortBreak,
                                  'E. Corto (${state.customShortBreakMinutes}m)',
                                  colors,
                                ),
                                _buildModeTab(
                                  context,
                                  provider,
                                  PomodoroMode.longBreak,
                                  'E. Largo (${state.customLongBreakMinutes}m)',
                                  colors,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.settings_outlined, color: colors.fg2),
                          onPressed: () => _showSettings(context, provider),
                          tooltip: 'Personalizar Tiempos',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Dynamic Rich Animation Canvas Artwork
                  PomodoroAnimationWidget(
                    theme: state.selectedTheme,
                    progress: progress,
                    isRunning: state.status == PomodoroStatus.running,
                  ),

                  const SizedBox(height: 20),

                  // Redesigned Theme Selector (Sleek Segmented Pill Bar)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.borderSoft),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: PomodoroTheme.values.map((theme) {
                        final isSelected = state.selectedTheme == theme;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => provider.setTheme(theme),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? colors.surfaceWarm : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: colors.accent.withOpacity(0.5)) : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getThemeIcon(theme),
                                    size: 20,
                                    color: isSelected ? colors.accent : colors.muted,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getThemeName(theme),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? colors.fg : colors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Big Digital Timer Text
                  Text(
                    provider.formattedTime,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      color: colors.fg,
                      fontFamily: 'monospace',
                    ),
                  ),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: colors.surfaceWarm,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Round / Cycle Counter Indicator
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pomodoros: ${state.completedPomodoros}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.muted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(4, (index) {
                          final currentInCycle = state.completedPomodoros % 4;
                          final isFilled = index < currentInCycle;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(
                              isFilled ? Icons.lens : Icons.panorama_fish_eye,
                              size: 10,
                              color: isFilled ? colors.accent : colors.muted,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.status != PomodoroStatus.idle && state.status != PomodoroStatus.finished)
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Material(
                            color: colors.surfaceWarm,
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.stop),
                              iconSize: 32,
                              color: colors.danger,
                              onPressed: provider.stopTimer,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          if (state.status == PomodoroStatus.running) {
                            provider.pauseTimer();
                          } else {
                            provider.startTimer();
                          }
                        },
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.accent,
                            boxShadow: [
                              BoxShadow(
                                color: colors.accent.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Icon(
                            state.status == PomodoroStatus.running
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 42,
                            color: colors.accentOn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeTab(
    BuildContext context,
    PomodoroProvider provider,
    PomodoroMode mode,
    String label,
    AppColors colors,
  ) {
    final isSelected = provider.state.selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleModeChange(context, provider, mode),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colors.accentOn : colors.muted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
