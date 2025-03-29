import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for haptic feedback
import '../utils/theme.dart';

class WheelTimerPicker extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onChanged;
  
  const WheelTimerPicker({
    super.key,
    required this.initialMinutes,
    required this.onChanged,
  });

  @override
  State<WheelTimerPicker> createState() => _WheelTimerPickerState();
}

class _WheelTimerPickerState extends State<WheelTimerPicker> {
  late FixedExtentScrollController _scrollController;
  final int _maxMinutes = 60;
  final int _minMinutes = 1;
  
  // Track the currently selected value
  late int _selectedMinutes;
  // Track the previous value to know when it changes
  late int _previousMinutes;
  
  @override
  void initState() {
    super.initState();
    // Set the initial selected minutes
    _selectedMinutes = widget.initialMinutes;
    _previousMinutes = widget.initialMinutes;
    
    // Initialize the scroll controller to show the initial value
    _scrollController = FixedExtentScrollController(
      initialItem: widget.initialMinutes - _minMinutes,
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Use theme-aware colors
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Set Duration',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.buttonBackground(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection highlight
                Positioned(
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.accent(context).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                // Wheel picker
                SizedBox(
                  width: 150,
                  child: NotificationListener<ScrollNotification>(
                    // Listen for scroll updates to provide haptic feedback
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        // Get the current position to determine the current value
                        final currentItem = (_scrollController.position.pixels / 50).round();
                        final currentMinutes = currentItem + _minMinutes;
                        
                        // Only provide feedback when crossing a minute boundary
                        if (currentMinutes != _previousMinutes && 
                            currentMinutes >= _minMinutes && 
                            currentMinutes <= _maxMinutes) {
                          // Use the lightest haptic feedback for subtlety
                          HapticFeedback.selectionClick();
                          _previousMinutes = currentMinutes;
                        }
                      }
                      return false;
                    },
                    child: CupertinoPicker(
                      scrollController: _scrollController,
                      itemExtent: 50,
                      backgroundColor: Colors.transparent,
                      onSelectedItemChanged: (index) {
                        final minutes = index + _minMinutes;
                        // Update the selected minutes in state
                        setState(() {
                          _selectedMinutes = minutes;
                        });
                        widget.onChanged(minutes);
                      },
                      children: List<Widget>.generate(
                        _maxMinutes - _minMinutes + 1,
                        (index) {
                          final minutes = index + _minMinutes;
                          // Compare against _selectedMinutes
                          final isSelected = minutes == _selectedMinutes;
                          
                          return Center(
                            child: Text(
                              minutes == 1 ? '$minutes minute' : '$minutes minutes', // Proper plural handling
                              style: TextStyle(
                                color: isSelected 
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: isSelected ? 22 : 18,
                                fontWeight: isSelected 
                                    ? FontWeight.w500 
                                    : FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}