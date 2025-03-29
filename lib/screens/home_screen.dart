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
    
    // Use layout builder to get constraints
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive values based on constraints
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;
            
            // Limit content width on very wide screens
            final contentWidth = maxWidth > 500 ? 500.0 : maxWidth;
            
            // Calculate dynamic padding that increases with screen size
            // but is capped for very large screens
            final horizontalPadding = maxWidth * 0.06 > 24 ? 24.0 : maxWidth * 0.06;
            
            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: contentWidth,
                ),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: maxHeight * 0.05),
                    
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
                          width: contentWidth * 0.45, // Slightly narrower than before
                          height: 36, // Fixed height matching screenshot
                          constraints: const BoxConstraints(
                            minWidth: 150, // Reduced from 180
                            maxWidth: 200, // Reduced from 250
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.buttonBackground(context).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Stack(
                            children: [
                              // Centered text
                              Center(
                                child: Text(
                                  appState.currentPreset.name,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 14, // Reduced from 16
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                                    size: 14, // Reduced from 16
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Mode toggle
                    Center(
                      child: Container(
                        height: 36, // Fixed height matching screenshot
                        width: contentWidth * 0.45, // Same width as preset button
                        constraints: const BoxConstraints(
                          minWidth: 150, // Reduced from 180
                          maxWidth: 200, // Reduced from 250
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.buttonBackground(context).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: LayoutBuilder(
                          builder: (context, toggleConstraints) {
                            // Get the actual width of the toggle container
                            final toggleWidth = toggleConstraints.maxWidth;
                            final toggleHalfWidth = toggleWidth / 2;
                            
                            return Stack(
                              children: [
                                // Animated selection indicator
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  left: appState.sessionMode == SessionMode.timer ? 0 : toggleHalfWidth,
                                  top: 0,
                                  bottom: 0,
                                  width: toggleHalfWidth,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent(context).withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(18),
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
                            );
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(height: maxHeight * 0.04),
                    
                    // Timer dial or breath counter
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: contentWidth * 0.75, // Reduced from 0.85
                            maxHeight: maxHeight * 0.4, // Reduced from 0.5
                          ),
                          child: AspectRatio(
                            aspectRatio: 1.0, // Keep the picker/counter square
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
                        ),
                      ),
                    ),
                    
                    SizedBox(height: maxHeight * 0.04),
                    
                    // Start button
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 150,
                          maxWidth: 220,
                        ),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          child: const Text(
                            'START',
                            style: TextStyle(
                              fontSize: 16, // Reduced from 18
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
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
                          minimumSize: const Size(10, 10), // Allow for smaller touch target
                        ),
                        child: const Text(
                          'Advanced Settings',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: maxHeight * 0.05),
                  ],
                ),
              ),
            );
          },
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
              fontSize: 13, // Reduced from 14
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
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
      constraints: const BoxConstraints(
        maxWidth: 500, // Limit width on large screens
      ),
      isScrollControlled: true,
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
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
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
                              Expanded(
                                child: Text(
                                  preset.name,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                  ),
                                ),
                              ),
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