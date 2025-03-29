import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BreathCounter extends StatefulWidget {
  final int initialCount;
  final ValueChanged<int> onChanged;
  
  const BreathCounter({
    super.key,
    required this.initialCount,
    required this.onChanged,
  });

  @override
  State<BreathCounter> createState() => _BreathCounterState();
}

class _BreathCounterState extends State<BreathCounter> {
  late int _count;
  
  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
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
            'Number of Breaths',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrease button
              GestureDetector(
                onTap: () {
                  if (_count > 1) {
                    setState(() {
                      _count--;
                    });
                    widget.onChanged(_count);
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonBackground(context),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              
              // Count display
              Container(
                width: 120,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _count.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              
              // Increase button
              GestureDetector(
                onTap: () {
                  if (_count < 100) {
                    setState(() {
                      _count++;
                    });
                    widget.onChanged(_count);
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonBackground(context),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}