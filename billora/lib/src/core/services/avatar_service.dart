import 'package:flutter/material.dart';

class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  // Consistent color palette for all avatars
  static const List<Color> _avatarColors = [
    Color(0xFF4A90E2), // Blue
    Color(0xFF7ED321), // Green
    Color(0xFFF5A623), // Orange
    Color(0xFFD0021B), // Red
    Color(0xFF9013FE), // Purple
    Color(0xFF50E3C2), // Teal
    Color(0xFFFF6B35), // Deep Orange
    Color(0xFF9C27B0), // Deep Purple
    Color(0xFF2196F3), // Light Blue
    Color(0xFF4CAF50), // Light Green
    Color(0xFFFF9800), // Amber
    Color(0xFFE91E63), // Pink
  ];

  /// Get consistent avatar color for a given name
  static Color getAvatarColor(String name) {
    if (name.isEmpty) return _avatarColors[0];
    return _avatarColors[name.hashCode.abs() % _avatarColors.length];
  }

  /// Get initials from a name (supports multiple words)
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    
    List<String> words = name.trim().split(RegExp(r'\s+'));
    String initials = '';
    
    // Take first letter of first 2 words
    for (int i = 0; i < words.length && i < 2; i++) {
      if (words[i].isNotEmpty) {
        initials += words[i][0].toUpperCase();
      }
    }
    
    return initials.isEmpty ? '?' : initials;
  }

  /// Get first letter of name (single character)
  static String getFirstLetter(String name) {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  /// Build a consistent avatar widget
  static Widget buildAvatar({
    required String name,
    double size = 40.0,
    bool isCircular = true,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    final color = backgroundColor ?? getAvatarColor(name);
    final textColorFinal = textColor ?? Colors.white;
    final fontSizeFinal = fontSize ?? (size * 0.4).clamp(12.0, 24.0);
    final fontWeightFinal = fontWeight ?? FontWeight.w600;
    final initials = getInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(size / 2),
        boxShadow: boxShadow,
        border: border,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColorFinal,
            fontSize: fontSizeFinal,
            fontWeight: fontWeightFinal,
          ),
        ),
      ),
    );
  }

  /// Build a ranking avatar with special styling
  static Widget buildRankingAvatar({
    required String name,
    required int position,
    double size = 50.0,
    bool isFirst = false,
  }) {
    Color avatarColor;
    Color borderColor = Colors.white;
    double borderWidth = 2.0;
    List<BoxShadow> boxShadow = [];

    // Special colors for top 3 positions
    switch (position) {
      case 1:
        avatarColor = const Color(0xFF4285F4); // Blue
        borderColor = const Color(0xFFFFD700); // Gold border
        borderWidth = 3.0;
        boxShadow = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case 2:
        avatarColor = const Color(0xFF34A853); // Green
        borderColor = const Color(0xFFC0C0C0); // Silver border
        borderWidth = 3.0;
        boxShadow = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ];
        break;
      case 3:
        avatarColor = const Color(0xFFFF6B35); // Orange
        borderColor = const Color(0xFFCD7F32); // Bronze border
        borderWidth = 3.0;
        boxShadow = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      default:
        avatarColor = getAvatarColor(name);
        boxShadow = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: boxShadow,
      ),
      child: Center(
        child: Text(
          getInitials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: (size * 0.4).clamp(12.0, 24.0),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Build a VIP customer avatar with special styling
  static Widget buildVipAvatar({
    required String name,
    double size = 44.0,
    bool isVip = false,
  }) {
    final baseAvatar = buildAvatar(
      name: name,
      size: size,
      isCircular: true,
    );

    if (!isVip) return baseAvatar;

    return Stack(
      children: [
        baseAvatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD700), // Gold
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Get consistent avatar color for a customer (used for caching)
  static Color getCustomerAvatarColor(String customerName) {
    return getAvatarColor(customerName);
  }

  /// Get consistent initials for a customer (used for caching)
  static String getCustomerInitials(String customerName) {
    return getInitials(customerName);
  }
}


