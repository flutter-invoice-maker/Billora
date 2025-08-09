import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

class InvoicePrintTemplates {
  // Wrapper function để thu nhỏ template cho preview
  static Widget _wrapForPreview(Widget template, {bool isPreview = false}) {
    // Không scale ở đây để tránh thay đổi layout gây overflow; 
    // các nơi hiển thị (FittedBox) sẽ quyết định tỉ lệ hiển thị.
    return template;
  }

  // Template 1: Professional Business (Commercial, Tax, Electronic, VAT)
  static Widget professionalBusiness(BuildContext context, Invoice invoice, {bool isPreview = false}) {
    final companyOrShopName = invoice.items.isNotEmpty ? invoice.items.first.companyOrShopName ?? '' : '';
    final template = Container(
      color: Colors.white,
      padding: EdgeInsets.all(isPreview ? 8 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with company branding area
          Container(
            padding: EdgeInsets.all(isPreview ? 6 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(isPreview ? 3 : 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyOrShopName.isNotEmpty ? companyOrShopName : 'YOUR COMPANY NAME',
                      style: TextStyle(
                        fontSize: isPreview ? 6 : 20, // Tăng từ 3 lên 6
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isPreview ? 1 : 4),
                    Text(
                      'Professional Invoice Solutions',
                      style: TextStyle(
                        fontSize: isPreview ? 4 : 14, // Tăng từ 2 lên 4
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPreview ? 4 : 16, 
                    vertical: isPreview ? 2 : 8
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isPreview ? 2 : 6),
                  ),
                  child: Text(
                    invoice.status.name.toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                      fontSize: isPreview ? 4 : 12, // Tăng từ 2 lên 4
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Invoice title and number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getInvoiceTypeTitle(invoice.templateId ?? ''),
                    style: TextStyle(
                      fontSize: isPreview ? 10 : 32, // Tăng từ 6 lên 10
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  Text(
                    '#${invoice.id}',
                    style: TextStyle(
                      fontSize: isPreview ? 5 : 18, // Tăng từ 3 lên 5
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              // QR Code placeholder
              Container(
                width: isPreview ? 20 : 80,
                height: isPreview ? 20 : 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                ),
                child: Center(
                  child: Text(
                    'QR\nCODE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isPreview ? 4 : 12, // Tăng từ 2 lên 4
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Customer and date info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(isPreview ? 5 : 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BILL TO',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        invoice.customerName,
                        style: TextStyle(
                          fontSize: isPreview ? 3 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        'Customer Address\nCity, State, ZIP\nCountry',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: isPreview ? 5 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Invoice Date', _formatDate(invoice.createdAt)),
                    SizedBox(height: isPreview ? 2 : 12),
                    if (invoice.dueDate != null)
                      _buildInfoRow('Due Date', _formatDate(invoice.dueDate!)),
                    SizedBox(height: isPreview ? 2 : 12),
                    _buildInfoRow('Payment Terms', 'Net 30'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Items table
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isPreview ? 4 : 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('DESCRIPTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12))),
                      Expanded(child: Text('QTY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12), textAlign: TextAlign.center)),
                      Expanded(child: Text('RATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12), textAlign: TextAlign.center)),
                      Expanded(child: Text('AMOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    padding: EdgeInsets.all(isPreview ? 4 : 16),
                    decoration: BoxDecoration(
                      color: index.isEven ? const Color(0xFFF8FAFC) : Colors.white,
                      border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isPreview ? 2 : 14,
                                ),
                              ),
                              if (item.description != null)
                                Text(
                                  item.description ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isPreview ? 2 : 12,
                                  ),
                                ),
                              if (item.extraFields['sku'] != null)
                                Text(
                                  'SKU: ${item.extraFields['sku']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isPreview ? 2 : 12,
                                  ),
                                ),
                              if (item.extraFields['vatRegistrationNumber'] != null)
                                Text(
                                  'VAT: ${item.extraFields['vatRegistrationNumber']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isPreview ? 2 : 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.quantity.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: isPreview ? 2 : 14),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${item.unitPrice.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: isPreview ? 2 : 14),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isPreview ? 2 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 6 : 24),

          // Totals section
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: isPreview ? 75 : 300,
                padding: EdgeInsets.all(isPreview ? 5 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildTotalRow('Subtotal', invoice.subtotal),
                    SizedBox(height: isPreview ? 2 : 8),
                    _buildTotalRow('Tax', invoice.tax),
                    Divider(height: isPreview ? 10 : 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: isPreview ? 3 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        Text(
                          '\$${invoice.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isPreview ? 3 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Footer with notes and promotional content
          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            SizedBox(height: isPreview ? 6 : 24),
            Container(
              padding: EdgeInsets.all(isPreview ? 4 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOTES',
                    style: TextStyle(
                      fontSize: isPreview ? 2 : 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: isPreview ? 2 : 8),
                  Text(
                    invoice.note ?? '',
                    style: TextStyle(
                      fontSize: isPreview ? 2 : 14,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: isPreview ? 6 : 24),
          
          // Promotional footer
          Container(
            padding: EdgeInsets.all(isPreview ? 4 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '💼 Powered by Billora - Professional Invoice Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPreview ? 2 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return _wrapForPreview(template, isPreview: isPreview);
  }

  // Template 2: Modern Creative (Sales, Self-billing)
  static Widget modernCreative(BuildContext context, Invoice invoice, {bool isPreview = false}) {
    final companyOrShopName = invoice.items.isNotEmpty ? invoice.items.first.companyOrShopName ?? '' : '';
    final template = Container(
      color: Colors.white,
      padding: EdgeInsets.all(isPreview ? 8 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creative header
          Container(
            padding: EdgeInsets.all(isPreview ? 6 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(isPreview ? 4 : 16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyOrShopName.isNotEmpty ? companyOrShopName : '🚀 CREATIVE STUDIO',
                        style: TextStyle(
                          fontSize: isPreview ? 6 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        _getInvoiceTypeTitle(invoice.templateId ?? ''),
                        style: TextStyle(
                          fontSize: isPreview ? 3 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '#${invoice.id}',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPreview ? 5 : 20, 
                    vertical: isPreview ? 2 : 10
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isPreview ? 10 : 25),
                  ),
                  child: Text(
                    invoice.status.name.toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      fontSize: isPreview ? 2 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Info cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isPreview ? 5 : 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(isPreview ? 3 : 12),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('👤', style: TextStyle(fontSize: isPreview ? 4 : 16)),
                          SizedBox(width: isPreview ? 2 : 8),
                          Text(
                            'CLIENT',
                            style: TextStyle(
                              fontSize: isPreview ? 2 : 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        invoice.customerName,
                        style: TextStyle(
                          fontSize: isPreview ? 3 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: isPreview ? 5 : 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isPreview ? 5 : 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(isPreview ? 3 : 12),
                    border: Border.all(color: const Color(0xFFD1FAE5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('📅', style: TextStyle(fontSize: isPreview ? 4 : 16)),
                          SizedBox(width: isPreview ? 2 : 8),
                          Text(
                            'DATE',
                            style: TextStyle(
                              fontSize: isPreview ? 2 : 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        _formatDate(invoice.createdAt),
                        style: TextStyle(
                          fontSize: isPreview ? 3 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: isPreview ? 5 : 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isPreview ? 5 : 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(isPreview ? 3 : 12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('⏰', style: TextStyle(fontSize: isPreview ? 4 : 16)),
                          SizedBox(width: isPreview ? 2 : 8),
                          Text(
                            'DUE',
                            style: TextStyle(
                              fontSize: isPreview ? 2 : 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        invoice.dueDate != null ? _formatDate(invoice.dueDate!) : 'On Receipt',
                        style: TextStyle(
                          fontSize: isPreview ? 3 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Creative items table
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPreview ? 4 : 16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: isPreview ? 0.5 : 2),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isPreview ? 5 : 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF111827),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('✨ ITEM DESCRIPTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(child: Text('QTY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(child: Text('RATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(child: Text('TOTAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    padding: EdgeInsets.all(isPreview ? 5 : 20),
                    decoration: BoxDecoration(
                      color: index.isEven ? const Color(0xFFF9FAFB) : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: isPreview ? 2 : 8,
                                    height: isPreview ? 2 : 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF7C3AED),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: isPreview ? 2 : 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isPreview ? 2 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.description != null) ...[
                                SizedBox(height: isPreview ? 1 : 4),
                                Padding(
                                  padding: EdgeInsets.only(left: isPreview ? 4 : 16),
                                  child: Text(
                                    item.description ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: isPreview ? 2 : 12,
                                    ),
                                  ),
                                ),
                              ],
                              if (item.extraFields['sku'] != null)
                                Text(
                                  'SKU: ${item.extraFields['sku']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isPreview ? 2 : 12,
                                  ),
                                ),
                              if (item.extraFields['vatRegistrationNumber'] != null)
                                Text(
                                  'VAT: ${item.extraFields['vatRegistrationNumber']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isPreview ? 2 : 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.quantity.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: isPreview ? 2 : 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${item.unitPrice.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: isPreview ? 2 : 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isPreview ? 2 : 14,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Creative totals
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(isPreview ? 6 : 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(isPreview ? 4 : 16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('💰', style: TextStyle(fontSize: isPreview ? 5 : 20)),
                        SizedBox(width: isPreview ? 2 : 8),
                        Text(
                          'INVOICE TOTAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isPreview ? 3 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isPreview ? 2 : 12),
                    Text(
                      '\$${invoice.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPreview ? 6 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isPreview ? 2 : 8),
                    Text(
                      'Subtotal: \$${invoice.subtotal.toStringAsFixed(2)} | Tax: \$${invoice.tax.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: isPreview ? 2 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            SizedBox(height: isPreview ? 6 : 24),
            Container(
              padding: EdgeInsets.all(isPreview ? 4 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(isPreview ? 3 : 12),
                border: Border.all(color: const Color(0xFFE9D5FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('📝', style: TextStyle(fontSize: isPreview ? 4 : 16)),
                      SizedBox(width: isPreview ? 2 : 8),
                      Text(
                        'NOTES',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isPreview ? 2 : 8),
                  Text(invoice.note ?? ''),
                ],
              ),
            ),
          ],

          SizedBox(height: isPreview ? 6 : 24),
          Container(
            padding: EdgeInsets.all(isPreview ? 4 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(isPreview ? 3 : 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🎨 Created with Billora - Where Creativity Meets Professionalism',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPreview ? 2 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return _wrapForPreview(template, isPreview: isPreview);
  }

  // Template 3: Minimal Clean (Proforma, Credit/Debit notes)
  static Widget minimalClean(BuildContext context, Invoice invoice, {bool isPreview = false}) {
    final companyOrShopName = invoice.items.isNotEmpty ? invoice.items.first.companyOrShopName ?? '' : '';
    final template = Container(
      color: Colors.white,
      padding: EdgeInsets.all(isPreview ? 10 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimal header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyOrShopName.isNotEmpty ? companyOrShopName : _getInvoiceTypeTitle(invoice.templateId ?? '').toUpperCase(),
                    style: TextStyle(
                      fontSize: isPreview ? 9 : 36,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 3,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: isPreview ? 2 : 8),
                  Text(
                    '#${invoice.id}',
                    style: TextStyle(
                      fontSize: isPreview ? 4 : 16,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isPreview ? 6 : 24, 
                  vertical: isPreview ? 3 : 12
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF374151), width: isPreview ? 0.5 : 2),
                  borderRadius: BorderRadius.circular(isPreview ? 0 : 0),
                ),
                child: Text(
                  invoice.status.name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    fontSize: isPreview ? 2 : 12,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isPreview ? 15 : 60),

          // Clean info layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyOrShopName.isNotEmpty ? companyOrShopName : 'BILL TO',
                      style: TextStyle(
                        fontSize: isPreview ? 2 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: isPreview ? 4 : 16),
                    Text(
                      invoice.customerName,
                      style: TextStyle(
                        fontSize: isPreview ? 6 : 24,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: isPreview ? 2 : 8),
                    Text(
                      'Customer Address\nCity, State ZIP\nCountry',
                      style: TextStyle(
                        fontSize: isPreview ? 2 : 14,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMinimalInfoRow('DATE', _formatDate(invoice.createdAt)),
                    SizedBox(height: isPreview ? 4 : 16),
                    if (invoice.dueDate != null)
                      _buildMinimalInfoRow('DUE DATE', _formatDate(invoice.dueDate!)),
                    SizedBox(height: isPreview ? 4 : 16),
                    _buildMinimalInfoRow('TERMS', 'Net 30'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isPreview ? 15 : 60),

          // Minimal table
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: isPreview ? 4 : 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF374151), width: 2),
                    bottom: BorderSide(color: Color(0xFF374151), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 2 : 12, letterSpacing: 1))),
                    Expanded(child: Text('QTY', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 2 : 12, letterSpacing: 1), textAlign: TextAlign.center)),
                    Expanded(child: Text('RATE', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 2 : 12, letterSpacing: 1), textAlign: TextAlign.center)),
                    Expanded(child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 2 : 12, letterSpacing: 1), textAlign: TextAlign.center)),
                  ],
                ),
              ),
              ...invoice.items.map((item) => Container(
                padding: EdgeInsets.symmetric(vertical: isPreview ? 5 : 20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: isPreview ? 0.25 : 1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: isPreview ? 4 : 16,
                            ),
                          ),
                          if (item.description != null) ...[
                            SizedBox(height: isPreview ? 1 : 4),
                            Text(
                              item.description ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isPreview ? 2 : 14,
                              ),
                            ),
                          ],
                          if (item.extraFields['sku'] != null)
                            Text(
                              'SKU: ${item.extraFields['sku']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isPreview ? 2 : 12,
                              ),
                            ),
                          if (item.extraFields['vatRegistrationNumber'] != null)
                            Text(
                              'VAT: ${item.extraFields['vatRegistrationNumber']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isPreview ? 2 : 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: isPreview ? 4 : 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '\$${item.unitPrice.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: isPreview ? 4 : 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isPreview ? 4 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
          SizedBox(height: isPreview ? 10 : 40),

          // Clean totals
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMinimalTotalRow('SUBTOTAL', invoice.subtotal),
                  SizedBox(height: isPreview ? 2 : 12),
                  _buildMinimalTotalRow('TAX', invoice.tax),
                  SizedBox(height: isPreview ? 5 : 20),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPreview ? 6 : 24, 
                      vertical: isPreview ? 4 : 16
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF374151), width: isPreview ? 0.5 : 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: isPreview ? 4 : 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: isPreview ? 5 : 32),
                        Text(
                          '\$${invoice.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isPreview ? 4 : 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            SizedBox(height: isPreview ? 15 : 60),
            Container(
              padding: EdgeInsets.all(isPreview ? 4 : 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOTES',
                    style: TextStyle(
                      fontSize: isPreview ? 2 : 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: isPreview ? 2 : 12),
                  Text(
                    invoice.note ?? '',
                    style: TextStyle(fontSize: isPreview ? 2 : 16, height: 1.6),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: isPreview ? 10 : 40),
          Center(
            child: Text(
              'Powered by Billora - Minimal. Professional. Effective.',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: isPreview ? 2 : 12,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
    return _wrapForPreview(template, isPreview: isPreview);
  }

  // Template 4: Corporate Formal (Internal transfers, consignment)
  static Widget corporateFormal(BuildContext context, Invoice invoice, {bool isPreview = false}) {
    final companyOrShopName = invoice.items.isNotEmpty ? invoice.items.first.companyOrShopName ?? '' : '';
    final template = Container(
      color: Colors.white,
      padding: EdgeInsets.all(isPreview ? 8 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Corporate header
          Container(
            padding: EdgeInsets.all(isPreview ? 6 : 24),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyOrShopName.isNotEmpty ? companyOrShopName : 'CORPORATE HEADQUARTERS',
                      style: TextStyle(
                        fontSize: isPreview ? 5 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: isPreview ? 1 : 4),
                    Text(
                      _getInvoiceTypeTitle(invoice.templateId ?? ''),
                      style: TextStyle(
                        fontSize: isPreview ? 3 : 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Document #${invoice.id}',
                      style: TextStyle(
                        fontSize: isPreview ? 2 : 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPreview ? 4 : 16, 
                    vertical: isPreview ? 2 : 8
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invoice.status),
                    borderRadius: BorderRadius.circular(isPreview ? 1 : 4),
                  ),
                  child: Text(
                    invoice.status.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isPreview ? 2 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Corporate info grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isPreview ? 5 : 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1F2937)),
                    borderRadius: BorderRadius.circular(isPreview ? 1 : 4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyOrShopName.isNotEmpty ? companyOrShopName : 'RECIPIENT',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        invoice.customerName,
                        style: TextStyle(
                          fontSize: isPreview ? 3 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isPreview ? 1 : 4),
                      Text(
                        'Department/Division\nInternal Code: INT-001',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: isPreview ? 5 : 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isPreview ? 5 : 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1F2937)),
                    borderRadius: BorderRadius.circular(isPreview ? 1 : 4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyOrShopName.isNotEmpty ? companyOrShopName : 'DOCUMENT DATE',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        _formatDate(invoice.createdAt),
                        style: TextStyle(fontSize: isPreview ? 3 : 16),
                      ),
                      SizedBox(height: isPreview ? 1 : 4),
                      Text(
                        'Fiscal Year: 2025\nQuarter: Q1',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: isPreview ? 5 : 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isPreview ? 5 : 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1F2937)),
                    borderRadius: BorderRadius.circular(isPreview ? 1 : 4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyOrShopName.isNotEmpty ? companyOrShopName : 'AUTHORIZATION',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        'APPROVED',
                        style: TextStyle(
                          fontSize: isPreview ? 3 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      SizedBox(height: isPreview ? 1 : 4),
                      Text(
                        'Manager: J. Smith\nRef: AUTH-2025-001',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Corporate table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1F2937)),
              borderRadius: BorderRadius.circular(isPreview ? 1 : 4),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isPreview ? 4 : 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F2937),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: Text('ITEM DESCRIPTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12))),
                      Expanded(child: Text('QTY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12), textAlign: TextAlign.center)),
                      Expanded(child: Text('UNIT COST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12), textAlign: TextAlign.center)),
                      Expanded(child: Text('TOTAL COST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    padding: EdgeInsets.all(isPreview ? 4 : 16),
                    decoration: BoxDecoration(
                      color: index.isEven ? const Color(0xFFF9FAFB) : Colors.white,
                      border: Border(top: BorderSide(color: const Color(0xFF1F2937))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (item.description != null) ...[
                                SizedBox(height: isPreview ? 1 : 4),
                                Text(
                                  item.description ?? '',
                                  style: TextStyle(color: Colors.grey[600], fontSize: isPreview ? 2 : 12),
                                ),
                              ],
                              if (item.extraFields['sku'] != null)
                                Text(
                                  'SKU: ${item.extraFields['sku']}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: isPreview ? 1 : 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              if (item.extraFields['vatRegistrationNumber'] != null)
                                Text(
                                  'VAT: ${item.extraFields['vatRegistrationNumber']}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: isPreview ? 1 : 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.quantity.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${item.unitPrice.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 6 : 24),

          // Corporate summary
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: isPreview ? 90 : 350,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1F2937)),
                  borderRadius: BorderRadius.circular(isPreview ? 1 : 4),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isPreview ? 3 : 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1F2937),
                      ),
                      child: Row(
                        children: [
                          Text('FINANCIAL SUMMARY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isPreview ? 4 : 16),
                      child: Column(
                        children: [
                          _buildCorporateRow('Net Amount:', invoice.subtotal),
                          SizedBox(height: isPreview ? 2 : 8),
                          _buildCorporateRow('Tax Amount:', invoice.tax),
                          SizedBox(height: isPreview ? 2 : 8),
                          _buildCorporateRow('Processing Fee:', 0.00),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TOTAL AMOUNT:', style: TextStyle(fontSize: isPreview ? 3 : 16, fontWeight: FontWeight.bold)),
                              Text('\$${invoice.total.toStringAsFixed(2)}', style: TextStyle(fontSize: isPreview ? 3 : 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            SizedBox(height: isPreview ? 6 : 24),
            Container(
              padding: EdgeInsets.all(isPreview ? 4 : 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1F2937)),
                borderRadius: BorderRadius.circular(isPreview ? 1 : 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTERNAL NOTES',
                    style: TextStyle(fontSize: isPreview ? 2 : 12, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937), letterSpacing: 1),
                  ),
                  SizedBox(height: isPreview ? 2 : 8),
                  Text(invoice.note ?? ''),
                ],
              ),
            ),
          ],

          SizedBox(height: isPreview ? 6 : 24),
          Container(
            padding: EdgeInsets.all(isPreview ? 3 : 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🏢 Enterprise Solution by Billora - Streamlining Corporate Operations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPreview ? 2 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return _wrapForPreview(template, isPreview: isPreview);
  }

  // Template 5: Service Based (Timesheet, transport receipts)
  static Widget serviceBased(BuildContext context, Invoice invoice, {bool isPreview = false}) {
    final companyOrShopName = invoice.items.isNotEmpty ? invoice.items.first.companyOrShopName ?? '' : '';
    final template = Container(
      color: Colors.white,
      padding: EdgeInsets.all(isPreview ? 8 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service header
          Container(
            padding: EdgeInsets.all(isPreview ? 6 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyOrShopName.isNotEmpty ? companyOrShopName : '⚡ SERVICE PROVIDER',
                        style: TextStyle(
                          fontSize: isPreview ? 6 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        _getInvoiceTypeTitle(invoice.templateId ?? ''),
                        style: TextStyle(
                          fontSize: isPreview ? 3 : 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Service ID: #${invoice.id}',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isPreview ? 4 : 16, 
                        vertical: isPreview ? 2 : 8
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isPreview ? 10 : 20),
                      ),
                      child: Text(
                        invoice.status.name.toUpperCase(),
                        style: TextStyle(
                          color: const Color(0xFF0F766E),
                          fontWeight: FontWeight.bold,
                          fontSize: isPreview ? 2 : 12,
                        ),
                      ),
                    ),
                    SizedBox(height: isPreview ? 2 : 8),
                    Text(
                      '🕒 24/7 Support Available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPreview ? 2 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Service info
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(isPreview ? 5 : 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                    border: Border.all(color: const Color(0xFF5EEAD4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('🏢', style: TextStyle(fontSize: isPreview ? 4 : 16)),
                          SizedBox(width: isPreview ? 2 : 8),
                          Text(
                            'CLIENT INFORMATION',
                            style: TextStyle(
                              fontSize: isPreview ? 2 : 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isPreview ? 3 : 12),
                      Text(
                        invoice.customerName,
                        style: TextStyle(
                          fontSize: isPreview ? 5 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isPreview ? 2 : 8),
                      Text(
                        'Client ID: CLI-${invoice.customerName.hashCode.abs().toString().substring(0, 4)}\nService Level: Premium\nAccount Manager: Sarah Johnson',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: isPreview ? 10 : 20),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isPreview ? 4 : 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('📅', style: TextStyle(fontSize: isPreview ? 4 : 16)),
                              SizedBox(width: isPreview ? 2 : 8),
                              Text(
                                'SERVICE PERIOD',
                                style: TextStyle(
                                  fontSize: isPreview ? 2 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isPreview ? 2 : 8),
                          Text(
                            _formatDate(invoice.createdAt),
                            style: TextStyle(
                              fontSize: isPreview ? 3 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isPreview ? 5 : 16),
                    Container(
                      padding: EdgeInsets.all(isPreview ? 4 : 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('⏱️', style: TextStyle(fontSize: isPreview ? 4 : 16)),
                              SizedBox(width: isPreview ? 2 : 8),
                              Text(
                                'TOTAL HOURS',
                                style: TextStyle(
                                  fontSize: isPreview ? 2 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isPreview ? 2 : 8),
                          Text(
                            '${invoice.items.fold(0.0, (sum, item) => sum + item.quantity)} hrs',
                            style: TextStyle(
                              fontSize: isPreview ? 3 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isPreview ? 8 : 32),

          // Service items table
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
              border: Border.all(color: const Color(0xFF0F766E), width: isPreview ? 0.5 : 2),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isPreview ? 4 : 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F766E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('🛠️ SERVICE DESCRIPTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(child: Text('HOURS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(child: Text('RATE/HR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(child: Text('SUBTOTAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    padding: EdgeInsets.all(isPreview ? 4 : 16),
                    decoration: BoxDecoration(
                      color: index.isEven ? const Color(0xFFF0FDFA) : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: isPreview ? 1 : 6,
                                    height: isPreview ? 1 : 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0F766E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: isPreview ? 2 : 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isPreview ? 2 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.description != null) ...[
                                SizedBox(height: isPreview ? 1 : 4),
                                Padding(
                                  padding: EdgeInsets.only(left: isPreview ? 4 : 14),
                                  child: Text(
                                    item.description ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: isPreview ? 2 : 12,
                                    ),
                                  ),
                                ),
                              ],
                              if (item.extraFields['sku'] != null)
                                Text(
                                  'Service Code: SVC-${(index + 1).toString().padLeft(3, '0')}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: isPreview ? 1 : 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${item.quantity}h',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: isPreview ? 2 : 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${item.unitPrice.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: isPreview ? 2 : 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isPreview ? 2 : 14,
                              color: const Color(0xFF0F766E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 6 : 24),

          // Service totals
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(isPreview ? 5 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('💰', style: TextStyle(fontSize: isPreview ? 4 : 18)),
                        SizedBox(width: isPreview ? 2 : 8),
                        Text(
                          'SERVICE TOTAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isPreview ? 2 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isPreview ? 2 : 12),
                    Text(
                      '\$${invoice.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPreview ? 7 : 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isPreview ? 2 : 8),
                    Text(
                      'Net: \$${invoice.subtotal.toStringAsFixed(2)} + Tax: \$${invoice.tax.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: isPreview ? 2 : 12,
                      ),
                    ),
                    SizedBox(height: isPreview ? 2 : 8),
                    Text(
                      '✅ Quality Guaranteed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPreview ? 2 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            SizedBox(height: isPreview ? 6 : 24),
            Container(
              padding: EdgeInsets.all(isPreview ? 4 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                border: Border.all(color: const Color(0xFF5EEAD4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('📝', style: TextStyle(fontSize: isPreview ? 4 : 16)),
                      SizedBox(width: isPreview ? 2 : 8),
                      Text(
                        'SERVICE NOTES',
                        style: TextStyle(
                          fontSize: isPreview ? 2 : 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isPreview ? 2 : 8),
                  Text(invoice.note ?? ''),
                ],
              ),
            ),
          ],

          SizedBox(height: isPreview ? 6 : 24),
          Container(
            padding: EdgeInsets.all(isPreview ? 4 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '⚡ Powered by Billora - Excellence in Service Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPreview ? 2 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return _wrapForPreview(template, isPreview: isPreview);
  }

  // Template 6: Simple Receipt (Bank fees, stamps/tickets)
  static Widget simpleReceipt(BuildContext context, Invoice invoice, {bool isPreview = false}) {
    final companyOrShopName = invoice.items.isNotEmpty ? invoice.items.first.companyOrShopName ?? '' : '';
    final template = Container(
      color: Colors.white,
      padding: EdgeInsets.all(isPreview ? 6 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Receipt header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isPreview ? 5 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
            ),
            child: Column(
              children: [
                Text(
                  companyOrShopName.isNotEmpty ? companyOrShopName : '🧾 OFFICIAL RECEIPT',
                  style: TextStyle(
                    fontSize: isPreview ? 5 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isPreview ? 2 : 8),
                Text(
                  _getInvoiceTypeTitle(invoice.templateId ?? ''),
                  style: TextStyle(
                    fontSize: isPreview ? 3 : 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Receipt #${invoice.id}',
                  style: TextStyle(
                    fontSize: isPreview ? 2 : 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 6 : 24),

          // Receipt details
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isPreview ? 5 : 20),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECEIVED FROM:',
                      style: TextStyle(
                        fontSize: isPreview ? 2 : 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      invoice.customerName,
                      style: TextStyle(
                        fontSize: isPreview ? 2 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isPreview ? 2 : 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DATE:',
                      style: TextStyle(
                        fontSize: isPreview ? 2 : 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      _formatDate(invoice.createdAt),
                      style: TextStyle(fontSize: isPreview ? 2 : 14),
                    ),
                  ],
                ),
                SizedBox(height: isPreview ? 2 : 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PAYMENT METHOD:',
                      style: TextStyle(
                        fontSize: isPreview ? 2 : 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      'Cash/Card',
                      style: TextStyle(fontSize: isPreview ? 2 : 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 5 : 20),

          // Items list
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isPreview ? 3 : 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12))),
                      Expanded(child: Text('QTY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12), textAlign: TextAlign.center)),
                      Expanded(child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isPreview ? 2 : 12), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                ...invoice.items.map((item) => Container(
                  padding: EdgeInsets.all(isPreview ? 3 : 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.name,
                          style: TextStyle(fontSize: isPreview ? 2 : 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.quantity.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: isPreview ? 2 : 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '\$${item.total.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isPreview ? 2 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: isPreview ? 5 : 20),

          // Total section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isPreview ? 5 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
            ),
            child: Column(
              children: [
                if (invoice.tax > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal:',
                        style: TextStyle(color: Colors.white, fontSize: isPreview ? 2 : 14),
                      ),
                      Text(
                        '\$${invoice.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white, fontSize: isPreview ? 2 : 14),
                      ),
                    ],
                  ),
                  SizedBox(height: isPreview ? 2 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tax:',
                        style: TextStyle(color: Colors.white, fontSize: isPreview ? 2 : 14),
                      ),
                      Text(
                        '\$${invoice.tax.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white, fontSize: isPreview ? 2 : 14),
                      ),
                    ],
                  ),
                  SizedBox(height: isPreview ? 2 : 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL PAID:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPreview ? 3 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${invoice.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPreview ? 3 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            SizedBox(height: isPreview ? 2 : 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isPreview ? 3 : 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(isPreview ? 2 : 8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOTES:',
                    style: TextStyle(
                      fontSize: isPreview ? 2 : 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: isPreview ? 1 : 4),
                  Text(
                    invoice.note ?? '',
                    style: TextStyle(fontSize: isPreview ? 2 : 12),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: isPreview ? 5 : 20),
          Text(
            '✅ PAYMENT RECEIVED - THANK YOU',
            style: TextStyle(
              fontSize: isPreview ? 2 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF059669),
            ),
          ),
          SizedBox(height: isPreview ? 2 : 8),
          Text(
            'Transaction ID: TXN-${invoice.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
            style: TextStyle(
              fontSize: isPreview ? 1 : 10,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: isPreview ? 2 : 16),
          Text(
            'Powered by Billora - Simple & Secure Receipts',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: isPreview ? 1 : 10,
            ),
          ),
        ],
      ),
    );
    return _wrapForPreview(template, isPreview: isPreview);
  }

  // Helper methods
  static Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.orange;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _getInvoiceTypeTitle(String templateId) {
    switch (templateId) {
      case 'professional_business':
        return 'COMMERCIAL INVOICE';
      case 'modern_creative':
        return 'SALES INVOICE';
      case 'minimal_clean':
        return 'PROFORMA INVOICE';
      case 'corporate_formal':
        return 'INTERNAL TRANSFER NOTE';
      case 'service_based':
        return 'TIMESHEET INVOICE';
      case 'simple_receipt':
        return 'PAYMENT RECEIPT';
      default:
        return 'INVOICE';
    }
  }

  static Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildTotalRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _buildMinimalInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  static Widget _buildMinimalTotalRow(String label, double amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(width: 20),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _buildCorporateRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Get template by ID
  static Widget getTemplateById(String templateId, BuildContext context, Invoice invoice, {bool isPreview = false}) {
    switch (templateId) {
      case 'professional_business':
        return professionalBusiness(context, invoice, isPreview: isPreview);
      case 'modern_creative':
        return modernCreative(context, invoice, isPreview: isPreview);
      case 'minimal_clean':
        return minimalClean(context, invoice, isPreview: isPreview);
      case 'corporate_formal':
        return corporateFormal(context, invoice, isPreview: isPreview);
      case 'service_based':
        return serviceBased(context, invoice, isPreview: isPreview);
      case 'simple_receipt':
        return simpleReceipt(context, invoice, isPreview: isPreview);
      default:
        return professionalBusiness(context, invoice, isPreview: isPreview);
    }
  }
}
