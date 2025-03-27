class BreathingPreset {
  final String name;
  final double inhaleSeconds;
  final double exhaleSeconds;
  final double holdSeconds;
  final bool isDefault;
  
  BreathingPreset({
    required this.name,
    required this.inhaleSeconds,
    required this.exhaleSeconds,
    required this.holdSeconds,
    this.isDefault = false,
  });
  
  factory BreathingPreset.fromJson(Map<String, dynamic> json) {
    return BreathingPreset(
      name: json['name'],
      inhaleSeconds: json['inhaleSeconds'].toDouble(),
      exhaleSeconds: json['exhaleSeconds'].toDouble(),
      holdSeconds: json['holdSeconds'].toDouble(),
      isDefault: json['isDefault'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'inhaleSeconds': inhaleSeconds,
      'exhaleSeconds': exhaleSeconds,
      'holdSeconds': holdSeconds,
      'isDefault': isDefault,
    };
  }
  
  BreathingPreset copyWith({
    String? name,
    double? inhaleSeconds,
    double? exhaleSeconds,
    double? holdSeconds,
    bool? isDefault,
  }) {
    return BreathingPreset(
      name: name ?? this.name,
      inhaleSeconds: inhaleSeconds ?? this.inhaleSeconds,
      exhaleSeconds: exhaleSeconds ?? this.exhaleSeconds,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      isDefault: isDefault ?? this.isDefault,
    );
  }
  
  @override
  String toString() {
    return name;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreathingPreset &&
        other.name == name &&
        other.inhaleSeconds == inhaleSeconds &&
        other.exhaleSeconds == exhaleSeconds &&
        other.holdSeconds == holdSeconds;
  }
  
  @override
  int get hashCode {
    return name.hashCode ^
        inhaleSeconds.hashCode ^
        exhaleSeconds.hashCode ^
        holdSeconds.hashCode;
  }
}