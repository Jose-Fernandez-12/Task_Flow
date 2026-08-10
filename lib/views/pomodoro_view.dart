import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../models/pomodoro_state.dart';

class PomodoroView extends StatelessWidget {
  const PomodoroView({Key? key}) : super(key: key);

  IconData _getIconForThemeAndProgress(PomodoroTheme theme, double progress) {
    int stage = (progress * 4).floor().clamp(0, 3);
    
    switch (theme) {
      case PomodoroTheme.tree:
        return [Icons.spa_outlined, Icons.local_florist, Icons.park_outlined, Icons.park][stage];
      case PomodoroTheme.fire:
        return [Icons.local_fire_department_outlined, Icons.whatshot_outlined, Icons.local_fire_department, Icons.whatshot][stage];
      case PomodoroTheme.space:
        return [Icons.airplanemode_inactive, Icons.airplanemode_active, Icons.flight_takeoff, Icons.rocket_launch][stage];
      case PomodoroTheme.potion:
        return [Icons.science_outlined, Icons.water_drop_outlined, Icons.water_drop, Icons.science][stage];
    }
  }

  String _getThemeName(PomodoroTheme theme) {
    switch (theme) {
      case PomodoroTheme.tree: return 'Bosque';
      case PomodoroTheme.fire: return 'Fogata';
      case PomodoroTheme.space: return 'Espacio';
      case PomodoroTheme.potion: return 'Poción';
    }
  }

  Widget _buildModeTab(BuildContext context, PomodoroProvider provider, PomodoroMode mode, String label) {
    final isSelected = provider.state.selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimary 
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const SizedBox(height: 20),
                  // Mode Selector (Focus, Short Break, Long Break)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        _buildModeTab(context, provider, PomodoroMode.focus, 'Enfoque (25m)'),
                        _buildModeTab(context, provider, PomodoroMode.shortBreak, 'Corto (5m)'),
                        _buildModeTab(context, provider, PomodoroMode.longBreak, 'Largo (15m)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Theme Selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: PomodoroTheme.values.map((theme) {
                        final isSelected = state.selectedTheme == theme;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ChoiceChip(
                            label: Text(_getThemeName(theme)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                provider.setTheme(theme);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 35),
                  
                  // Animation Area (Placeholder using Icons)
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Icon(
                          _getIconForThemeAndProgress(state.selectedTheme, progress),
                          key: ValueKey('${state.selectedTheme}_${(progress * 4).floor().clamp(0, 3)}'),
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  
                  // Timer Text
                  Text(
                    provider.formattedTime,
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  
                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.status != PomodoroStatus.idle && state.status != PomodoroStatus.finished)
                        IconButton(
                          icon: const Icon(Icons.stop),
                          iconSize: 48,
                          onPressed: provider.stopTimer,
                          color: Colors.red,
                        ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: Icon(
                          state.status == PomodoroStatus.running 
                              ? Icons.pause_circle_filled 
                              : Icons.play_circle_fill
                        ),
                        iconSize: 80,
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          if (state.status == PomodoroStatus.running) {
                            provider.pauseTimer();
                          } else {
                            provider.startTimer();
                          }
                        },
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
}
