import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static const String _tag = 'Billora';
  
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  static void _log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final logTag = tag != null ? '$_tag-$tag' : _tag;
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    
    final logMessage = '[$timestamp] [$levelStr] $message';
    
    if (kDebugMode) {
      // In debug mode, use developer.log for better formatting
      developer.log(
        logMessage,
        name: logTag,
        level: _getLogLevelValue(level),
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      // In release mode, use developer.log for basic logging
      developer.log(
        logMessage,
        name: logTag,
        level: _getLogLevelValue(level),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  static int _getLogLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
  
  // Convenience methods for common operations
  static void scanStart(String operation, {Map<String, dynamic>? context}) {
    final contextStr = context != null ? ' | Context: $context' : '';
    info('🔍 Starting $operation$contextStr', tag: 'SCAN');
  }
  
  static void scanSuccess(String operation, {Map<String, dynamic>? result}) {
    final resultStr = result != null ? ' | Result: $result' : '';
    info('✅ $operation completed successfully$resultStr', tag: 'SCAN');
  }
  
  static void scanError(String operation, Object error, {StackTrace? stackTrace}) {
    Logger.error('❌ $operation failed: $error', tag: 'SCAN', error: error, stackTrace: stackTrace);
  }
  
  static void productOperation(String operation, {String? productId, String? productName}) {
    final details = <String>[];
    if (productId != null) details.add('ID: $productId');
    if (productName != null) details.add('Name: $productName');
    final detailsStr = details.isNotEmpty ? ' | ${details.join(', ')}' : '';
    info('🔄 Product $operation$detailsStr', tag: 'PRODUCT');
  }
  
  static void productSuccess(String operation, {String? productId, String? productName}) {
    final details = <String>[];
    if (productId != null) details.add('ID: $productId');
    if (productName != null) details.add('Name: $productName');
    final detailsStr = details.isNotEmpty ? ' | ${details.join(', ')}' : '';
    info('✅ Product $operation successful$detailsStr', tag: 'PRODUCT');
  }
  
  static void productError(String operation, Object error, {String? productId}) {
    final details = productId != null ? ' | ID: $productId' : '';
    Logger.error('❌ Product $operation failed$details: $error', tag: 'PRODUCT', error: error);
  }
  
  static void saveOperation(String operation, {String? itemId, String? itemName}) {
    final details = <String>[];
    if (itemId != null) details.add('ID: $itemId');
    if (itemName != null) details.add('Name: $itemName');
    final detailsStr = details.isNotEmpty ? ' | ${details.join(', ')}' : '';
    info('💾 $operation$detailsStr', tag: 'SAVE');
  }
  
  static void saveSuccess(String operation, {String? itemId, String? itemName}) {
    final details = <String>[];
    if (itemId != null) details.add('ID: $itemId');
    if (itemName != null) details.add('Name: $itemName');
    final detailsStr = details.isNotEmpty ? ' | ${details.join(', ')}' : '';
    info('✅ $operation saved successfully$detailsStr', tag: 'SAVE');
  }
  
  static void saveError(String operation, Object error, {String? itemId}) {
    final details = itemId != null ? ' | ID: $itemId' : '';
    Logger.error('❌ $operation save failed$details: $error', tag: 'SAVE', error: error);
  }
}
