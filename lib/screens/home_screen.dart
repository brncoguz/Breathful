import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/breathing_preset.dart';
import '../utils/theme.dart';
import '../widgets/timer_dial.dart';
import '../widgets/breath_counter.dart';
import 'breathing_session_screen.dart';
import 'advanced_settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Preset selection button
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final selectedPreset = await _showPresetPicker(context, appState);
                    if (selectedPreset != null) {
                      appState.setCurrentPreset(selectedPreset);
                    }
                  },
                  child: Container(
                    width: 200,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonBackground(context).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Centered text
                        Center(
                          child: Text(
                            appState.currentPreset.name,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // Right-aligned chevron
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Icon(
                              Icons.keyboard_arrow_right,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Mode toggle
              Center(
                child: Container(
                  height: 36,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonBackground(context).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Animated selection indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        left: appState.sessionMode == SessionMode.timer ? 0 : 100,
                        top: 0,
                        bottom: 0,
                        width: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.accent(context).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // Toggle options
                      Row(
                        children: [
                          _buildToggleOption(
                            context: context,
                            title: 'Timer',
                            isSelected: appState.sessionMode == SessionMode.timer,
                            onTap: () {
                              appState.setSessionMode(SessionMode.timer);
                            },
                          ),
                          _buildToggleOption(
                            context: context,
                            title: 'Breath Count',
                            isSelected: appState.sessionMode == SessionMode.breathCount,
                            onTap: () {
                              appState.setSessionMode(SessionMode.breathCount);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Timer dial or breath counter
              Expanded(
                child: appState.sessionMode == SessionMode.timer
                    ? WheelTimerPicker(
                        initialMinutes: appState.sessionDuration,
                        onChanged: (minutes) {
                          appState.setSessionDuration(minutes);
                        },
                      )
                    : BreathCounter(
                        initialCount: appState.breathCount,
                        onChanged: (count) {
                          appState.setBreathCount(count);
                        },
                      ),
              ),
              
              const SizedBox(height: 40),
              
              // Start button
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BreathingSessionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'START',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Advanced settings button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvancedSettingsScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  ),
                  child: const Text(
                    'Advanced Settings',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  // Toggle option widget
  Widget _buildToggleOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected 
                  ? Theme.of(context).colorScheme.onSurface 
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
  
  // Preset picker with swipe-to-delete functionality
  Future<BreathingPreset?> _showPresetPicker(BuildContext context, AppState appState) async {
    final theme = Theme.of(context);
    
    return showModalBottomSheet<BreathingPreset>(
      context: context,
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: appState.allPresets.length,
                  itemBuilder: (context, index) {
                    final preset = appState.allPresets[index];
                    final isSelected = preset.name == appState.currentPreset.name;
                    final isDefaultPreset = preset.isDefault;
                    
                    return Dismissible(
                      // Use preset name as key
                      key: Key(preset.name),
                      // Only allow dismissal if it's not a default preset
                      direction: isDefaultPreset 
                          ? DismissDirection.none 
                          : DismissDirection.endToStart,
                      // Confirm before deleting
                      confirmDismiss: (direction) async {
                        if (isDefaultPreset) return false;
                        
                        // Don't allow deleting the current preset
                        if (isSelected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Can't delete the active preset"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return false;
                        }
                        
                        // Show confirmation dialog
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Preset'),
                            content: Text('Are you sure you want to delete "${preset.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('DELETE'),
                              ),
                            ],
                          ),
                        ) ?? false;
                      },
                      // Handle the dismissal
                      onDismissed: (direction) {
                        // Remove preset using the existing method in AppState
                        appState.deleteUserPreset(preset);
                        
                        // Show a snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted "${preset.name}"'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      // The background that appears when swiping
                      background: Container(
                        color: Colors.transparent,
                      ),
                      // The secondary background (for end-to-start swipe)
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, preset);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Text(
                                preset.name,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: AppTheme.accent(context),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}