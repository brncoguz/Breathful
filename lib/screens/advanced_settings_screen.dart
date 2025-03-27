import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../utils/theme.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  late double _inhaleSeconds;
  late double _exhaleSeconds;
  late double _holdSeconds;
  late bool _soundEnabled;
  late TextEditingController _presetNameController;
  bool _isCustomized = false;
  
  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _inhaleSeconds = appState.currentPreset.inhaleSeconds;
    _exhaleSeconds = appState.currentPreset.exhaleSeconds;
    _holdSeconds = appState.currentPreset.holdSeconds;
    _soundEnabled = appState.soundEnabled;
    _presetNameController = TextEditingController();
  }
  
  @override
  void dispose() {
    _presetNameController.dispose();
    super.dispose();
  }
  
  void _updateSettings() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setCustomPreset(
      inhaleSeconds: _inhaleSeconds,
      exhaleSeconds: _exhaleSeconds,
      holdSeconds: _holdSeconds,
    );
    appState.setSoundEnabled(_soundEnabled);
  }
  
  void _showSavePresetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Custom Preset'),
        content: TextField(
          controller: _presetNameController,
          decoration: const InputDecoration(
            hintText: 'Enter preset name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_presetNameController.text.isNotEmpty) {
                final appState = Provider.of<AppState>(context, listen: false);
                appState.saveCustomPreset(_presetNameController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Preset "${_presetNameController.text}" saved',
                    ),
                    backgroundColor: AppColors.accentLight,
                  ),
                );
                _presetNameController.clear();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryTextLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note about customizing presets
            if (_isCustomized)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryTextLight,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Your changes will override the current preset. '
                        'Save as a custom preset to keep these settings.',
                      ),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 24),
            
            // Inhale duration slider
            Text(
              'Inhale Duration: ${_inhaleSeconds.toStringAsFixed(1)}s',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Slider(
              value: _inhaleSeconds,
              min: 1.0,
              max: 10.0,
              divisions: 18,
              activeColor: AppColors.accentLight,
              inactiveColor: AppColors.accentLight.withOpacity(0.3),
              onChanged: (value) {
                setState(() {
                  _inhaleSeconds = value;
                  _isCustomized = true;
                });
                _updateSettings();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Exhale duration slider
            Text(
              'Exhale Duration: ${_exhaleSeconds.toStringAsFixed(1)}s',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Slider(
              value: _exhaleSeconds,
              min: 1.0,
              max: 10.0,
              divisions: 18,
              activeColor: AppColors.accentLight,
              inactiveColor: AppColors.accentLight.withOpacity(0.3),
              onChanged: (value) {
                setState(() {
                  _exhaleSeconds = value;
                  _isCustomized = true;
                });
                _updateSettings();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Hold duration slider
            Text(
              'Hold Duration: ${_holdSeconds.toStringAsFixed(1)}s',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Slider(
              value: _holdSeconds,
              min: 0.0,
              max: 10.0,
              divisions: 20,
              activeColor: AppColors.accentLight,
              inactiveColor: AppColors.accentLight.withOpacity(0.3),
              onChanged: (value) {
                setState(() {
                  _holdSeconds = value;
                  _isCustomized = true;
                });
                _updateSettings();
              },
            ),
            
            const SizedBox(height: 32),
            
            // Sound effects toggle
            SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text(
                'Play gentle sounds during transitions',
              ),
              value: _soundEnabled,
              activeColor: AppColors.accentLight,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
                _updateSettings();
              },
            ),
            
            const SizedBox(height: 48),
            
            // Save Custom Preset button
            Center(
              child: ElevatedButton.icon(
                onPressed: _showSavePresetDialog,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Custom Preset'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}