import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'breathing_preset.dart';

enum SessionMode { timer, breathCount }

class AppState with ChangeNotifier {
  // Default presets
  final List<BreathingPreset> _defaultPresets = [
    BreathingPreset(
      name: '5-5',
      inhaleSeconds: 5,
      exhaleSeconds: 5,
      holdSeconds: 0,
      isDefault: true,
    ),
    BreathingPreset(
      name: '4-7-8-7',
      inhaleSeconds: 4,
      exhaleSeconds: 8,
      holdSeconds: 7,
      isDefault: true,
    ),
    BreathingPreset(
      name: 'Box Breathing',
      inhaleSeconds: 4,
      exhaleSeconds: 4,
      holdSeconds: 4,
      isDefault: true,
    ),
  ];
  
  // User presets
  List<BreathingPreset> _userPresets = [];
  
  // Session settings
  BreathingPreset _currentPreset;
  SessionMode _sessionMode = SessionMode.timer;
  int _sessionDuration = 5; // in minutes
  int _breathCount = 10;
  
  // Stats
  int _totalSessions = 0;
  int _totalBreathingMinutes = 0;
  DateTime? _lastSessionDate;
  
  // Reminder settings
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 10, minute: 0);
  
  // Preferences
  bool _soundEnabled = true;
  
  // Theme settings
  bool _isDarkMode = false;
  bool _followSystemTheme = true;
  
  // Constructor initializes with default preset
  AppState() : _currentPreset = BreathingPreset(
    name: '5-5',
    inhaleSeconds: 5,
    exhaleSeconds: 5,
    holdSeconds: 0,
    isDefault: true,
  ) {
    _loadFromPrefs();
  }
  
  // Getters
  List<BreathingPreset> get allPresets => [..._defaultPresets, ..._userPresets];
  BreathingPreset get currentPreset => _currentPreset;
  SessionMode get sessionMode => _sessionMode;
  int get sessionDuration => _sessionDuration;
  int get breathCount => _breathCount;
  int get totalSessions => _totalSessions;
  int get totalBreathingMinutes => _totalBreathingMinutes;
  DateTime? get lastSessionDate => _lastSessionDate;
  bool get reminderEnabled => _reminderEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  bool get soundEnabled => _soundEnabled;
  
  // Theme getters
  bool get isDarkMode => _followSystemTheme 
      ? WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark 
      : _isDarkMode;
  bool get followSystemTheme => _followSystemTheme;
  ThemeMode get themeMode => _followSystemTheme 
      ? ThemeMode.system 
      : (_isDarkMode ? ThemeMode.dark : ThemeMode.light);
  
  // Setters
  void setCurrentPreset(BreathingPreset preset) {
    _currentPreset = preset;
    notifyListeners();
  }
  
  void setCustomPreset({
    required double inhaleSeconds,
    required double exhaleSeconds, 
    required double holdSeconds
  }) {
    _currentPreset = BreathingPreset(
      name: 'Custom',
      inhaleSeconds: inhaleSeconds,
      exhaleSeconds: exhaleSeconds,
      holdSeconds: holdSeconds,
      isDefault: false,
    );
    notifyListeners();
  }
  
  void saveCustomPreset(String name) {
    final newPreset = BreathingPreset(
      name: name,
      inhaleSeconds: _currentPreset.inhaleSeconds,
      exhaleSeconds: _currentPreset.exhaleSeconds,
      holdSeconds: _currentPreset.holdSeconds,
      isDefault: false,
    );
    
    _userPresets.add(newPreset);
    _currentPreset = newPreset;
    _saveToPrefs();
    notifyListeners();
  }
  
  void deleteUserPreset(BreathingPreset preset) {
    _userPresets.removeWhere((p) => p.name == preset.name);
    if (_currentPreset.name == preset.name) {
      _currentPreset = _defaultPresets[0];
    }
    _saveToPrefs();
    notifyListeners();
  }
  
  void setSessionMode(SessionMode mode) {
    _sessionMode = mode;
    notifyListeners();
  }
  
  void setSessionDuration(int minutes) {
    _sessionDuration = minutes;
    notifyListeners();
  }
  
  void setBreathCount(int count) {
    _breathCount = count;
    notifyListeners();
  }
  
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _saveToPrefs();
    notifyListeners();
  }
  
  void setReminderEnabled(bool enabled) {
    _reminderEnabled = enabled;
    _saveToPrefs();
    notifyListeners();
  }
  
  void setReminderTime(TimeOfDay time) {
    _reminderTime = time;
    _saveToPrefs();
    notifyListeners();
  }
  
  // Theme setters
  void setDarkMode(bool value) {
    _isDarkMode = value;
    _followSystemTheme = false;
    _saveToPrefs();
    notifyListeners();
  }
  
  void setFollowSystemTheme(bool value) {
    _followSystemTheme = value;
    _saveToPrefs();
    notifyListeners();
  }
  
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _followSystemTheme = false;
    _saveToPrefs();
    notifyListeners();
  }
  
  void recordCompletedSession(int durationMinutes) {
    _totalSessions++;
    _totalBreathingMinutes += durationMinutes;
    _lastSessionDate = DateTime.now();
    _saveToPrefs();
    notifyListeners();
  }
  
  // Load and save state from/to SharedPreferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load user presets
    final userPresetsJson = prefs.getStringList('userPresets') ?? [];
    _userPresets = userPresetsJson
        .map((json) => BreathingPreset.fromJson(jsonDecode(json)))
        .toList();
    
    // Load settings
    _sessionMode = SessionMode.values[prefs.getInt('sessionMode') ?? 0];
    _sessionDuration = prefs.getInt('sessionDuration') ?? 5;
    _breathCount = prefs.getInt('breathCount') ?? 10;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    
    // Load theme settings
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _followSystemTheme = prefs.getBool('followSystemTheme') ?? true;
    
    // Load stats
    _totalSessions = prefs.getInt('totalSessions') ?? 0;
    _totalBreathingMinutes = prefs.getInt('totalBreathingMinutes') ?? 0;
    final lastSessionTimestamp = prefs.getInt('lastSessionTimestamp');
    _lastSessionDate = lastSessionTimestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(lastSessionTimestamp) 
        : null;
    
    // Load reminder settings
    _reminderEnabled = prefs.getBool('reminderEnabled') ?? false;
    final reminderHour = prefs.getInt('reminderHour') ?? 10;
    final reminderMinute = prefs.getInt('reminderMinute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    
    // Load current preset
    final currentPresetJson = prefs.getString('currentPreset');
    if (currentPresetJson != null) {
      final decodedPreset = BreathingPreset.fromJson(jsonDecode(currentPresetJson));
      
      // Find matching preset in lists
      _currentPreset = [..._defaultPresets, ..._userPresets]
          .firstWhere(
            (p) => p.name == decodedPreset.name, 
            orElse: () => decodedPreset
          );
    }
    
    notifyListeners();
  }
  
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save user presets
    final userPresetsJson = _userPresets
        .map((preset) => jsonEncode(preset.toJson()))
        .toList();
    await prefs.setStringList('userPresets', userPresetsJson);
    
    // Save settings
    await prefs.setInt('sessionMode', _sessionMode.index);
    await prefs.setInt('sessionDuration', _sessionDuration);
    await prefs.setInt('breathCount', _breathCount);
    await prefs.setBool('soundEnabled', _soundEnabled);
    
    // Save theme settings
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('followSystemTheme', _followSystemTheme);
    
    // Save stats
    await prefs.setInt('totalSessions', _totalSessions);
    await prefs.setInt('totalBreathingMinutes', _totalBreathingMinutes);
    if (_lastSessionDate != null) {
      await prefs.setInt(
        'lastSessionTimestamp', 
        _lastSessionDate!.millisecondsSinceEpoch
      );
    }
    
    // Save reminder settings
    await prefs.setBool('reminderEnabled', _reminderEnabled);
    await prefs.setInt('reminderHour', _reminderTime.hour);
    await prefs.setInt('reminderMinute', _reminderTime.minute);
    
    // Save current preset
    await prefs.setString('currentPreset', jsonEncode(_currentPreset.toJson()));
  }
}