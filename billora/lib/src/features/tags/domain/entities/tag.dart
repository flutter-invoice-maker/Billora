import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final String id;
  final String name;
  final String color;
  final int usageCount;
  final DateTime createdAt;
  final DateTime? lastUsed;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
    this.usageCount = 0,
    required this.createdAt,
    this.lastUsed,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        color,
        usageCount,
        createdAt,
        lastUsed,
      ];

  Tag copyWith({
    String? id,
    String? name,
    String? color,
    int? usageCount,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'usageCount': usageCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUsed': lastUsed?.millisecondsSinceEpoch,
    };
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      usageCount: json['usageCount'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      lastUsed: json['lastUsed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUsed'] as int)
          : null,
    );
  }
} 