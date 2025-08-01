import 'package:flutter/material.dart';

class LocalizationHelper {
  static LocalizationHelper of(BuildContext context) {
    return LocalizationHelper();
  }
  
  String get dashboard => 'Dashboard';
  
  static String getLocalizedString(BuildContext context, String key) {
    // Get current locale
    final locale = Localizations.localeOf(context);
    final isVietnamese = locale.languageCode == 'vi';
    
    // Define translations
    final translations = {
      'en': {
        'homeTitle': 'Home',
        'productMenu': 'Products',
        'invoiceListTitle': 'Invoices',
        'logout': 'Logout',
        'invoiceAddTitle': 'Add Invoice',
        'invoiceEditTitle': 'Edit Invoice',
        'invoiceSave': 'Save',
        'invoiceUpdate': 'Update',
        'invoiceCreateSampleProducts': 'Create Sample Products',
        'customerName': 'Customer Name',
        'customerNameRequired': 'Please enter a name',
        'invoiceItems': 'Items',
        'productPrice': 'Price',
        'productTax': 'Tax',
        'productInventory': 'Inventory',
        'invoiceSubtotal': 'Subtotal',
        'invoiceTax': 'Tax',
        'invoiceTotal': 'Total',
        'invoiceNote': 'Note',
        'invoiceDueDate': 'Due Date',
        'invoiceSelectDate': 'Select date',
        'invoiceDraft': 'Draft',
        'invoicePaid': 'Paid',
        'invoiceOverdue': 'Overdue',
        'invoiceCancelled': 'Cancelled',
        'invoiceSelectedItems': 'Selected Items',
        'invoiceNoItemsSelected': 'No items selected',
        'invoiceQuantity': 'Quantity',
        'invoiceUnitPrice': 'Unit Price',
        'invoiceItemTotal': 'Item Total',
        'invoiceRemoveItem': 'Remove Item',
        'invoiceSmartRecommendations': 'Smart Recommendations',
        'invoiceBasedOnHistory': 'Based on customer purchase history',
        'invoiceLoadingRecommendations': 'Loading smart recommendations...',
        'invoiceNoRecommendations': 'No recommendations available',
        'invoiceTags': 'Tags',
        'invoiceAddTags': 'Add Tags',
        'invoiceFilterByTag': 'Filter by Tag',
        'invoiceAllTags': 'All Tags',
        'invoiceCreateNewTag': 'Create New Tag',
        'invoiceTagName': 'Tag Name',
        'invoiceTagColor': 'Tag Color',
        'invoiceCreateTag': 'Create Tag',
        'invoiceCancel': 'Cancel',
        'invoiceSuccess': 'Success',
        'invoiceError': 'Error',
        'invoiceInvoiceCreated': 'Invoice created!',
        'invoiceInvoiceUpdated': 'Invoice updated!',
        'invoiceErrorSaving': 'Error saving invoice',
        'invoiceProductNotFound': 'Product not found in product list',
        'invoiceAddedWithQuantity': 'Added {productName} (Qty: {quantity} from last invoice)',
        'pleaseSelectTemplate': 'Please select a template',
        'inventory': 'Inventory',
        'remove': 'Remove',
        'dueDate': 'Due Date',
        'selectDate': 'Select date',
        'status': 'Status',
        'note': 'Note',
        'template': 'Template',
        'searchProducts': 'Search products...',
        'searchProductsToAdd': 'Search products to add...',
        'selectColor': 'Select Color:',
        'deleteInvoice': 'Delete Invoice',
        'deleteInvoiceConfirm': 'Are you sure you want to delete this invoice?',
        'filterByTag': 'Filter by Tag',
        'allTags': 'All Tags',
        'noInvoicesYet': 'No invoices yet.',
        'noProductsFound': 'No products found',
        'noProductsAvailable': 'No products available',
        'searchInvoices': 'Search by customer or invoice ID',
        'invoiceStatusDraft': 'DRAFT',
        'invoiceStatusSent': 'SENT',
        'invoiceStatusPaid': 'PAID',
        'invoiceStatusOverdue': 'OVERDUE',
        'invoiceStatusCancelled': 'CANCELLED',
        'addTagsPlaceholder': 'Add tags to categorize this invoice...',
        'availableTags': 'Available tags:',
        'scanFeatureTitle': 'Invoice Scanning Feature',
        'scanFeatureMobileOnly': 'Only available on mobile application.',
        'scanFeatureUseMobile': 'Please use Android/iOS to scan invoices.',
        'billScanner': 'Scan & Upload Invoice',
        'scanInvoice': 'Scan Invoice',
        'uploadImage': 'Upload Image',
        'cameraPermission': 'Camera Permission',
        'cameraPermissionMessage': 'App needs camera access to scan invoices.',
        'cancel': 'Cancel',
        'settings': 'Settings',
        'ok': 'OK',
        'error': 'Error',
        'retry': 'Retry',
        'close': 'Close',
        'downloadPdf': 'Download PDF',
        'saveToDevice': 'Save to your device',
        'generatingPdf': 'Generating PDF...',
        'pdfReady': 'PDF ready for download!',
        'failedToGeneratePdf': 'Failed to generate PDF',
        'createShareableLink': 'Create Shareable Link',
        'uploadAndGetLink': 'Upload and get a link to share',
        'creatingLink': 'Creating shareable link...',
        'linkCreated': 'Shareable link created! Link copied to clipboard.',
        'failedToCreateLink': 'Failed to create link',
        'sendViaEmail': 'Send via Email',
        'sendingEmail': 'Sending email...',
        'emailSentSuccessfully': 'Email sent successfully to',
        'failedToSendEmail': 'Failed to send email',
        'sendInvoice': 'Send Invoice',
        'send': 'Send',
        'filterByStatus': 'Filter by Status',
        'allStatus': 'All Status',
        'confirmDeletion': 'Confirm Deletion',
        'processingInvoice': 'Processing Invoice',
        'startProcessing': 'Starting processing...',
        'scanningInvoice': 'Scanning invoice...',
        'processingData': 'Processing data...',
        'scanSuccessful': 'Scan successful!',
        'confidence': 'Confidence',
        'quantity': 'Quantity',
        'tryAgain': 'Try Again',
        'scanAgain': 'Scan Again',
        'confirmAndCreateInvoice': 'Confirm & Create Invoice',
        'editData': 'Edit Data',
        'saveAndContinue': 'Save & Continue',
        'selectImage': 'Select Image',
        'uploadInvoiceImage': 'Upload Invoice Image',
        'signInWithGoogle': 'Sign in with Google',
        'signInWithApple': 'Sign in with Apple',
        'registrationSuccess': 'Registration successful!',
        'email': 'Email',
        'phone': 'Phone',
        'address': 'Address',
        'due': 'Due',
        'noDueDate': 'No due date',
        'more': 'more',
        'preview': 'Preview',
        'sharePdf': 'Share PDF',
        'edit': 'Edit',
        'all': 'All',
      },
      'vi': {
        'homeTitle': 'Trang chủ',
        'productMenu': 'Sản phẩm',
        'invoiceListTitle': 'Hóa đơn',
        'logout': 'Đăng xuất',
        'invoiceAddTitle': 'Thêm hóa đơn',
        'invoiceEditTitle': 'Sửa hóa đơn',
        'invoiceSave': 'Lưu',
        'invoiceUpdate': 'Cập nhật',
        'invoiceCreateSampleProducts': 'Tạo sản phẩm mẫu',
        'customerName': 'Tên khách hàng',
        'customerNameRequired': 'Vui lòng nhập tên',
        'invoiceItems': 'Các mục',
        'productPrice': 'Giá',
        'productTax': 'Thuế',
        'productInventory': 'Tồn kho',
        'invoiceSubtotal': 'Tạm tính',
        'invoiceTax': 'Thuế',
        'invoiceTotal': 'Tổng tiền',
        'invoiceNote': 'Ghi chú',
        'invoiceDueDate': 'Ngày đến hạn',
        'invoiceSelectDate': 'Chọn ngày',
        'invoiceDraft': 'Nháp',
        'invoicePaid': 'Đã thanh toán',
        'invoiceOverdue': 'Quá hạn',
        'invoiceCancelled': 'Đã hủy',
        'invoiceSelectedItems': 'Sản phẩm đã chọn',
        'invoiceNoItemsSelected': 'Chưa chọn sản phẩm nào',
        'invoiceQuantity': 'Số lượng',
        'invoiceUnitPrice': 'Đơn giá',
        'invoiceItemTotal': 'Thành tiền',
        'invoiceRemoveItem': 'Xóa mục',
        'invoiceSmartRecommendations': 'Gợi ý thông minh',
        'invoiceBasedOnHistory': 'Dựa trên lịch sử mua hàng',
        'invoiceLoadingRecommendations': 'Đang tải gợi ý...',
        'invoiceNoRecommendations': 'Không có gợi ý',
        'invoiceTags': 'Nhãn',
        'invoiceAddTags': 'Thêm nhãn',
        'invoiceFilterByTag': 'Lọc theo nhãn',
        'invoiceAllTags': 'Tất cả nhãn',
        'invoiceCreateNewTag': 'Tạo nhãn mới',
        'invoiceTagName': 'Tên nhãn',
        'invoiceTagColor': 'Màu nhãn',
        'invoiceCreateTag': 'Tạo nhãn',
        'invoiceCancel': 'Hủy',
        'invoiceSuccess': 'Thành công',
        'invoiceError': 'Lỗi',
        'invoiceInvoiceCreated': 'Hóa đơn đã được tạo!',
        'invoiceInvoiceUpdated': 'Hóa đơn đã được cập nhật!',
        'invoiceErrorSaving': 'Lỗi khi lưu hóa đơn',
        'invoiceProductNotFound': 'Không tìm thấy sản phẩm trong danh sách',
        'invoiceAddedWithQuantity': 'Đã thêm {productName} (SL: {quantity} từ hóa đơn trước)',
        'pleaseSelectTemplate': 'Vui lòng chọn mẫu',
        'inventory': 'Tồn kho',
        'remove': 'Xóa',
        'dueDate': 'Ngày đến hạn',
        'selectDate': 'Chọn ngày',
        'status': 'Trạng thái',
        'note': 'Ghi chú',
        'template': 'Mẫu',
        'searchProducts': 'Tìm kiếm sản phẩm...',
        'searchProductsToAdd': 'Tìm kiếm sản phẩm để thêm...',
        'selectColor': 'Chọn màu:',
        'deleteInvoice': 'Xóa hóa đơn',
        'deleteInvoiceConfirm': 'Bạn có chắc chắn muốn xóa hóa đơn này không?',
        'filterByTag': 'Lọc theo nhãn',
        'allTags': 'Tất cả nhãn',
        'noInvoicesYet': 'Chưa có hóa đơn nào.',
        'noProductsFound': 'Không tìm thấy sản phẩm',
        'noProductsAvailable': 'Không có sản phẩm nào',
        'searchInvoices': 'Tìm kiếm theo tên khách hàng hoặc ID hóa đơn',
        'invoiceStatusDraft': 'NHÁP',
        'invoiceStatusSent': 'ĐÃ GỬI',
        'invoiceStatusPaid': 'ĐÃ THANH TOÁN',
        'invoiceStatusOverdue': 'QUÁ HẠN',
        'invoiceStatusCancelled': 'ĐÃ HỦY',
        'addTagsPlaceholder': 'Thêm nhãn để phân loại hóa đơn này...',
        'availableTags': 'Nhãn có sẵn:',
        'scanFeatureTitle': 'Tính năng Quét Hóa Đơn',
        'scanFeatureMobileOnly': 'Chỉ khả dụng trên ứng dụng mobile.',
        'scanFeatureUseMobile': 'Vui lòng sử dụng Android/iOS để quét hóa đơn.',
        'billScanner': 'Quét & Tải lên Hóa đơn',
        'scanInvoice': 'Quét Hóa đơn',
        'uploadImage': 'Tải lên Ảnh',
        'cameraPermission': 'Quyền Camera',
        'cameraPermissionMessage': 'Ứng dụng cần quyền camera để quét hóa đơn.',
        'cancel': 'Hủy',
        'settings': 'Cài đặt',
        'ok': 'Đồng ý',
        'error': 'Lỗi',
        'retry': 'Thử lại',
        'close': 'Đóng',
        'downloadPdf': 'Tải xuống PDF',
        'saveToDevice': 'Lưu vào thiết bị',
        'generatingPdf': 'Đang tạo PDF...',
        'pdfReady': 'PDF sẵn sàng để tải xuống!',
        'failedToGeneratePdf': 'Không thể tạo PDF',
        'createShareableLink': 'Tạo Liên kết Chia sẻ',
        'uploadAndGetLink': 'Tải lên và lấy liên kết để chia sẻ',
        'creatingLink': 'Đang tạo liên kết chia sẻ...',
        'linkCreated': 'Liên kết chia sẻ đã được tạo! Liên kết đã sao chép vào bảng tạm.',
        'failedToCreateLink': 'Không thể tạo liên kết',
        'sendViaEmail': 'Gửi qua Email',
        'sendingEmail': 'Đang gửi email...',
        'emailSentSuccessfully': 'Email đã gửi thành công đến',
        'failedToSendEmail': 'Không thể gửi email',
        'sendInvoice': 'Gửi Hóa đơn',
        'send': 'Gửi',
        'filterByStatus': 'Lọc theo Trạng thái',
        'allStatus': 'Tất cả Trạng thái',
        'confirmDeletion': 'Xác nhận Xóa',
        'processingInvoice': 'Đang xử lý Hóa đơn',
        'startProcessing': 'Đang bắt đầu xử lý...',
        'scanningInvoice': 'Đang quét hóa đơn...',
        'processingData': 'Đang xử lý dữ liệu...',
        'scanSuccessful': 'Quét thành công!',
        'confidence': 'Độ tin cậy',
        'quantity': 'Số lượng',
        'tryAgain': 'Thử lại',
        'scanAgain': 'Quét lại',
        'confirmAndCreateInvoice': 'Xác nhận & Tạo Hóa đơn',
        'editData': 'Chỉnh sửa Dữ liệu',
        'saveAndContinue': 'Lưu & Tiếp tục',
        'selectImage': 'Chọn Ảnh',
        'uploadInvoiceImage': 'Tải lên Ảnh Hóa đơn',
        'signInWithGoogle': 'Đăng nhập với Google',
        'signInWithApple': 'Đăng nhập với Apple',
        'registrationSuccess': 'Đăng ký thành công!',
        'email': 'Email',
        'phone': 'Điện thoại',
        'address': 'Địa chỉ',
        'due': 'Đến hạn',
        'noDueDate': 'Không có ngày đến hạn',
        'more': 'Thêm',
        'preview': 'Xem trước',
        'sharePdf': 'Chia sẻ PDF',
        'edit': 'Chỉnh sửa',
        'all': 'Tất cả',
      }
    };
    
    final languageCode = isVietnamese ? 'vi' : 'en';
    return translations[languageCode]?[key] ?? key;
  }
  
  static String formatCurrency(double amount, BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      if (amount >= 1000000000) {
        return '${(amount / 1000000000).toStringAsFixed(1)}B ₫';
      } else if (amount >= 1000000) {
        return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
      } else if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(1)}K ₫';
      } else {
        return '${amount.toStringAsFixed(0)} ₫';
      }
    } else {
      if (amount >= 1000000000) {
        return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
      } else if (amount >= 1000000) {
        return '\$${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '\$${(amount / 1000).toStringAsFixed(1)}K';
      } else {
        return '\$${amount.toStringAsFixed(0)}';
      }
    }
  }
} 