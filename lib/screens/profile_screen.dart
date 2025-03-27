import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../utils/notification_service.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
                      side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ),
                ],
                
                const SizedBox(height: 40),
                
                // Theme settings
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Use System Theme'),
                        subtitle: const Text('Automatically match device settings'),
                        value: appState.followSystemTheme,
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          appState.setFollowSystemTheme(value);
                        },
                      ),
                      
                      if (!appState.followSystemTheme) ...[
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: Text(appState.isDarkMode ? 'On' : 'Off'),
                          value: appState.isDarkMode,
                          activeColor: Theme.of(context).colorScheme.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            appState.setDarkMode(value);
                          },
                        ),
                      ],
                      
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Currently using: ${appState.isDarkMode ? 'Dark theme' : 'Light theme'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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