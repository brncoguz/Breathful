import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../utils/notification_service.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    return Scaffold(
      body: SafeArea(
        // Wrap the main Column with SingleChildScrollView
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Nicer scrolling effect
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Profile header
                Center(
                  child: Text(
                    'Your Progress',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Stats
                _buildStatCard(
                  context: context,
                  title: 'Total Sessions',
                  value: appState.totalSessions.toString(),
                  icon: Icons.check_circle_outline,
                ),
                
                const SizedBox(height: 16),
                
                _buildStatCard(
                  context: context,
                  title: 'Total Breathing Time',
                  value: '${appState.totalBreathingMinutes} minutes',
                  subtitle: appState.totalBreathingMinutes >= 60
                      ? '${(appState.totalBreathingMinutes / 60).toStringAsFixed(1)} hours'
                      : null,
                  icon: Icons.timer_outlined,
                ),
                
                const SizedBox(height: 16),
                
                _buildStatCard(
                  context: context,
                  title: 'Last Session',
                  value: appState.lastSessionDate != null
                      ? DateFormat('MMM d, yyyy').format(appState.lastSessionDate!)
                      : 'No sessions yet',
                  subtitle: appState.lastSessionDate != null
                      ? DateFormat('h:mm a').format(appState.lastSessionDate!)
                      : null,
                  icon: Icons.calendar_today_outlined,
                ),
                
                const SizedBox(height: 40),
                
                // Daily reminder settings
                Text(
                  'Daily Reminder',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                
                const SizedBox(height: 16),
                
                SwitchListTile(
                  title: const Text('Enable Daily Reminder'),
                  subtitle: Text(
                    appState.reminderEnabled
                        ? 'Reminder set for ${appState.reminderTime.format(context)}'
                        : 'No reminder set',
                  ),
                  value: appState.reminderEnabled,
                  activeColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) async {
                    if (value) {
                      // Request notification permissions
                      await NotificationService.requestNotificationPermissions(
                        flutterLocalNotificationsPlugin,
                      );
                      
                      // Show time picker
                      final timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: appState.reminderTime,
                      );
                      
                      if (timeOfDay != null) {
                        appState.setReminderEnabled(true);
                        appState.setReminderTime(timeOfDay);
                        
                        // Schedule notification
                        await NotificationService.scheduleDailyReminder(
                          flutterLocalNotificationsPlugin,
                          timeOfDay,
                        );
                      }
                    } else {
                      appState.setReminderEnabled(false);
                      
                      // Cancel notifications
                      await NotificationService.cancelAllNotifications(
                        flutterLocalNotificationsPlugin,
                      );
                    }
                  },
                ),
                
                if (appState.reminderEnabled) ...[
                  const SizedBox(height: 16),
                  
                  OutlinedButton.icon(
                    onPressed: () async {
                      final timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: appState.reminderTime,
                      );
                      
                      if (timeOfDay != null) {
                        appState.setReminderTime(timeOfDay);
                        
                        // Schedule notification
                        await NotificationService.scheduleDailyReminder(
                          flutterLocalNotificationsPlugin,
                          timeOfDay,
                        );
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: const Text('Change Reminder Time'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
                
                const SizedBox(height: 40),
                
                // Theme settings - replaced with new ThemeModeSelector
                ThemeModeSelector(),
                
                // Achievement message
                if (appState.totalSessions > 0)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        _getAchievementMessage(appState),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                
                // Add bottom padding for scrolling comfort
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getAchievementMessage(AppState appState) {
    if (appState.totalSessions >= 30) {
      return 'Amazing dedication! You\'ve completed ${appState.totalSessions} breathing sessions.';
    } else if (appState.totalSessions >= 10) {
      return 'Great progress! Keep up the regular breathing practice.';
    } else if (appState.totalSessions >= 5) {
      return 'You\'re building a healthy habit. Keep going!';
    } else {
      return 'You\'ve taken your first steps to mindful breathing. Well done!';
    }
  }
}

// Theme Mode Selector Component
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    
    // Get the current selected mode index
    int selectedIndex = appState.followSystemTheme 
        ? 2 
        : (appState.isDarkMode ? 1 : 0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: theme.textTheme.displaySmall,
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Selection Control
              Container(
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    _buildThemeOption(
                      context: context,
                      index: 0,
                      selectedIndex: selectedIndex,
                      label: 'Light',
                      icon: Icons.light_mode,
                      isFirstItem: true,
                      onTap: () {
                        appState.setFollowSystemTheme(false);
                        appState.setDarkMode(false);
                      },
                    ),
                    _buildThemeOption(
                      context: context,
                      index: 1,
                      selectedIndex: selectedIndex,
                      label: 'Dark',
                      icon: Icons.dark_mode,
                      onTap: () {
                        appState.setFollowSystemTheme(false);
                        appState.setDarkMode(true);
                      },
                    ),
                    _buildThemeOption(
                      context: context,
                      index: 2,
                      selectedIndex: selectedIndex,
                      label: 'Auto',
                      icon: Icons.brightness_auto,
                      isLastItem: true,
                      onTap: () {
                        appState.setFollowSystemTheme(true);
                      },
                    ),
                  ],
                ),
              ),
              
              // Current theme indicator
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Icon(
                      _getCurrentThemeIcon(appState),
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCurrentThemeText(appState),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  IconData _getCurrentThemeIcon(AppState appState) {
    if (appState.followSystemTheme) {
      return Icons.brightness_auto;
    }
    return appState.isDarkMode ? Icons.dark_mode : Icons.light_mode;
  }
  
  String _getCurrentThemeText(AppState appState) {
    if (appState.followSystemTheme) {
      return 'Currently using: System theme (${appState.isDarkMode ? 'Dark' : 'Light'})';
    }
    return 'Currently using: ${appState.isDarkMode ? 'Dark' : 'Light'} theme';
  }
  
  Widget _buildThemeOption({
    required BuildContext context,
    required int index,
    required int selectedIndex,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isFirstItem = false,
    bool isLastItem = false,
  }) {
    final theme = Theme.of(context);
    final isSelected = index == selectedIndex;
    
    // Border radius for the theme option containers
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isFirstItem ? 12 : 0),
      bottomLeft: Radius.circular(isFirstItem ? 12 : 0),
      topRight: Radius.circular(isLastItem ? 12 : 0),
      bottomRight: Radius.circular(isLastItem ? 12 : 0),
    );
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: borderRadius,
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Theme preview thumbnail
              Container(
                height: 35,
                width: 55,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: index == 0 
                      ? AppColors.backgroundLight
                      : AppColors.backgroundDark,
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: index == 2 
                    ? Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Container(
                          height: 12,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: index == 0 
                                ? AppColors.accentLight
                                : AppColors.accentDark,
                          ),
                        ),
                      ),
              ),
              
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}