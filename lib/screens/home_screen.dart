import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../views/daily_view.dart';
import '../views/weekly_view.dart';
import '../views/monthly_view.dart';
import '../views/alerts_view.dart';
import '../widgets/add_task_modal.dart';
import 'dart:ui' show ImageFilter;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    DailyView(),
    WeeklyView(),
    MonthlyView(),
    AlertsView(),
  ];

  void _showAddTaskModal(BuildContext context, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskModal(
        onSave: (title, desc, date, priority, type, time) {
          provider.addOrUpdateTask(
            title: title,
            desc: desc,
            date: date,
            priority: priority,
            type: type,
            time: time,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final provider = Provider.of<TaskProvider>(context);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'TaskFlow ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: colors.fg,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Hoy',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: colors.muted,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('EEEE, d MMMM', 'es_ES').format(now).capitalize(),
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.muted,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          _buildHeaderAction(
                            icon: Icons.delete_sweep,
                            colors: colors,
                            onTap: () {
                              final count = provider.deleteCompleted();
                              if (count > 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$count eliminada(s)'), duration: const Duration(seconds: 2)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No hay completadas'), duration: Duration(seconds: 2)),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderAction(
                            icon: provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            colors: colors,
                            onTap: () {
                              provider.toggleTheme();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _views,
                  ),
                ),
              ],
            ),
            // Bottom Bar and FAB wrapper
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // FAB
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.accent.withOpacity(0.35),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: FloatingActionButton(
                          onPressed: () => _showAddTaskModal(context, provider),
                          backgroundColor: colors.accent,
                          elevation: 0,
                          child: Icon(Icons.add, color: colors.accentOn, size: 28),
                        ),
                      ),
                    ),
                  ),
                  // Tab Bar
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surface.withOpacity(0.85),
                          border: Border(top: BorderSide(color: colors.borderSoft)),
                        ),
                        padding: const EdgeInsets.only(top: 6, bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTabItem(0, 'Diario', Icons.today, colors, context),
                            _buildTabItem(1, 'Semanal', Icons.calendar_view_week, colors, context),
                            _buildTabItem(2, 'Mensual', Icons.calendar_month, colors, context),
                            _buildTabItem(
                              3,
                              'Alertas',
                              Icons.notifications,
                              colors,
                              context,
                              badgeCount: provider.recordatoriosPendientes.length,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction({required IconData icon, required AppColors colors, required VoidCallback onTap}) {
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9999),
        side: BorderSide(color: colors.borderSoft),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: colors.fg2, size: 22),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon, AppColors colors, BuildContext context, {int badgeCount = 0}) {
    final isActive = _currentIndex == index;
    final color = isActive ? colors.accent : colors.muted;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 26),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: BoxDecoration(
                        color: colors.danger,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Geist Mono'),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}


