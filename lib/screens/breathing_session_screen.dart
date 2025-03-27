import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'dart:async';
import 'dart:math' as math;

import '../models/app_state.dart';
import '../utils/audio_service.dart';
import '../utils/notification_service.dart';
import '../utils/theme.dart';

enum BreathingState { inhale, inhaleHold, exhale, exhaleHold }

class BreathingSessionScreen extends StatefulWidget {
  const BreathingSessionScreen({Key? key}) : super(key: key);

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _particleController;
  late AnimationController _textAnimationController;
  late Animation<double> _textOpacityAnimation;
  Timer? _breathTimer; // For hold phases only
  Timer? _countdownTimer; // For phase countdown
  Timer? _sessionTimer; // Dedicated timer for session timing
  late AudioService _audioService;
  late DateTime _sessionStartTime;
  
  BreathingState _currentState = BreathingState.inhale;
  int _completedBreaths = 0;
  int _secondsElapsed = 0;
  int _phaseCountdown = 0; // Countdown for current phase
  bool _isPaused = false;
  bool _isFirstSession = false;
  bool _isEnding = false; // Flag to prevent multiple ending calls
  
  @override
  void initState() {
    super.initState();
    
    final appState = Provider.of<AppState>(context, listen: false);
    _audioService = AudioService();
    _audioService.setEnabled(appState.soundEnabled);
    
    // Check if this is the first session
    _isFirstSession = appState.totalSessions == 0;
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (appState.currentPreset.inhaleSeconds * 1000).toInt(),
      ),
    );
    
    // Initialize particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );
    _particleController.repeat();
    
    // Initialize text animation controller
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initial text animation
    _textAnimationController.forward();
    
    // Add listener to transition to next state when animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isPaused && !_isEnding) {
        _moveToNextState();
      }
    });
    
    // Create the circular animation
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start session
    _sessionStartTime = DateTime.now();
    _startBreathCycle();
    _startSessionTimer();
    
    // Play initial sound
    _audioService.playSound(AudioService.inhale);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    _textAnimationController.dispose();
    
    if (_breathTimer != null && _breathTimer!.isActive) {
      _breathTimer!.cancel();
    }
    
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
    
    if (_sessionTimer != null && _sessionTimer!.isActive) {
      _sessionTimer!.cancel();
    }
    
    _audioService.dispose();
    super.dispose();
  }
  
  void _startBreathCycle() {
    if (_isPaused || _isEnding) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Cancel any existing countdown timer
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
    
    // Cancel any existing breath phase timer
    if (_breathTimer != null && _breathTimer!.isActive) {
      _breathTimer!.cancel();
    }
    
    // Animate text change
    _textAnimationController.reset();
    _textAnimationController.forward();
    
    switch (_currentState) {
      case BreathingState.inhale:
        final inhaleDurationMs = (appState.currentPreset.inhaleSeconds * 1000).toInt();
        _animationController.duration = Duration(milliseconds: inhaleDurationMs);
        _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );
        _animationController.reset();
        _animationController.forward();
        _audioService.playSound(AudioService.inhale);
        
        // Start countdown for inhale phase
        _startPhaseCountdown(appState.currentPreset.inhaleSeconds.toInt());
        break;
        
      case BreathingState.inhaleHold:
        // For hold, we don't animate but use a timer
        if (appState.currentPreset.holdSeconds > 0) {
          _audioService.playSound(AudioService.hold);
          
          // Start countdown for hold phase
          _startPhaseCountdown(appState.currentPreset.holdSeconds.toInt());
          
          _breathTimer = Timer(
            Duration(milliseconds: (appState.currentPreset.holdSeconds * 1000).toInt()), 
            _moveToNextState,
          );
        } else {
          // If no hold, move directly to exhale
          _moveToNextState();
        }
        break;
        
      case BreathingState.exhale:
        final exhaleDurationMs = (appState.currentPreset.exhaleSeconds * 1000).toInt();
        _animationController.duration = Duration(milliseconds: exhaleDurationMs);
        _animation = Tween<double>(begin: 1.0, end: 0.5).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );
        _animationController.reset();
        _animationController.forward();
        _audioService.playSound(AudioService.exhale);
        
        // Start countdown for exhale phase
        _startPhaseCountdown(appState.currentPreset.exhaleSeconds.toInt());
        break;
        
      case BreathingState.exhaleHold:
        // For hold, we don't animate but use a timer
        if (appState.currentPreset.holdSeconds > 0) {
          _audioService.playSound(AudioService.hold);
          
          // Start countdown for hold phase
          _startPhaseCountdown(appState.currentPreset.holdSeconds.toInt());
          
          _breathTimer = Timer(
            Duration(milliseconds: (appState.currentPreset.holdSeconds * 1000).toInt()), 
            _moveToNextState,
          );
        } else {
          // If no hold, move directly to next breath
          _moveToNextState();
        }
        break;
    }
  }
  
  void _startPhaseCountdown(int seconds) {
    setState(() {
      _phaseCountdown = seconds;
    });
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _phaseCountdown > 0 && !_isEnding) {
        setState(() {
          _phaseCountdown--;
        });
      }
    });
  }
  
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isEnding) {
        setState(() {
          _secondsElapsed++;
        });
        
        final appState = Provider.of<AppState>(context, listen: false);
        
        // Check if time-based session should end
        if (appState.sessionMode == SessionMode.timer &&
            _secondsElapsed >= appState.sessionDuration * 60) {
          _endSession();
        }
      }
    });
  }
  
  void _moveToNextState() {
    if (_isPaused || _isEnding) return;
    
    // Cancel breath phase timer if active
    if (_breathTimer != null && _breathTimer!.isActive) {
      _breathTimer!.cancel();
    }
    
    // Cancel countdown timer if active
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
    
    setState(() {
      switch (_currentState) {
        case BreathingState.inhale:
          _currentState = BreathingState.inhaleHold;
          break;
          
        case BreathingState.inhaleHold:
          _currentState = BreathingState.exhale;
          break;
          
        case BreathingState.exhale:
          _currentState = BreathingState.exhaleHold;
          break;
          
        case BreathingState.exhaleHold:
          // Complete the breath cycle
          _completedBreaths++;
          
          final appState = Provider.of<AppState>(context, listen: false);
          
          // Check if session should end
          if (appState.sessionMode == SessionMode.breathCount &&
              _completedBreaths >= appState.breathCount) {
            _endSession();
            return;
          }
          
          // Start next breath cycle
          _currentState = BreathingState.inhale;
          break;
      }
    });
    
    // Start the next phase
    if (!_isEnding) {
      _startBreathCycle();
    }
  }
  
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      
      if (_isPaused) {
        _animationController.stop();
        _particleController.stop();
      } else {
        _particleController.repeat();
        // Restart current state
        _startBreathCycle();
      }
    });
  }
  
  void _endSession() {
    // Set ending flag to prevent multiple calls
    if (_isEnding) return;
    setState(() {
      _isEnding = true;
    });
    
    // Cancel all timers
    if (_breathTimer != null && _breathTimer!.isActive) {
      _breathTimer!.cancel();
    }
    
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
    
    if (_sessionTimer != null && _sessionTimer!.isActive) {
      _sessionTimer!.cancel();
    }
    
    _animationController.stop();
    _particleController.stop();
    _audioService.playSound(AudioService.complete);
    
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Calculate session duration in minutes
    final sessionDuration = DateTime.now().difference(_sessionStartTime);
    final durationMinutes = (sessionDuration.inSeconds / 60).ceil();
    
    // Record completed session
    appState.recordCompletedSession(durationMinutes);
    
    // Show session summary
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showSessionSummary(sessionDuration, appState);
      }
    });
  }
  
  void _showSessionSummary(Duration sessionDuration, AppState appState) {
    final double averageBreathDuration = _completedBreaths > 0 
        ? sessionDuration.inSeconds / _completedBreaths 
        : 0;
    
    // Format the session date
    final dateFormatter = DateFormat('EEEE, MMMM d');
    final timeFormatter = DateFormat('h:mm a');
    final now = DateTime.now();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Session Complete Header
              const Text(
                'Session Complete',
                style: TextStyle(
                  color: AppColors.primaryTextLight,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                dateFormatter.format(now),
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 16,
                ),
              ),
              
              Text(
                timeFormatter.format(now),
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Session Stats
              _buildSummaryStat(
                icon: Icons.timer_outlined, 
                label: 'Duration', 
                value: _formatTime(sessionDuration.inSeconds)
              ),
              
              const SizedBox(height: 16),
              
              _buildSummaryStat(
                icon: Icons.air_outlined, 
                label: 'Breaths', 
                value: '$_completedBreaths'
              ),
              
              const SizedBox(height: 16),
              
              _buildSummaryStat(
                icon: Icons.loop_outlined, 
                label: 'Average Breath', 
                value: '${averageBreathDuration.toStringAsFixed(1)}s'
              ),
              
              const SizedBox(height: 24),
              
              // Encouragement message
              Text(
                _getEncouragementMessage(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.accentLight,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close summary
                    
                    // If first session, show reminder dialog, otherwise return home
                    if (_isFirstSession) {
                      _showReminderDialog();
                    } else {
                      Navigator.pop(context); // Return to home screen
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLight,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSummaryStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accentLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.accentLight,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryTextLight,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _getEncouragementMessage() {
    final messages = [
      'Great work! Keep up the mindful breathing.',
      'Your mind and body thank you for this moment of calm.',
      'You\'re building a wonderful breathing habit.',
      'Each breath brings more peace and clarity.',
      'Taking time to breathe is a gift to yourself.',
    ];
    
    final random = math.Random();
    return messages[random.nextInt(messages.length)];
  }
  
  void _showReminderDialog() {
    final appState = Provider.of<AppState>(context, listen: false);
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Great job!'),
        content: const Text(
          'Would you like a daily reminder to practice breathing?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Return to home screen
              }
            },
            child: const Text('No, thanks'),
          ),
          TextButton(
            onPressed: () async {
              // Request notification permissions
              await NotificationService.requestNotificationPermissions(
                flutterLocalNotificationsPlugin,
              );
              
              if (!mounted) return;
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
              
              // Show time picker
              final timeOfDay = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 10, minute: 0),
              );
              
              if (timeOfDay != null && mounted) {
                appState.setReminderEnabled(true);
                appState.setReminderTime(timeOfDay);
                
                // Schedule notification
                await NotificationService.scheduleDailyReminder(
                  flutterLocalNotificationsPlugin,
                  timeOfDay,
                );
                
                if (mounted && Navigator.canPop(context)) {
                  Navigator.of(context).pop(); // Return to home screen
                }
              } else if (mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Return to home screen
              }
            },
            child: const Text('Yes, please'),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Session info
              Text(
                appState.currentPreset.name,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              
              const SizedBox(height: 20),
              
              // Breathing animation with countdown and text above
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Phase text positioned above the circle with animation and gap
                      Positioned(
                        top: 20, // Changed from negative to positive value to ensure text is visible
                        child: AnimatedOpacity(
                          opacity: _textOpacityAnimation.value,
                          duration: const Duration(milliseconds: 300),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, -0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _currentState == BreathingState.inhale
                                  ? 'Inhale'
                                  : _currentState == BreathingState.exhale
                                      ? 'Exhale'
                                      : 'Hold',
                              key: ValueKey<String>(_currentState.toString()),
                              style: const TextStyle(
                                color: AppColors.primaryTextLight,
                                fontSize: 30,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Background glow
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Container(
                            width: 280 * _animation.value,
                            height: 280 * _animation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accentLight.withValues(alpha: 0.1),
                                  AppColors.accentLight.withValues(alpha: 0.0),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          );
                        }
                      ),
                      
                      // Floating particles
                      AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(300, 300),
                            painter: _ParticlesPainter(
                              progress: _particleController.value,
                              color: AppColors.accentLight,
                              expansionRatio: _animation.value,
                            ),
                          );
                        }
                      ),
                      
                      // Main animated cloud-like shape with no border
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Container(
                            width: 240 * _animation.value,
                            height: 240 * _animation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accentLight.withValues(alpha: 0.4),
                                  AppColors.accentLight.withValues(alpha: 0.2),
                                  AppColors.accentLight.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                                stops: const [0.5, 0.75, 0.9, 1.0],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Countdown text
                      Text(
                        _phaseCountdown.toString(),
                        style: const TextStyle(
                          color: AppColors.primaryTextLight,
                          fontSize: 64,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
              const SizedBox(height: 40),
              
              // Session progress
              if (appState.sessionMode == SessionMode.timer)
                Text(
                  'Time: ${_formatTime(_secondsElapsed)} / ${_formatTime(appState.sessionDuration * 60)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              else
                Text(
                  'Breaths: $_completedBreaths / ${appState.breathCount}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              
              const SizedBox(height: 40),
              
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _togglePause,
                    icon: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                    ),
                    label: Text(_isPaused ? 'Resume' : 'Pause'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('End Session?'),
                          content: const Text(
                            'Are you sure you want to end this session?'
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
                                Navigator.pop(context);
                                _endSession();
                              },
                              child: const Text('End Session'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Particles painter for the floating animated particles
class _ParticlesPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double expansionRatio;
  final int particleCount = 15;
  
  _ParticlesPainter({
    required this.progress,
    required this.color,
    required this.expansionRatio,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(42); // Fixed seed for consistency
    final baseSize = size.width * 0.4;
    
    // Create particles
    for (int i = 0; i < particleCount; i++) {
      // Randomize particle properties
      final angle = random.nextDouble() * math.pi * 2;
      final distance = random.nextDouble() * baseSize * 0.5 * (0.6 + expansionRatio * 0.4);
      final speed = 0.3 + random.nextDouble() * 0.7;
      final particleSize = 1.0 + random.nextDouble() * 4.0;
      final opacity = 0.1 + random.nextDouble() * 0.3;
      
      // Calculate particle position based on time
      final adjustedProgress = (progress + i / particleCount) % 1.0;
      final currentDistance = distance * (0.4 + adjustedProgress * 0.6);
      
      // Apply slight spiral movement
      final currentAngle = angle + adjustedProgress * speed;
      
      // Position
      final x = center.dx + math.cos(currentAngle) * currentDistance;
      final y = center.dy + math.sin(currentAngle) * currentDistance;
      
      // Draw particle
      final paint = Paint()
        ..color = color.withOpacity(opacity * (1.0 - adjustedProgress))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }
  
  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) => 
      oldDelegate.progress != progress || 
      oldDelegate.expansionRatio != expansionRatio;
}