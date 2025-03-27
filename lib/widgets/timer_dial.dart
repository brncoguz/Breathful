import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class WheelTimerPicker extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onChanged;
  
  const WheelTimerPicker({
    Key? key,
    required this.initialMinutes,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<WheelTimerPicker> createState() => _WheelTimerPickerState();
}

class _WheelTimerPickerState extends State<WheelTimerPicker> {
  late FixedExtentScrollController _scrollController;
  final int _maxMinutes = 60;
  final int _minMinutes = 1;
  
  @override
  void initState() {
    super.initState();
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
              color: theme.colorScheme.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.5),
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
                      color: AppTheme.accent(context).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                // Wheel picker
                SizedBox(
                  width: 150,
                  child: CupertinoPicker(
                    scrollController: _scrollController,
                    itemExtent: 50,
                    backgroundColor: Colors.transparent,
                    onSelectedItemChanged: (index) {
                      final minutes = index + _minMinutes;
                      widget.onChanged(minutes);
                    },
                    children: List<Widget>.generate(
                      _maxMinutes - _minMinutes + 1,
                      (index) {
                        final minutes = index + _minMinutes;
                        final isSelected = minutes == widget.initialMinutes;
                        
                        return Center(
                          child: Text(
                            '$minutes minutes',
                            style: TextStyle(
                              color: isSelected 
                                  ? theme.colorScheme.onBackground
                                  : theme.colorScheme.onBackground.withOpacity(0.7),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}