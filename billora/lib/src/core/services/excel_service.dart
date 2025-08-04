import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:billora/src/features/dashboard/domain/entities/report_params.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';

class ExcelService {
  static const String _overviewSheetName = 'Overview';
  static const String _detailsSheetName = 'Details';
  static const String _customersSheetName = 'Customers';
  static const String _productsSheetName = 'Products';

  /// Generate Excel report with multiple sheets
  static Uint8List generateInvoiceReport({
    required ReportParams params,
    required List<Invoice> invoices,
    required List<Customer> customers,
    required List<Product> products,
  }) {
    final excel = Excel.createExcel();
    
    // Create Overview sheet
    _createOverviewSheet(excel, params, invoices);
    
    // Create Details sheet
    _createDetailsSheet(excel, params, invoices);
    
    // Create Customers sheet
    _createCustomersSheet(excel, customers);
    
    // Create Products sheet
    _createProductsSheet(excel, products);
    
    return Uint8List.fromList(excel.encode()!);
  }

  static void _createOverviewSheet(
    Excel excel,
    ReportParams params,
    List<Invoice> invoices,
  ) {
    final sheet = excel[_overviewSheetName];
    
    // Title
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = 'Invoice Report Overview'
      ..cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );
    
    // Date Range
    final dateRangeCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2));
    dateRangeCell.value = 'Date Range:';
    dateRangeCell.cellStyle = CellStyle(bold: true);
    
    final dateRangeValueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2));
    dateRangeValueCell.value = '${_formatDate(params.dateRange.startDate)} - ${_formatDate(params.dateRange.endDate)}';
    
    // Summary Statistics
    final totalInvoices = invoices.length;
    final totalRevenue = invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
    final averageValue = totalInvoices > 0 ? totalRevenue / totalInvoices : 0.0;
    final paidInvoices = invoices.where((i) => i.status == InvoiceStatus.paid).length;
    final overdueInvoices = invoices.where((i) => i.status == InvoiceStatus.overdue).length;
    
    // Statistics table
    final statsData = [
      ['Metric', 'Value'],
      ['Total Invoices', totalInvoices],
      ['Total Revenue', _formatCurrency(totalRevenue, params.currency)],
      ['Average Invoice Value', _formatCurrency(averageValue, params.currency)],
      ['Paid Invoices', paidInvoices],
      ['Overdue Invoices', overdueInvoices],
      ['Payment Rate', totalInvoices > 0 ? '${((paidInvoices / totalInvoices) * 100).toStringAsFixed(1)}%' : '0%'],
    ];
    
    _addTableToSheet(sheet, statsData, 4, 0);
    
    // Status Distribution
    final statusDistribution = <String, int>{};
    for (final invoice in invoices) {
      final status = invoice.status.name;
      statusDistribution[status] = (statusDistribution[status] ?? 0) + 1;
    }
    
    final statusData = [
      ['Status', 'Count', 'Percentage'],
      ...statusDistribution.entries.map((entry) => [
        entry.key.toUpperCase(),
        entry.value,
        '${((entry.value / totalInvoices) * 100).toStringAsFixed(1)}%',
      ]),
    ];
    
    _addTableToSheet(sheet, statusData, 4, 4);
  }

  static void _createDetailsSheet(
    Excel excel,
    ReportParams params,
    List<Invoice> invoices,
  ) {
    final sheet = excel[_detailsSheetName];
    
    // Headers
    final headers = [
      'Invoice ID',
      'Customer Name',
      'Date Created',
      'Due Date',
      'Status',
      'Subtotal',
      'Tax',
      'Total',
      'Tags',
      'Note',
    ];
    
    // Add headers
    for (int i = 0; i < headers.length; i++) {
      final headerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      headerCell.value = headers[i];
      headerCell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#E0E0E0',
      );
    }
    
    // Add data rows
    for (int i = 0; i < invoices.length; i++) {
      final invoice = invoices[i];
      final row = i + 1;
      
      final idCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
      idCell.value = invoice.id;
      
      final customerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
      customerCell.value = invoice.customerName;
      
      final dateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row));
      dateCell.value = _formatDate(invoice.createdAt);
      
      final dueDateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row));
      dueDateCell.value = invoice.dueDate != null ? _formatDate(invoice.dueDate!) : '';
      
      final statusCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row));
      statusCell.value = invoice.status.name.toUpperCase();
      
      final subtotalCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row));
      subtotalCell.value = invoice.subtotal;
      
      final taxCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row));
      taxCell.value = invoice.tax;
      
      final totalCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row));
      totalCell.value = invoice.total;
      
      final tagsCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row));
      tagsCell.value = invoice.tags.join(', ');
      
      final noteCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row));
      noteCell.value = invoice.note ?? '';
    }
    
    // Auto-fit columns - commented out as method not available
    // for (int i = 0; i < headers.length; i++) {
    //   sheet.setColumnAutoFit(i);
    // }
  }

  static void _createCustomersSheet(
    Excel excel,
    List<Customer> customers,
  ) {
    final sheet = excel[_customersSheetName];
    
    // Headers
    final headers = [
      'Customer ID',
      'Name',
      'Email',
      'Phone',
      'Address',
      'Created Date',
      'Total Invoices',
      'Total Revenue',
    ];
    
    // Add headers
    for (int i = 0; i < headers.length; i++) {
      final headerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      headerCell.value = headers[i];
      headerCell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#E0E0E0',
      );
    }
    
    // Add data rows
    for (int i = 0; i < customers.length; i++) {
      final customer = customers[i];
      final row = i + 1;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = customer.id;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = customer.name;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = customer.email;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = customer.phone;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        .value = customer.address;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .value = 'N/A'; // Created date not available
      
      // These would need to be calculated from invoice data
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .value = 0; // Total invoices
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
        .value = 0.0; // Total revenue
    }
    
    // Auto-fit columns - commented out as method not available
    // for (int i = 0; i < headers.length; i++) {
    //   sheet.setColumnAutoFit(i);
    // }
  }

  static void _createProductsSheet(
    Excel excel,
    List<Product> products,
  ) {
    final sheet = excel[_productsSheetName];
    
    // Headers
    final headers = [
      'Product ID',
      'Name',
      'Description',
      'Category',
      'Unit Price',
      'Tax Rate',
      'Created Date',
      'Usage Count',
    ];
    
    // Add headers
    for (int i = 0; i < headers.length; i++) {
      final headerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      headerCell.value = headers[i];
      headerCell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#E0E0E0',
      );
    }
    
    // Add data rows
    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      final row = i + 1;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = product.id;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = product.name;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = product.description;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = product.category;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        .value = product.price;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        .value = '${product.tax.toStringAsFixed(1)}%';
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        .value = 'N/A'; // Created date not available
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
        .value = 0; // Usage count would need to be calculated
    }
    
    // Auto-fit columns - commented out as method not available
    // for (int i = 0; i < headers.length; i++) {
    //   sheet.setColumnAutoFit(i);
    // }
  }

  static void _addTableToSheet(
    Sheet sheet,
    List<List<dynamic>> data,
    int startRow,
    int startCol,
  ) {
    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data[i].length; j++) {
        sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: startCol + j,
          rowIndex: startRow + i,
        )).value = data[i][j];
      }
    }
  }

  static String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String _formatCurrency(double amount, String currency) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: currency == 'USD' ? '\$' : currency,
    );
    return formatter.format(amount);
  }
} 