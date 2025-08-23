import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice_item.dart';
import 'package:billora/src/features/invoice/presentation/widgets/qr_code_widget.dart';

class InvoicePrintTemplates {
	// Helper function để lấy thông tin công ty từ Product
	static Map<String, String> _getCompanyInfo(Invoice invoice) {
		if (invoice.items.isEmpty) {
			return {
				'name': 'COMPANY NAME',
				'slogan': 'Professional Business Solutions',
				'address': '123 Business Street\nCity, State 12345\nPhone: (555) 123-4567',
			};
		}
		
		// Lấy thông tin từ item đầu tiên (giả sử tất cả items đều cùng công ty)
		final firstItem = invoice.items.first;
		
		return {
			'name': firstItem.companyOrShopName?.isNotEmpty == true 
				? firstItem.companyOrShopName! 
				: 'COMPANY NAME',
			'address': _buildCompanyAddress(firstItem),
		};
	}
	
	// Helper function để xây dựng địa chỉ công ty
	static String _buildCompanyAddress(InvoiceItem item) {
		final parts = <String>[];
		
		// Thêm địa chỉ nếu có
		if (item.companyAddress?.isNotEmpty == true) {
			parts.add(item.companyAddress!);
		}
		
		// Thêm số điện thoại nếu có
		if (item.companyPhone?.isNotEmpty == true) {
			parts.add('Phone: ${item.companyPhone}');
		}
		
		// Thêm email nếu có
		if (item.companyEmail?.isNotEmpty == true) {
			parts.add('Email: ${item.companyEmail}');
		}
		
		// Thêm website nếu có
		if (item.companyWebsite?.isNotEmpty == true) {
			parts.add('Website: ${item.companyWebsite}');
		}
		
		// Nếu không có thông tin gì, trả về địa chỉ mặc định
		if (parts.isEmpty) {
			return '123 Business Street\nCity, State 12345\nPhone: (555) 123-4567';
		}
		
		return parts.join('\n');
	}

	// Wrapper function để thu nhỏ template cho preview
	static Widget _wrapForPreview(Widget template, {bool isPreview = false}) {
		// Không scale ở đây để tránh thay đổi layout gây overflow;
		// các nơi hiển thị (FittedBox) sẽ quyết định tỉ lệ hiển thị.
		return template;
	}

	// Template 1: Professional Business (Commercial, Tax, Electronic, VAT)
	static Widget professionalBusiness(BuildContext context, Invoice invoice, {bool isPreview = false}) {
		final companyInfo = _getCompanyInfo(invoice);
		final template = Container(
			color: Colors.white,
			padding: EdgeInsets.all(isPreview ? 12 : 40),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Clean header with company name and QR code
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								flex: 2,
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											companyInfo['name']!,
											style: TextStyle(
												fontSize: isPreview ? 8 : 28,
												fontWeight: FontWeight.w700,
												color: Colors.black,
												letterSpacing: 0.5,
											),
										),
										SizedBox(height: isPreview ? 2 : 8),
										SizedBox(height: isPreview ? 3 : 12),
										Text(
											companyInfo['address']!,
											style: TextStyle(
												fontSize: isPreview ? 3 : 12,
												color: Colors.black87,
												height: 1.4,
											),
										),
									],
								),
							),
							SizedBox(width: isPreview ? 8 : 32),
							// QR Code positioned in top right
							Column(
								children: [
									CompactQRCodeWidget(
										invoice: invoice,
										size: isPreview ? 30.0 : 100.0,
										color: Colors.black,
										showBackground: true,
									),
									SizedBox(height: isPreview ? 2 : 8),
									Text(
										'Scan for Details',
										style: TextStyle(
											fontSize: isPreview ? 2 : 10,
											color: Colors.black54,
										),
									),
								],
							),
						],
					),
					
					SizedBox(height: isPreview ? 10 : 40),

					// Invoice title and status
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										_getInvoiceTypeTitle(invoice.templateId ?? ''),
										style: TextStyle(
											fontSize: isPreview ? 10 : 36,
											fontWeight: FontWeight.w300,
											color: Colors.black,
											letterSpacing: 2,
										),
									),
									Text(
										'No. ${invoice.id}',
										style: TextStyle(
											fontSize: isPreview ? 5 : 18,
											color: Colors.black54,
										),
									),
								],
							),
							Container(
								padding: EdgeInsets.symmetric(
									horizontal: isPreview ? 6 : 20, 
									vertical: isPreview ? 3 : 12
								),
								decoration: BoxDecoration(
									border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
								),
								child: Text(
									invoice.status.name.toUpperCase(),
									style: TextStyle(
										color: Colors.black,
										fontWeight: FontWeight.w600,
										fontSize: isPreview ? 3 : 14,
										letterSpacing: 1,
									),
								),
							),
						],
					),
					
					SizedBox(height: isPreview ? 10 : 40),

					// Bill to and invoice info
					Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								flex: 2,
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											'BILL TO',
											style: TextStyle(
												fontSize: isPreview ? 3 : 12,
												fontWeight: FontWeight.w600,
												color: Colors.black,
												letterSpacing: 1,
											),
										),
										SizedBox(height: isPreview ? 3 : 12),
										Text(
											invoice.customerName,
											style: TextStyle(
												fontSize: isPreview ? 5 : 20,
												fontWeight: FontWeight.w600,
												color: Colors.black,
											),
										),
										SizedBox(height: isPreview ? 2 : 8),
										Text(
											'Customer Address\nCity, State, ZIP\nCountry',
											style: TextStyle(
												fontSize: isPreview ? 3 : 14,
												color: Colors.black87,
												height: 1.5,
											),
										),
									],
								),
							),
							SizedBox(width: isPreview ? 10 : 40),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										_buildInfoRow('Invoice Date', _formatDate(invoice.createdAt), isPreview),
										SizedBox(height: isPreview ? 3 : 16),
										if (invoice.dueDate != null)
											_buildInfoRow('Due Date', _formatDate(invoice.dueDate!), isPreview),
										SizedBox(height: isPreview ? 3 : 16),
										_buildInfoRow('Payment Terms', 'Net 30', isPreview),
									],
								),
							),
						],
					),
					
					SizedBox(height: isPreview ? 10 : 40),

					// Items table
					Container(
						decoration: BoxDecoration(
							border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
						),
						child: Column(
							children: [
								Container(
									color: Colors.black,
									padding: EdgeInsets.all(isPreview ? 4 : 16),
									child: Row(
										children: [
											Expanded(flex: 3, child: Text('DESCRIPTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 14))),
											Expanded(child: Text('QTY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 14), textAlign: TextAlign.center)),
											Expanded(child: Text('RATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 14), textAlign: TextAlign.center)),
											Expanded(child: Text('AMOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 14), textAlign: TextAlign.center)),
										],
									),
								),
								...invoice.items.asMap().entries.map((entry) {
									final index = entry.key;
									final item = entry.value;
									return Container(
										padding: EdgeInsets.all(isPreview ? 4 : 16),
										decoration: BoxDecoration(
											color: index.isEven ? Colors.grey[50] : Colors.white,
											border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
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
																	fontWeight: FontWeight.w600,
																	fontSize: isPreview ? 3 : 14,
																	color: Colors.black,
																),
															),
															if (item.description != null) ...[
																SizedBox(height: isPreview ? 1 : 4),
																Text(
																	item.description ?? '',
																	style: TextStyle(
																		color: Colors.black54,
																		fontSize: isPreview ? 2 : 12,
																	),
																),
															],
														],
													),
												),
												Expanded(
													child: Text(
														item.quantity.toString(),
														textAlign: TextAlign.center,
														style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black),
													),
												),
												Expanded(
													child: Text(
														'\$${item.unitPrice.toStringAsFixed(2)}',
														textAlign: TextAlign.center,
														style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black),
													),
												),
												Expanded(
													child: Text(
														'\$${item.total.toStringAsFixed(2)}',
														textAlign: TextAlign.center,
														style: TextStyle(
															fontWeight: FontWeight.w700,
															fontSize: isPreview ? 3 : 14,
															color: Colors.black,
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

					// Totals section
					Row(
						mainAxisAlignment: MainAxisAlignment.end,
						children: [
							SizedBox(
								width: isPreview ? 100 : 300,
								child: Column(
									children: [
										_buildTotalRow('Subtotal', invoice.subtotal, isPreview),
										SizedBox(height: isPreview ? 2 : 8),
										_buildTotalRow('Tax', invoice.tax, isPreview),
										SizedBox(height: isPreview ? 3 : 12),
										Container(
											padding: EdgeInsets.symmetric(vertical: isPreview ? 3 : 12),
											decoration: BoxDecoration(
												border: const Border(
													top: BorderSide(color: Colors.black, width: 1),
												),
											),
											child: Row(
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: [
													Text(
														'TOTAL',
														style: TextStyle(
															fontSize: isPreview ? 4 : 18,
															fontWeight: FontWeight.w700,
															color: Colors.black,
														),
													),
													Text(
														'\$${invoice.total.toStringAsFixed(2)}',
														style: TextStyle(
															fontSize: isPreview ? 4 : 18,
															fontWeight: FontWeight.w700,
															color: Colors.black,
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

					if (invoice.note != null && invoice.note!.isNotEmpty) ...[
						SizedBox(height: isPreview ? 8 : 32),
						Container(
							padding: EdgeInsets.all(isPreview ? 6 : 20),
							decoration: BoxDecoration(
								border: Border.all(color: Colors.black, width: 1),
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'NOTES',
										style: TextStyle(
											fontSize: isPreview ? 3 : 12,
											fontWeight: FontWeight.w600,
											color: Colors.black,
											letterSpacing: 1,
										),
									),
									SizedBox(height: isPreview ? 2 : 8),
									Text(
										invoice.note ?? '',
										style: TextStyle(
											fontSize: isPreview ? 3 : 14,
											color: Colors.black87,
										),
									),
								],
							),
						),
					],
					
					SizedBox(height: isPreview ? 8 : 32),
					Container(
						padding: EdgeInsets.symmetric(vertical: isPreview ? 3 : 12),
						decoration: const BoxDecoration(
							border: Border(top: BorderSide(color: Colors.black, width: 1)),
						),
						child: Center(
							child: Text(
								'Powered by Billora - Professional Invoice Management',
								style: TextStyle(
									color: Colors.black54,
									fontSize: isPreview ? 2 : 12,
								),
							),
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
			padding: EdgeInsets.all(isPreview ? 12 : 40),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Modern header with geometric elements
					Row(
						children: [
							// Left side with company info
							Expanded(
								flex: 2,
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											children: [
												Container(
													width: isPreview ? 4 : 16,
													height: isPreview ? 4 : 16,
													color: Colors.black,
												),
												SizedBox(width: isPreview ? 2 : 8),
												Text(
													companyOrShopName.isNotEmpty ? companyOrShopName : 'CREATIVE STUDIO',
													style: TextStyle(
														fontSize: isPreview ? 7 : 24,
														fontWeight: FontWeight.w800,
														color: Colors.black,
													),
												),
											],
										),
										SizedBox(height: isPreview ? 3 : 12),
										Text(
											_getInvoiceTypeTitle(invoice.templateId ?? ''),
											style: TextStyle(
												fontSize: isPreview ? 4 : 16,
												color: Colors.black87,
												letterSpacing: 3,
											),
										),
										Text(
											'#${invoice.id}',
											style: TextStyle(
												fontSize: isPreview ? 3 : 14,
												color: Colors.black54,
											),
										),
									],
								),
							),
							
							// Right side with status and QR
							Column(
								crossAxisAlignment: CrossAxisAlignment.end,
								children: [
									Container(
										padding: EdgeInsets.symmetric(
											horizontal: isPreview ? 3 : 12, 
											vertical: isPreview ? 2 : 8
										),
										decoration: BoxDecoration(
											border: Border.all(color: Colors.black, width: isPreview ? 0.5 : 2),
										),
										child: Text(
											invoice.status.name.toUpperCase(),
											style: TextStyle(
												fontWeight: FontWeight.w500,
												letterSpacing: 1,
												fontSize: isPreview ? 2 : 12,
												color: Colors.black,
											),
										),
									),
								],
							),
						],
					),
					
					SizedBox(height: isPreview ? 20 : 80),

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
											'BILL TO',
											style: TextStyle(
												fontSize: isPreview ? 3 : 12,
												fontWeight: FontWeight.w600,
												color: Colors.black54,
												letterSpacing: 2,
											),
										),
										SizedBox(height: isPreview ? 4 : 16),
										Text(
											invoice.customerName,
											style: TextStyle(
												fontSize: isPreview ? 6 : 24,
												fontWeight: FontWeight.w300,
												color: Colors.black,
											),
										),
										SizedBox(height: isPreview ? 2 : 8),
										Text(
											'Customer Address\nCity, State ZIP\nCountry',
											style: TextStyle(
												fontSize: isPreview ? 3 : 14,
												color: Colors.black54,
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
										_buildMinimalInfoRow('DATE', _formatDate(invoice.createdAt), isPreview),
										SizedBox(height: isPreview ? 4 : 16),
										if (invoice.dueDate != null)
											_buildMinimalInfoRow('DUE DATE', _formatDate(invoice.dueDate!), isPreview),
										SizedBox(height: isPreview ? 4 : 16),
										_buildMinimalInfoRow('TERMS', 'Net 30', isPreview),
									],
								),
							),
						],
					),
					
					SizedBox(height: isPreview ? 20 : 80),

					// Minimal table
					Column(
						children: [
							Container(
								padding: EdgeInsets.symmetric(vertical: isPreview ? 4 : 16),
								decoration: BoxDecoration(
									border: Border(
										top: BorderSide(color: Colors.black, width: isPreview ? 1 : 2),
										bottom: const BorderSide(color: Colors.black, width: 1),
									),
								),
								child: Row(
									children: [
										Expanded(flex: 3, child: Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 12, letterSpacing: 1, color: Colors.black))),
										Expanded(child: Text('QTY', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 12, letterSpacing: 1, color: Colors.black), textAlign: TextAlign.center)),
										Expanded(child: Text('RATE', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 12, letterSpacing: 1, color: Colors.black), textAlign: TextAlign.center)),
										Expanded(child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 12, letterSpacing: 1, color: Colors.black), textAlign: TextAlign.center)),
									],
								),
							),
							...invoice.items.map((item) => Container(
								padding: EdgeInsets.symmetric(vertical: isPreview ? 6 : 24),
								decoration: BoxDecoration(
									border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: isPreview ? 0.5 : 1)),
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
															fontWeight: FontWeight.w400,
															fontSize: isPreview ? 4 : 16,
															color: Colors.black,
														),
													),
													if (item.description != null) ...[
														SizedBox(height: isPreview ? 1 : 4),
														Text(
															item.description ?? '',
															style: TextStyle(
																color: Colors.black54,
																fontSize: isPreview ? 3 : 14,
															),
														),
													],
												],
											),
										),
										Expanded(
											child: Text(
												item.quantity.toString(),
												textAlign: TextAlign.center,
												style: TextStyle(fontSize: isPreview ? 4 : 16, color: Colors.black),
											),
										),
										Expanded(
											child: Text(
												'\$${item.unitPrice.toStringAsFixed(2)}',
												textAlign: TextAlign.center,
												style: TextStyle(fontSize: isPreview ? 4 : 16, color: Colors.black),
											),
										),
										Expanded(
											child: Text(
												'\$${item.total.toStringAsFixed(2)}',
												textAlign: TextAlign.center,
												style: TextStyle(
													fontWeight: FontWeight.w600,
													fontSize: isPreview ? 4 : 16,
													color: Colors.black,
												),
											),
										),
									],
								),
							)),
						],
					),
					
					SizedBox(height: isPreview ? 15 : 60),

					// Clean totals
					Row(
						mainAxisAlignment: MainAxisAlignment.end,
						children: [
							Column(
								crossAxisAlignment: CrossAxisAlignment.end,
								children: [
									_buildMinimalTotalRow('SUBTOTAL', invoice.subtotal, isPreview),
									SizedBox(height: isPreview ? 3 : 16),
									_buildMinimalTotalRow('TAX', invoice.tax, isPreview),
									SizedBox(height: isPreview ? 8 : 32),
									Container(
										padding: EdgeInsets.symmetric(
											horizontal: isPreview ? 8 : 32, 
											vertical: isPreview ? 4 : 16
										),
										decoration: BoxDecoration(
											border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
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
														color: Colors.black,
													),
												),
												SizedBox(width: isPreview ? 8 : 40),
												Text(
													'\$${invoice.total.toStringAsFixed(2)}',
													style: TextStyle(
														fontSize: isPreview ? 4 : 20,
														fontWeight: FontWeight.w600,
														color: Colors.black,
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
						SizedBox(height: isPreview ? 20 : 80),
						Container(
							padding: EdgeInsets.all(isPreview ? 6 : 24),
							decoration: BoxDecoration(
								border: Border.all(color: Colors.black54, width: 1),
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'NOTES',
										style: TextStyle(
											fontSize: isPreview ? 3 : 12,
											fontWeight: FontWeight.w600,
											color: Colors.black54,
											letterSpacing: 2,
										),
									),
									SizedBox(height: isPreview ? 3 : 12),
									Text(
										invoice.note ?? '',
										style: TextStyle(fontSize: isPreview ? 3 : 16, height: 1.6, color: Colors.black87),
									),
								],
							),
						),
					],

					SizedBox(height: isPreview ? 15 : 60),
					Center(
						child: Text(
							'Powered by Billora - Minimal. Professional. Effective.',
							style: TextStyle(
								color: Colors.black38,
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

	// Template 3: Minimal Clean (Proforma, Credit/Debit notes)
	static Widget minimalClean(BuildContext context, Invoice invoice, {bool isPreview = false}) {
		final companyOrShopName = invoice.items.isNotEmpty ? invoice.items.first.companyOrShopName ?? '' : '';
		final template = Container(
			color: Colors.white,
			padding: EdgeInsets.all(isPreview ? 15 : 50),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Ultra minimal header
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										companyOrShopName.isNotEmpty ? companyOrShopName : _getInvoiceTypeTitle(invoice.templateId ?? '').toUpperCase(),
										style: TextStyle(
											fontSize: isPreview ? 8 : 32,
											fontWeight: FontWeight.w100,
											letterSpacing: 4,
											color: Colors.black,
										),
									),
									SizedBox(height: isPreview ? 2 : 8),
									Text(
										'#${invoice.id}',
										style: TextStyle(
											fontSize: isPreview ? 4 : 16,
											color: Colors.black54,
											fontWeight: FontWeight.w300,
										),
									),
								],
							),
							
							// QR Code positioned elegantly
							Column(
								children: [
									Container(
										padding: EdgeInsets.all(isPreview ? 2 : 8),
										decoration: BoxDecoration(
											border: Border.all(color: Colors.black, width: 1),
										),
										child: CompactQRCodeWidget(
											invoice: invoice,
											size: isPreview ? 25.0 : 80.0,
											color: Colors.black,
											showBackground: false,
										),
									),
									SizedBox(height: isPreview ? 1 : 4),
									Container(
										padding: EdgeInsets.symmetric(
											horizontal: isPreview ? 4 : 16, 
											vertical: isPreview ? 2 : 8
										),
										decoration: BoxDecoration(
											border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
										),
										child: Text(
											invoice.status.name.toUpperCase(),
											style: TextStyle(
												fontWeight: FontWeight.w500,
												letterSpacing: 1,
												fontSize: isPreview ? 2 : 12,
												color: Colors.black,
											),
										),
									),
								],
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
											'BILL TO',
											style: TextStyle(
												fontSize: isPreview ? 3 : 12,
												fontWeight: FontWeight.w600,
												color: Colors.black54,
												letterSpacing: 2,
											),
										),
										SizedBox(height: isPreview ? 4 : 16),
										Text(
											invoice.customerName,
											style: TextStyle(
												fontSize: isPreview ? 6 : 24,
												fontWeight: FontWeight.w400,
												color: Colors.black,
											),
										),
										SizedBox(height: isPreview ? 2 : 8),
										Text(
											'Customer Address\nCity, State ZIP\nCountry',
											style: TextStyle(
												fontSize: isPreview ? 3 : 14,
												color: Colors.black54,
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
										_buildMinimalInfoRow('DATE', _formatDate(invoice.createdAt), isPreview),
										SizedBox(height: isPreview ? 4 : 16),
										if (invoice.dueDate != null)
											_buildMinimalInfoRow('DUE DATE', _formatDate(invoice.dueDate!), isPreview),
										SizedBox(height: isPreview ? 4 : 16),
										_buildMinimalInfoRow('TERMS', 'Net 30', isPreview),
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
										top: BorderSide(color: Colors.black, width: 2),
										bottom: BorderSide(color: Colors.black, width: 1),
									),
								),
								child: Row(
									children: [
										Expanded(flex: 3, child: Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 12, letterSpacing: 1, color: Colors.black))),
										Expanded(child: Text('QTY', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 12, letterSpacing: 1, color: Colors.black), textAlign: TextAlign.center)),
										Expanded(child: Text('RATE', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 12, letterSpacing: 1, color: Colors.black), textAlign: TextAlign.center)),
										Expanded(child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 12, letterSpacing: 1, color: Colors.black), textAlign: TextAlign.center)),
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
															color: Colors.black,
														),
													),
													if (item.description != null) ...[
														SizedBox(height: isPreview ? 1 : 4),
														Text(
															item.description ?? '',
															style: TextStyle(
																color: Colors.black54,
																fontSize: isPreview ? 2 : 14,
															),
														),
													],
												],
											),
										),
										Expanded(
											child: Text(
												item.quantity.toString(),
												textAlign: TextAlign.center,
												style: TextStyle(fontSize: isPreview ? 4 : 16, color: Colors.black),
											),
										),
										Expanded(
											child: Text(
												'\$${item.unitPrice.toStringAsFixed(2)}',
												textAlign: TextAlign.center,
												style: TextStyle(fontSize: isPreview ? 4 : 16, color: Colors.black),
											),
										),
										Expanded(
											child: Text(
												'\$${item.total.toStringAsFixed(2)}',
												textAlign: TextAlign.center,
												style: TextStyle(
													fontWeight: FontWeight.w600,
													fontSize: isPreview ? 4 : 16,
													color: Colors.black,
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
									_buildMinimalTotalRow('SUBTOTAL', invoice.subtotal, isPreview),
									SizedBox(height: isPreview ? 3 : 12),
									_buildMinimalTotalRow('TAX', invoice.tax, isPreview),
									SizedBox(height: isPreview ? 5 : 20),
									Container(
										padding: EdgeInsets.symmetric(
											horizontal: isPreview ? 6 : 24, 
											vertical: isPreview ? 4 : 16
										),
										decoration: BoxDecoration(
											border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
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
														color: Colors.black,
													),
												),
												SizedBox(width: isPreview ? 5 : 32),
												Text(
													'\$${invoice.total.toStringAsFixed(2)}',
													style: TextStyle(
														fontSize: isPreview ? 4 : 20,
														fontWeight: FontWeight.w600,
														color: Colors.black,
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
								border: Border.all(color: Colors.black),
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text('NOTES', style: TextStyle(fontSize: isPreview ? 3 : 12, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 2)),
									SizedBox(height: isPreview ? 2 : 12),
									Text(invoice.note ?? '', style: TextStyle(fontSize: isPreview ? 3 : 16, height: 1.6, color: Colors.black87)),
								],
							),
						),
					],

					SizedBox(height: isPreview ? 10 : 40),
					Center(
						child: Text(
							'Powered by Billora - Minimal. Professional. Effective.',
							style: TextStyle(color: Colors.black45, fontSize: isPreview ? 2 : 12, letterSpacing: 1),
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
			padding: EdgeInsets.all(isPreview ? 12 : 40),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Corporate header
					Container(
						width: double.infinity,
						padding: EdgeInsets.all(isPreview ? 8 : 30),
						decoration: BoxDecoration(
							border: Border.all(color: Colors.black, width: isPreview ? 1 : 3),
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
												fontSize: isPreview ? 6 : 22,
												fontWeight: FontWeight.w700,
												color: Colors.black,
												letterSpacing: 1,
											),
										),
										SizedBox(height: isPreview ? 2 : 8),
										Text(
											_getInvoiceTypeTitle(invoice.templateId ?? ''),
											style: TextStyle(
												fontSize: isPreview ? 4 : 16,
												color: Colors.black87,
												fontWeight: FontWeight.w500,
											),
										),
										Text(
											'Document #${invoice.id}',
											style: TextStyle(
												fontSize: isPreview ? 3 : 14,
												color: Colors.black54,
											),
										),
									],
								),
								
								// QR Code and status
								Column(
									crossAxisAlignment: CrossAxisAlignment.end,
									children: [
										Container(
											padding: EdgeInsets.symmetric(
												horizontal: isPreview ? 4 : 16, 
												vertical: isPreview ? 2 : 8
											),
											color: Colors.black,
											child: Text(
												invoice.status.name.toUpperCase(),
												style: TextStyle(
													color: Colors.white,
													fontWeight: FontWeight.w600,
													fontSize: isPreview ? 3 : 12,
													letterSpacing: 1,
												),
											),
										),
										SizedBox(height: isPreview ? 3 : 12),
										CompactQRCodeWidget(
											invoice: invoice,
											size: isPreview ? 25.0 : 80.0,
											color: Colors.black,
											showBackground: true,
										),
									],
								),
							],
						),
					),
					
					SizedBox(height: isPreview ? 10 : 40),

					// Corporate info grid
					Row(
						children: [
							Expanded(
								child: Container(
									padding: EdgeInsets.all(isPreview ? 5 : 20),
									decoration: BoxDecoration(
										border: Border.all(color: Colors.black, width: 1),
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'RECIPIENT',
												style: TextStyle(
													fontSize: isPreview ? 3 : 12,
													fontWeight: FontWeight.w700,
													color: Colors.black,
													letterSpacing: 1,
												),
											),
											SizedBox(height: isPreview ? 2 : 8),
											Text(
												invoice.customerName,
												style: TextStyle(
													fontSize: isPreview ? 4 : 18,
													fontWeight: FontWeight.w600,
													color: Colors.black,
												),
											),
											SizedBox(height: isPreview ? 1 : 4),
											Text(
												'Department/Division\nInternal Code: INT-001',
												style: TextStyle(
													fontSize: isPreview ? 2 : 12,
													color: Colors.black54,
												),
											),
										],
									),
								),
							),
							SizedBox(width: isPreview ? 5 : 20),
							Expanded(
								child: Container(
									padding: EdgeInsets.all(isPreview ? 5 : 20),
									decoration: BoxDecoration(
										border: Border.all(color: Colors.black, width: 1),
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'DOCUMENT DATE',
												style: TextStyle(
													fontSize: isPreview ? 3 : 12,
													fontWeight: FontWeight.w700,
													color: Colors.black,
													letterSpacing: 1,
												),
											),
											SizedBox(height: isPreview ? 2 : 8),
											Text(
												_formatDate(invoice.createdAt),
												style: TextStyle(
													fontSize: isPreview ? 4 : 16,
													fontWeight: FontWeight.w500,
													color: Colors.black,
												),
											),
											SizedBox(height: isPreview ? 1 : 4),
											Text(
												'Fiscal Year: 2025\nQuarter: Q1',
												style: TextStyle(
													fontSize: isPreview ? 2 : 12,
													color: Colors.black54,
												),
											),
										],
									),
								),
							),
							SizedBox(width: isPreview ? 5 : 20),
							Expanded(
								child: Container(
									padding: EdgeInsets.all(isPreview ? 5 : 20),
									decoration: BoxDecoration(
										border: Border.all(color: Colors.black, width: 1),
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'AUTHORIZATION',
												style: TextStyle(
													fontSize: isPreview ? 3 : 12,
													fontWeight: FontWeight.w700,
													color: Colors.black,
													letterSpacing: 1,
												),
											),
											SizedBox(height: isPreview ? 2 : 8),
											Text(
												'APPROVED',
												style: TextStyle(
													fontSize: isPreview ? 4 : 16,
													fontWeight: FontWeight.w600,
													color: Colors.black,
												),
											),
											SizedBox(height: isPreview ? 1 : 4),
											Text(
												'Manager: J. Smith\nRef: AUTH-2025-001',
												style: TextStyle(
													fontSize: isPreview ? 2 : 12,
													color: Colors.black54,
												),
											),
										],
									),
								),
							),
						],
					),
					
					SizedBox(height: isPreview ? 10 : 40),

					// Corporate table
					Container(
						decoration: BoxDecoration(
							border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
						),
						child: Column(
							children: [
								Container(
									padding: EdgeInsets.all(isPreview ? 4 : 16),
									color: Colors.black,
									child: Row(
										children: [
											Expanded(flex: 4, child: Text('ITEM DESCRIPTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: isPreview ? 3 : 14))),
											Expanded(child: Text('QTY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: isPreview ? 3 : 14), textAlign: TextAlign.center)),
											Expanded(child: Text('UNIT COST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: isPreview ? 3 : 14), textAlign: TextAlign.center)),
											Expanded(child: Text('TOTAL COST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: isPreview ? 3 : 14), textAlign: TextAlign.center)),
										],
									),
								),
								...invoice.items.asMap().entries.map((entry) {
									final index = entry.key;
									final item = entry.value;
									return Container(
										padding: EdgeInsets.all(isPreview ? 4 : 16),
										decoration: BoxDecoration(
											color: index.isEven ? Colors.grey[100] : Colors.white,
											border: Border(top: BorderSide(color: Colors.black, width: 1)),
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
																style: TextStyle(
																	fontWeight: FontWeight.w600,
																	fontSize: isPreview ? 3 : 14,
																	color: Colors.black,
																),
															),
															if (item.description != null) ...[
																SizedBox(height: isPreview ? 1 : 4),
																Text(
																	item.description ?? '',
																	style: TextStyle(color: Colors.black54, fontSize: isPreview ? 2 : 12),
																),
															],
														],
													),
												),
												Expanded(child: Text(item.quantity.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black))),
												Expanded(child: Text('\$${item.unitPrice.toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black))),
												Expanded(child: Text('\$${item.total.toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: isPreview ? 3 : 14, color: Colors.black))),
											],
										),
									);
								}),
							],
						),
					),
					
					SizedBox(height: isPreview ? 8 : 32),

					// Corporate summary
					Row(
						mainAxisAlignment: MainAxisAlignment.end,
						children: [
							Container(
								width: isPreview ? 120 : 400,
								decoration: BoxDecoration(
									border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
								),
								child: Column(
									children: [
										Container(
											padding: EdgeInsets.all(isPreview ? 3 : 12),
											color: Colors.black,
											width: double.infinity,
											child: Text(
												'FINANCIAL SUMMARY', 
												style: TextStyle(
													color: Colors.white, 
													fontWeight: FontWeight.w700, 
													fontSize: isPreview ? 3 : 14,
													letterSpacing: 1,
												),
												textAlign: TextAlign.center,
											),
										),
										Padding(
											padding: EdgeInsets.all(isPreview ? 6 : 20),
											child: Column(
												children: [
													_buildCorporateRow('Net Amount:', invoice.subtotal, isPreview),
													SizedBox(height: isPreview ? 2 : 8),
													_buildCorporateRow('Tax Amount:', invoice.tax, isPreview),
													SizedBox(height: isPreview ? 2 : 8),
													_buildCorporateRow('Processing Fee:', 0.00, isPreview),
													SizedBox(height: isPreview ? 3 : 12),
													Container(
														padding: EdgeInsets.symmetric(vertical: isPreview ? 2 : 8),
														decoration: BoxDecoration(
															border: Border(top: BorderSide(color: Colors.black, width: isPreview ? 1 : 2)),
														),
														child: Row(
															mainAxisAlignment: MainAxisAlignment.spaceBetween,
															children: [
																Text(
																	'TOTAL AMOUNT:', 
																	style: TextStyle(
																		fontSize: isPreview ? 4 : 16, 
																		fontWeight: FontWeight.w700,
																		color: Colors.black,
																	),
																),
																Text(
																	'\$${invoice.total.toStringAsFixed(2)}', 
																	style: TextStyle(
																		fontSize: isPreview ? 4 : 16, 
																		fontWeight: FontWeight.w700,
																		color: Colors.black,
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
							),
						],
					),
					
					if (invoice.note != null && invoice.note!.isNotEmpty) ...[
						SizedBox(height: isPreview ? 8 : 32),
						Container(
							padding: EdgeInsets.all(isPreview ? 6 : 20),
							decoration: BoxDecoration(
								border: Border.all(color: Colors.black, width: 1),
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'INTERNAL NOTES',
										style: TextStyle(
											fontSize: isPreview ? 3 : 12,
											fontWeight: FontWeight.w700,
											color: Colors.black,
											letterSpacing: 1,
										),
									),
									SizedBox(height: isPreview ? 2 : 8),
									Text(
										invoice.note ?? '',
										style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black87),
									),
								],
							),
						),
					],
					
					SizedBox(height: isPreview ? 8 : 32),
					Container(
						padding: EdgeInsets.all(isPreview ? 6 : 20),
						color: Colors.black,
						child: Center(
							child: Text(
								'Enterprise Solution by Billora - Streamlining Corporate Operations',
								style: TextStyle(
									color: Colors.white,
									fontSize: isPreview ? 2 : 12,
									fontWeight: FontWeight.w500,
								),
							),
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
			padding: EdgeInsets.all(isPreview ? 12 : 40),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Service header
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								flex: 2,
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											children: [
												Container(
													width: isPreview ? 3 : 12,
													height: isPreview ? 8 : 30,
													color: Colors.black,
												),
												SizedBox(width: isPreview ? 3 : 12),
												Expanded(
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																companyOrShopName.isNotEmpty ? companyOrShopName : 'SERVICE PROVIDER',
																style: TextStyle(
																	fontSize: isPreview ? 7 : 26,
																	fontWeight: FontWeight.w700,
																	color: Colors.black,
																	letterSpacing: 1,
																),
															),
															SizedBox(height: isPreview ? 2 : 8),
															Text(
																_getInvoiceTypeTitle(invoice.templateId ?? ''),
																style: TextStyle(
																	fontSize: isPreview ? 4 : 16,
																	color: Colors.black87,
																	fontWeight: FontWeight.w500,
																),
															),
														],
													),
												),
											],
										),
										SizedBox(height: isPreview ? 2 : 8),
										Text(
											'Service ID: #${invoice.id}',
											style: TextStyle(
												fontSize: isPreview ? 3 : 14,
												color: Colors.black54,
											),
										),
									],
								),
							),
							
							// Status and QR
							Column(
								crossAxisAlignment: CrossAxisAlignment.end,
								children: [
									Container(
										padding: EdgeInsets.symmetric(
											horizontal: isPreview ? 5 : 20, 
											vertical: isPreview ? 3 : 12
										),
										decoration: BoxDecoration(
											border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
										),
										child: Text(
											invoice.status.name.toUpperCase(),
											style: TextStyle(
												color: Colors.black,
												fontWeight: FontWeight.w600,
												fontSize: isPreview ? 3 : 12,
												letterSpacing: 1,
											),
										),
									),
									SizedBox(height: isPreview ? 4 : 16),
									Container(
										padding: EdgeInsets.all(isPreview ? 2 : 8),
										decoration: BoxDecoration(
											border: Border.all(color: Colors.black, width: 1),
										),
										child: CompactQRCodeWidget(
											invoice: invoice,
											size: isPreview ? 22.0 : 70.0,
											color: Colors.black,
											showBackground: false,
										),
									),
									SizedBox(height: isPreview ? 2 : 8),
									Text(
										'24/7 Support Available',
										style: TextStyle(
											color: Colors.black54,
											fontSize: isPreview ? 2 : 10,
										),
									),
								],
							),
						],
					),
					
					SizedBox(height: isPreview ? 10 : 40),

					// Service info
					Row(
						children: [
							Expanded(
								flex: 2,
								child: Container(
									padding: EdgeInsets.all(isPreview ? 6 : 24),
									decoration: BoxDecoration(
										border: Border.all(color: Colors.black, width: 1),
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'CLIENT INFORMATION',
												style: TextStyle(
													fontSize: isPreview ? 3 : 12,
													fontWeight: FontWeight.w700,
													color: Colors.black,
													letterSpacing: 1,
												),
											),
											SizedBox(height: isPreview ? 4 : 16),
											Text(
												invoice.customerName,
												style: TextStyle(
													fontSize: isPreview ? 5 : 20,
													fontWeight: FontWeight.w600,
													color: Colors.black,
												),
											),
											SizedBox(height: isPreview ? 2 : 8),
											Text(
												'Client ID: CLI-${invoice.customerName.hashCode.abs().toString().substring(0, 4)}\nService Level: Premium\nAccount Manager: Sarah Johnson',
												style: TextStyle(
													fontSize: isPreview ? 2 : 12,
													color: Colors.black54,
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
												border: Border.all(color: Colors.black, width: 1),
											),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text('SERVICE PERIOD', style: TextStyle(fontSize: isPreview ? 3 : 12, fontWeight: FontWeight.w700, color: Colors.black)),
													SizedBox(height: isPreview ? 2 : 8),
													Text(_formatDate(invoice.createdAt), style: TextStyle(fontSize: isPreview ? 4 : 16, fontWeight: FontWeight.w600, color: Colors.black)),
												],
											),
										),
										SizedBox(height: isPreview ? 5 : 16),
										Container(
											padding: EdgeInsets.all(isPreview ? 4 : 16),
											decoration: BoxDecoration(
												border: Border.all(color: Colors.black, width: 1),
											),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text('TOTAL HOURS', style: TextStyle(fontSize: isPreview ? 3 : 12, fontWeight: FontWeight.w700, color: Colors.black)),
													SizedBox(height: isPreview ? 2 : 8),
													Text('${invoice.items.fold(0.0, (sum, item) => sum + item.quantity)} hrs', style: TextStyle(fontSize: isPreview ? 4 : 16, fontWeight: FontWeight.w600, color: Colors.black)),
												],
											),
										),
									],
								),
							),
						],
					),
					
					SizedBox(height: isPreview ? 10 : 40),

					// Service items table
					Container(
						decoration: BoxDecoration(
							border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
						),
						child: Column(
							children: [
								Container(
									color: Colors.black,
									padding: EdgeInsets.all(isPreview ? 4 : 16),
									child: Row(
										children: [
											Expanded(flex: 3, child: Text('SERVICE DESCRIPTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 14))),
											Expanded(child: Text('HOURS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 14), textAlign: TextAlign.center)),
											Expanded(child: Text('RATE/HR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 14), textAlign: TextAlign.center)),
											Expanded(child: Text('SUBTOTAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 14), textAlign: TextAlign.center)),
										],
									),
								),
								...invoice.items.asMap().entries.map((entry) {
									final index = entry.key;
									final item = entry.value;
									return Container(
										padding: EdgeInsets.all(isPreview ? 4 : 16),
										decoration: BoxDecoration(
											color: index.isEven ? Colors.grey[50] : Colors.white,
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
																	Container(width: isPreview ? 1 : 4, height: isPreview ? 1 : 4, color: Colors.black),
																	SizedBox(width: isPreview ? 2 : 8),
																	Expanded(
																		child: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isPreview ? 3 : 14, color: Colors.black)),
																	),
																],
															),
															if (item.description != null) ...[
																SizedBox(height: isPreview ? 1 : 4),
																Padding(
																	padding: EdgeInsets.only(left: isPreview ? 4 : 16),
																	child: Text(item.description ?? '', style: TextStyle(color: Colors.black54, fontSize: isPreview ? 2 : 12)),
																),
															],
														],
													),
												),
												Expanded(child: Text('${item.quantity}h', textAlign: TextAlign.center, style: TextStyle(fontSize: isPreview ? 3 : 14, fontWeight: FontWeight.w500, color: Colors.black))),
												Expanded(child: Text('\$${item.unitPrice.toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(fontSize: isPreview ? 3 : 14, fontWeight: FontWeight.w500, color: Colors.black))),
												Expanded(child: Text('\$${item.total.toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: isPreview ? 3 : 14, color: Colors.black))),
											],
										),
									);
								}),
							],
						),
					),
					
					SizedBox(height: isPreview ? 8 : 32),

					// Service totals
					Row(
						mainAxisAlignment: MainAxisAlignment.end,
						children: [
							Container(
								padding: EdgeInsets.all(isPreview ? 6 : 24),
								color: Colors.black,
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.end,
									children: [
										Text('SERVICE TOTAL', style: TextStyle(color: Colors.white, fontSize: isPreview ? 3 : 14, fontWeight: FontWeight.w600, letterSpacing: 1)),
										SizedBox(height: isPreview ? 2 : 12),
										Text('\$${invoice.total.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: isPreview ? 6 : 28, fontWeight: FontWeight.w800)),
										SizedBox(height: isPreview ? 2 : 8),
										Text('Net: \$${invoice.subtotal.toStringAsFixed(2)} + Tax: \$${invoice.tax.toStringAsFixed(2)}', style: TextStyle(color: Colors.white70, fontSize: isPreview ? 2 : 12)),
									],
								),
							),
						],
					),

					if (invoice.note != null && invoice.note!.isNotEmpty) ...[
						SizedBox(height: isPreview ? 8 : 32),
						Container(
							padding: EdgeInsets.all(isPreview ? 6 : 20),
							decoration: BoxDecoration(
								border: Border.all(color: Colors.black, width: 1),
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text('SERVICE NOTES', style: TextStyle(fontSize: isPreview ? 3 : 12, fontWeight: FontWeight.w700, color: Colors.black)),
									SizedBox(height: isPreview ? 2 : 8),
									Text(invoice.note ?? '', style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black87)),
								],
							),
						),
					],
					
					SizedBox(height: isPreview ? 8 : 32),
					Container(
						padding: EdgeInsets.symmetric(vertical: isPreview ? 3 : 12),
						decoration: const BoxDecoration(
							border: Border(top: BorderSide(color: Colors.black, width: 1)),
						),
						child: Center(
							child: Text(
								'Powered by Billora - Excellence in Service Management',
								style: TextStyle(color: Colors.black54, fontSize: isPreview ? 2 : 12),
							),
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
			padding: EdgeInsets.all(isPreview ? 10 : 32),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					// Receipt header
					Container(
						width: double.infinity,
						padding: EdgeInsets.all(isPreview ? 6 : 20),
						decoration: BoxDecoration(
							border: Border.all(color: Colors.black, width: isPreview ? 1 : 2),
						),
						child: Column(
							children: [
								Text(
									companyOrShopName.isNotEmpty ? companyOrShopName : 'OFFICIAL RECEIPT',
									style: TextStyle(
										fontSize: isPreview ? 6 : 20,
										fontWeight: FontWeight.w700,
										color: Colors.black,
									),
								),
								SizedBox(height: isPreview ? 2 : 8),
								Text(
									_getInvoiceTypeTitle(invoice.templateId ?? ''),
									style: TextStyle(
										fontSize: isPreview ? 3 : 14,
										color: Colors.black87,
									),
								),
								Text(
									'Receipt #${invoice.id}',
									style: TextStyle(
										fontSize: isPreview ? 2 : 12,
										color: Colors.black54,
									),
								),
							],
						),
					),
					SizedBox(height: isPreview ? 6 : 24),

					// Receipt details
					Container(
						width: double.infinity,
						padding: EdgeInsets.all(isPreview ? 6 : 20),
						decoration: BoxDecoration(
							border: Border.all(color: Colors.black, width: 1),
						),
						child: Column(
							children: [
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text('RECEIVED FROM:', style: TextStyle(fontSize: isPreview ? 3 : 12, fontWeight: FontWeight.w700, color: Colors.black)),
										Text(invoice.customerName, style: TextStyle(fontSize: isPreview ? 3 : 14, fontWeight: FontWeight.w700, color: Colors.black)),
									],
								),
								SizedBox(height: isPreview ? 2 : 12),
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text('DATE:', style: TextStyle(fontSize: isPreview ? 3 : 12, fontWeight: FontWeight.w700, color: Colors.black)),
										Text(_formatDate(invoice.createdAt), style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black)),
									],
								),
								SizedBox(height: isPreview ? 2 : 12),
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text('PAYMENT METHOD:', style: TextStyle(fontSize: isPreview ? 3 : 12, fontWeight: FontWeight.w700, color: Colors.black)),
										Text('Cash/Card', style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black)),
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
							border: Border.all(color: Colors.black, width: 1),
						),
						child: Column(
							children: [
								Container(
									padding: EdgeInsets.all(isPreview ? 4 : 12),
									color: Colors.black12,
									child: Row(
										children: [
											Expanded(flex: 2, child: Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.w700, fontSize: isPreview ? 3 : 12, color: Colors.black))),
											Expanded(child: Text('QTY', style: TextStyle(fontWeight: FontWeight.w700, fontSize: isPreview ? 3 : 12, color: Colors.black), textAlign: TextAlign.center)),
											Expanded(child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.w700, fontSize: isPreview ? 3 : 12, color: Colors.black), textAlign: TextAlign.center)),
										],
									),
								),
								...invoice.items.map((item) => Container(
									padding: EdgeInsets.all(isPreview ? 4 : 12),
									decoration: const BoxDecoration(
										border: Border(top: BorderSide(color: Colors.black12)),
									),
									child: Row(
										children: [
											Expanded(flex: 2, child: Text(item.name, style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black))),
											Expanded(child: Text(item.quantity.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black))),
											Expanded(child: Text('\$${item.total.toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(fontSize: isPreview ? 3 : 14, fontWeight: FontWeight.w700, color: Colors.black))),
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
						padding: EdgeInsets.all(isPreview ? 6 : 20),
						decoration: BoxDecoration(
							border: Border.all(color: Colors.black, width: 1),
						),
						child: Column(
							children: [
								if (invoice.tax > 0) ...[
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											Text('Subtotal:', style: TextStyle(color: Colors.black, fontSize: isPreview ? 3 : 14)),
											Text('\$${invoice.subtotal.toStringAsFixed(2)}', style: TextStyle(color: Colors.black, fontSize: isPreview ? 3 : 14)),
										],
									),
									SizedBox(height: isPreview ? 2 : 8),
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											Text('Tax:', style: TextStyle(color: Colors.black, fontSize: isPreview ? 3 : 14)),
											Text('\$${invoice.tax.toStringAsFixed(2)}', style: TextStyle(color: Colors.black, fontSize: isPreview ? 3 : 14)),
										],
									),
									SizedBox(height: isPreview ? 2 : 12),
								],
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text('TOTAL PAID:', style: TextStyle(color: Colors.black, fontSize: isPreview ? 4 : 18, fontWeight: FontWeight.w700)),
										Text('\$${invoice.total.toStringAsFixed(2)}', style: TextStyle(color: Colors.black, fontSize: isPreview ? 4 : 18, fontWeight: FontWeight.w700)),
									],
								),
							],
						),
					),

					if (invoice.note != null && invoice.note!.isNotEmpty) ...[
						SizedBox(height: isPreview ? 4 : 16),
						Container(
							width: double.infinity,
							padding: EdgeInsets.all(isPreview ? 4 : 12),
							decoration: BoxDecoration(
								border: Border.all(color: Colors.black, width: 1),
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text('NOTES:', style: TextStyle(fontSize: isPreview ? 3 : 12, fontWeight: FontWeight.w700, color: Colors.black)),
									SizedBox(height: isPreview ? 1 : 4),
									Text(invoice.note ?? '', style: TextStyle(fontSize: isPreview ? 3 : 12, color: Colors.black87)),
								],
							),
						),
					],

					SizedBox(height: isPreview ? 5 : 20),
					Text('PAYMENT RECEIVED - THANK YOU', style: TextStyle(fontSize: isPreview ? 3 : 14, fontWeight: FontWeight.w700, color: Colors.black87)),
					SizedBox(height: isPreview ? 2 : 8),
					Text('Transaction ID: TXN-${invoice.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', style: TextStyle(fontSize: isPreview ? 2 : 10, color: Colors.black54)),
					SizedBox(height: isPreview ? 2 : 8),
					Text('Powered by Billora - Simple & Secure Receipts', style: TextStyle(color: Colors.black45, fontSize: isPreview ? 2 : 10)),
				],
			),
		);
		return _wrapForPreview(template, isPreview: isPreview);
	}

	// Helper methods

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

	static Widget _buildInfoRow(String label, String value, bool isPreview) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Flexible(
					flex: 0,
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: isPreview ? 60 : 120),
						child: Text(
							label,
							overflow: TextOverflow.ellipsis,
							softWrap: false,
							style: TextStyle(
								fontSize: isPreview ? 3 : 12,
								fontWeight: FontWeight.w700,
								color: Colors.black54,
							),
						),
					),
				),
				SizedBox(width: isPreview ? 4 : 8),
				Expanded(
					child: Text(
						value,
						style: TextStyle(
							fontSize: isPreview ? 3 : 14,
							fontWeight: FontWeight.w500,
							color: Colors.black,
						),
					),
				),
			],
		);
	}

	static Widget _buildTotalRow(String label, double amount, bool isPreview) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				Text(
					label,
					style: TextStyle(
						fontSize: isPreview ? 3 : 14,
						color: Colors.black54,
					),
				),
				Text(
					'\$${amount.toStringAsFixed(2)}',
					style: TextStyle(
						fontSize: isPreview ? 3 : 14,
						fontWeight: FontWeight.w600,
						color: Colors.black,
					),
				),
			],
		);
	}

	static Widget _buildMinimalInfoRow(String label, String value, bool isPreview) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.end,
			children: [
				Text(
					label,
					style: TextStyle(
						fontSize: isPreview ? 3 : 12,
						fontWeight: FontWeight.w600,
						color: Colors.black54,
						letterSpacing: 2,
					),
				),
				SizedBox(height: isPreview ? 2 : 4),
				Text(
					value,
					style: TextStyle(
						fontSize: isPreview ? 4 : 16,
						fontWeight: FontWeight.w400,
						color: Colors.black,
					),
				),
			],
		);
	}

	static Widget _buildMinimalTotalRow(String label, double amount, bool isPreview) {
		return Row(
			mainAxisSize: MainAxisSize.min,
			children: [
				SizedBox(
					width: isPreview ? 80 : 140,
					child: Text(
						label,
						style: TextStyle(
							fontSize: isPreview ? 3 : 14,
							color: Colors.black54,
						),
					),
				),
				SizedBox(width: isPreview ? 8 : 20),
				Text(
					'\$${amount.toStringAsFixed(2)}',
					style: TextStyle(
						fontSize: isPreview ? 3 : 14,
						fontWeight: FontWeight.w600,
						color: Colors.black,
					),
				),
			],
		);
	}

	static Widget _buildCorporateRow(String label, double amount, bool isPreview) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				Text(label, style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black54)),
				Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: isPreview ? 3 : 14, color: Colors.black)),
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