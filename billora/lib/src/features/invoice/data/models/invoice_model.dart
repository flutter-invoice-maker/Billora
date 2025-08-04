import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';

class InvoiceModel {
  final String id;
  final String customerId;
  final String customerName;
  final List<InvoiceItemModel> items;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? note;
  final String? templateId;
  final List<String> tags;
  final List<String> searchKeywords;

  InvoiceModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.paidAt,
    this.note,
    this.templateId,
    this.tags = const [],
    this.searchKeywords = const [],
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        id: json['id'] ?? '',
        customerId: json['customerId'] ?? '',
        customerName: json['customerName'] ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] ?? 0).toDouble(),
        tax: (json['tax'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
        status: json['status'] ?? 'draft',
        createdAt: DateTime.parse(json['createdAt']),
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
        paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
        note: json['note'],
        templateId: json['templateId'],
        tags: List<String>.from(json['tags'] ?? []),
        searchKeywords: List<String>.from(json['searchKeywords'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
        if (note != null && note!.isNotEmpty) 'note': note!,
        if (templateId != null && templateId!.isNotEmpty) 'templateId': templateId!,
        'tags': tags,
        'searchKeywords': searchKeywords,
      };

  Invoice toEntity() => Invoice(
        id: id,
        customerId: customerId,
        customerName: customerName,
        items: items.map((e) => e.toEntity()).toList(),
        subtotal: subtotal,
        tax: tax,
        total: total,
        status: InvoiceStatus.values.firstWhere(
          (s) => s.name == status,
          orElse: () => InvoiceStatus.draft,
        ),
        createdAt: createdAt,
        dueDate: dueDate,
        paidAt: paidAt,
        note: note,
        templateId: templateId,
        tags: tags,
        searchKeywords: searchKeywords,
      );

  factory InvoiceModel.fromEntity(Invoice invoice) => InvoiceModel(
        id: invoice.id,
        customerId: invoice.customerId,
        customerName: invoice.customerName,
        items: invoice.items.map(InvoiceItemModel.fromEntity).toList(),
        subtotal: invoice.subtotal,
        tax: invoice.tax,
        total: invoice.total,
        status: invoice.status.name,
        createdAt: invoice.createdAt,
        dueDate: invoice.dueDate,
        paidAt: invoice.paidAt,
        note: invoice.note,
        templateId: invoice.templateId,
        tags: invoice.tags,
        searchKeywords: invoice.searchKeywords,
      );
}

class InvoiceItemModel {
  final String id;
  final String name;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double tax;
  final double total;
  final String productId;

  InvoiceItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.tax,
    required this.total,
    required this.productId,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) => InvoiceItemModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        quantity: (json['quantity'] ?? 0).toDouble(),
        unitPrice: (json['unitPrice'] ?? 0).toDouble(),
        tax: (json['tax'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
        productId: json['productId'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null && description!.isNotEmpty) 'description': description!,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'tax': tax,
        'total': total,
        'productId': productId,
      };

  InvoiceItem toEntity() => InvoiceItem(
        id: id,
        name: name,
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
        tax: tax,
        total: total,
        productId: productId,
      );

  factory InvoiceItemModel.fromEntity(InvoiceItem item) => InvoiceItemModel(
        id: item.id,
        name: item.name,
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        tax: item.tax,
        total: item.total,
        productId: item.productId,
      );
} 