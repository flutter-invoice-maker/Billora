import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

class QRCodeWidget extends StatelessWidget {
  final Invoice invoice;
  final double size;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool showBorder;
  final BorderRadius? borderRadius;

  const QRCodeWidget({
    super.key,
    required this.invoice,
    this.size = 120,
    this.foregroundColor,
    this.backgroundColor,
    this.showBorder = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    return Container(
      width: size,
      height: size,
      decoration: showBorder ? BoxDecoration(
        border: Border.all(
          color: foregroundColor ?? primaryColor,
          width: 2,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ) : null,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: QrImageView(
          data: _generateSimpleQRData(),
          version: QrVersions.auto,
          size: size,
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: foregroundColor ?? primaryColor,
          ),
          backgroundColor: backgroundColor ?? Colors.white,
          embeddedImage: _getEmbeddedImage(),
          embeddedImageStyle: const QrEmbeddedImageStyle(
            size: Size(24, 24),
          ),
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  String _generateSimpleQRData() {
    // Chỉ chứa ID hóa đơn đơn giản, thống nhất với PDF service
    return 'invoice:${invoice.id}';
  }

  ImageProvider? _getEmbeddedImage() {
    // You can add a company logo here if needed
    // return AssetImage('assets/icons/logo.png');
    return null;
  }
}

class InvoiceQRCodeWidget extends StatelessWidget {
  final Invoice invoice;
  final double size;
  final bool showLabel;
  final String? labelText;
  final TextStyle? labelStyle;
  final MainAxisAlignment alignment;

  const InvoiceQRCodeWidget({
    super.key,
    required this.invoice,
    this.size = 120,
    this.showLabel = true,
    this.labelText,
    this.labelStyle,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultLabelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.primaryColor,
      fontWeight: FontWeight.w500,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        QRCodeWidget(
          invoice: invoice,
          size: size,
          foregroundColor: theme.primaryColor,
          backgroundColor: Colors.white,
          showBorder: true,
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            labelText ?? 'Scan to view invoice',
            style: labelStyle ?? defaultLabelStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class CompactQRCodeWidget extends StatelessWidget {
  final Invoice invoice;
  final double size;
  final Color? color;
  final bool showBackground;

  const CompactQRCodeWidget({
    super.key,
    required this.invoice,
    this.size = 80,
    this.color,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.primaryColor;

    return Container(
      width: size,
      height: size,
      decoration: showBackground ? BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: QrImageView(
          data: _generateSimpleQRData(),
          version: QrVersions.auto,
          size: size,
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: primaryColor,
          ),
          backgroundColor: Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          padding: const EdgeInsets.all(4),
        ),
      ),
    );
  }

  String _generateSimpleQRData() {
    // Chỉ chứa ID hóa đơn đơn giản, thống nhất với PDF service
    return 'invoice:${invoice.id}';
  }
} 