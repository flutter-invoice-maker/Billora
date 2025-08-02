// Các hằng số chung cho ứng dụng
class AppConstants {
  static const String appName = 'Billora';
  
  // Firestore Collections
  static const String invoicesCollection = 'invoices';
  static const String customersCollection = 'customers';
  static const String productsCollection = 'products';
  static const String tagsCollection = 'tags';
  static const String usersCollection = 'users';
  
  // Dashboard Constants
  static const int defaultChartDataPoints = 30;
  static const int maxTopTags = 5;
  static const String defaultCurrency = 'VND';
  static const String defaultCurrencySymbol = '₫';
  
  // Date Range Presets
  static const String today = 'today';
  static const String yesterday = 'yesterday';
  static const String last7Days = 'last7Days';
  static const String last30Days = 'last30Days';
  static const String thisMonth = 'thisMonth';
  static const String lastMonth = 'lastMonth';
  static const String thisQuarter = 'thisQuarter';
  static const String thisYear = 'thisYear';
  static const String custom = 'custom';
} 
