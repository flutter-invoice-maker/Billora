import 'package:flutter/material.dart';
import '../../domain/entities/scan_result.dart';

class ConfidenceIndicatorWidget extends StatelessWidget {
  final ScanConfidence confidence;

  const ConfidenceIndicatorWidget({
    super.key,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Độ Tin Cậy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _getConfidenceValue(),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor()),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _getConfidenceText(),
                  style: TextStyle(
                    color: _getConfidenceColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getConfidenceValue() {
    switch (confidence) {
      case ScanConfidence.high:
        return 1.0;
      case ScanConfidence.medium:
        return 0.7;
      case ScanConfidence.low:
        return 0.4;
      case ScanConfidence.unknown:
        return 0.1;
    }
  }

  Color _getConfidenceColor() {
    switch (confidence) {
      case ScanConfidence.high:
        return Colors.green;
      case ScanConfidence.medium:
        return Colors.orange;
      case ScanConfidence.low:
        return Colors.red;
      case ScanConfidence.unknown:
        return Colors.grey;
    }
  }

  String _getConfidenceText() {
    switch (confidence) {
      case ScanConfidence.high:
        return 'Cao';
      case ScanConfidence.medium:
        return 'Trung bình';
      case ScanConfidence.low:
        return 'Thấp';
      case ScanConfidence.unknown:
        return 'Không xác định';
    }
  }
} 