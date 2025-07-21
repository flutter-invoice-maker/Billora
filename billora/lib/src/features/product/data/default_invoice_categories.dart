const List<Map<String, String>> defaultInvoiceCategories = [
  // Quốc tế
  {'key': 'commercial_invoice', 'en': 'Commercial Invoice', 'vi': 'Hóa đơn thương mại'},
  {'key': 'proforma_invoice', 'en': 'Proforma Invoice', 'vi': 'Hóa đơn tạm tính'},
  {'key': 'tax_invoice', 'en': 'Tax Invoice', 'vi': 'Hóa đơn thuế'},
  {'key': 'electronic_invoice', 'en': 'Electronic Invoice', 'vi': 'Hóa đơn điện tử'},
  {'key': 'credit_note', 'en': 'Credit Note', 'vi': 'Giấy ghi có'},
  {'key': 'debit_note', 'en': 'Debit Note', 'vi': 'Giấy ghi nợ'},
  {'key': 'self_billing_invoice', 'en': 'Self-Billing Invoice', 'vi': 'Hóa đơn tự lập'},
  {'key': 'timesheet_invoice', 'en': 'Timesheet Invoice', 'vi': 'Hóa đơn tính giờ'},
  // Việt Nam
  {'key': 'vat_invoice', 'en': 'VAT Invoice', 'vi': 'Hóa đơn giá trị gia tăng'},
  {'key': 'sales_invoice', 'en': 'Sales Invoice', 'vi': 'Hóa đơn bán hàng'},
  {'key': 'internal_transfer', 'en': 'Internal Transfer Note', 'vi': 'Phiếu xuất kho kiêm vận chuyển nội bộ'},
  {'key': 'consignment', 'en': 'Consignment Note', 'vi': 'Phiếu xuất kho gửi bán đại lý'},
  {'key': 'stamp_ticket_card', 'en': 'Stamp/Ticket/Card', 'vi': 'Tem, vé, thẻ'},
  {'key': 'transport_receipt', 'en': 'Transport Receipt', 'vi': 'Phiếu thu tiền cước vận chuyển quốc tế'},
  {'key': 'bank_fee', 'en': 'Bank Fee Receipt', 'vi': 'Chứng từ thu phí dịch vụ ngân hàng'},
];

const List<Map<String, String>> defaultInvoiceFormats = [
  {'key': 'E', 'en': 'Electronic Invoice (E)', 'vi': 'Hóa đơn điện tử (E)'},
  {'key': 'T', 'en': 'Self-Printed Invoice (T)', 'vi': 'Hóa đơn tự in (T)'},
  {'key': 'P', 'en': 'Pre-Printed Invoice (P)', 'vi': 'Hóa đơn đặt in (P)'},
  {'key': 'EC', 'en': 'E-invoice with Code (EC)', 'vi': 'Hóa đơn điện tử có mã (EC)'},
  {'key': 'EB', 'en': 'E-invoice without Code (EB)', 'vi': 'Hóa đơn điện tử không mã (EB)'},
]; 