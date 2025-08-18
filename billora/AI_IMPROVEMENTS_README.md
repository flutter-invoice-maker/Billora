# AI Improvements for Billora

## Tổng quan

Dự án này đã được cải tiến để cung cấp AI chat thông minh có khả năng truy cập và phân tích dữ liệu thực từ tài khoản người dùng thay vì sử dụng dữ liệu mock. AI giờ đây có thể:

1. **Đọc hiểu dữ liệu thực**: Truy cập invoices, customers, products từ tài khoản người dùng
2. **Phân tích theo ngữ cảnh**: Cung cấp insights dựa trên tab hiện tại (Dashboard, Customers, Products, Invoices)
3. **Giao diện Messenger-style**: Quick actions và suggestions được hiển thị dưới dạng menu trong khung nhập
4. **Cách ly dữ liệu**: Mỗi tài khoản chỉ thấy dữ liệu của mình

## Cấu hình

### 1. OpenAI API Key

Tạo file `.env` trong thư mục gốc của dự án:

```bash
# OpenAI API Configuration
OPENAI_API_KEY=your_openai_api_key_here
```

**Lưu ý**: Thay `your_openai_api_key_here` bằng API key thực từ OpenAI.

### 2. Dependencies

Đảm bảo các dependencies sau đã được cài đặt:

```yaml
dependencies:
  flutter_dotenv: ^5.0.0
  http: ^0.13.0
  injectable: ^2.0.0
  firebase_auth: ^4.0.0
  cloud_firestore: ^4.0.0
```

## Cấu trúc mới

### EnhancedAIService
- **Vị trí**: `lib/src/core/services/enhanced_ai_service.dart`
- **Chức năng**: Truy cập dữ liệu thực từ repositories và gửi đến OpenAI API
- **Tính năng**:
  - Phân tích dữ liệu business
  - Gợi ý tags cho invoices
  - Phân loại invoices
  - Tạo summary

### AIChatService
- **Vị trí**: `lib/src/core/services/ai_chat_service.dart`
- **Chức năng**: Quản lý chat và quick actions
- **Tính năng**:
  - Quick actions theo ngữ cảnh tab
  - Gợi ý follow-up dựa trên câu trả lời
  - Tổng hợp dữ liệu business

### EnhancedAIChatWidget
- **Vị trí**: `lib/src/core/widgets/enhanced_ai_chat_widget.dart`
- **Chức năng**: Giao diện chat với Messenger-style
- **Tính năng**:
  - Quick actions chips
  - Message bubbles với suggestions
  - Input field với hint text
  - Responsive design

## Sử dụng

### 1. Khởi tạo AI Chat

```dart
// Trong widget
final aiChatService = sl<AIChatService>();

// Hiển thị chat
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.8,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    builder: (context, scrollController) => EnhancedAIChatWidget(
      currentTabIndex: currentTabIndex,
      primaryColor: primaryColor,
      scrollController: scrollController,
    ),
  ),
);
```

### 2. Gửi tin nhắn

```dart
// Gửi tin nhắn và nhận response
final response = await aiChatService.sendMessage(
  "Phân tích doanh thu của tôi", 
  currentTabIndex
);

if (!response.isError) {
  print(response.message);
  // Hiển thị suggestions
  for (final suggestion in response.suggestions) {
    print("${suggestion.title}: ${suggestion.prompt}");
  }
}
```

### 3. Quick Actions

```dart
// Lấy quick actions theo tab
final quickActions = aiChatService.getQuickActions(currentTabIndex);

// Hiển thị quick actions
for (final action in quickActions) {
  print("${action.icon} ${action.title}");
  print("Category: ${action.category}");
  print("Prompt: ${action.prompt}");
}
```

## Tính năng theo Tab

### Dashboard (Tab 0)
- Revenue Analysis
- Business Performance
- Growth Opportunities
- Customer Insights

### Customers (Tab 1)
- Customer Segmentation
- Customer Lifetime Value
- Retention Analysis
- Customer Behavior

### Products (Tab 2)
- Top Selling Products
- Inventory Optimization
- Pricing Strategy
- Product Categories

### Invoices (Tab 3)
- Invoice Analysis
- Payment Status
- Overdue Tracking
- Revenue Trends

## Xử lý lỗi

### 1. API Key không hợp lệ
```dart
if (_apiKey.isEmpty) {
  return 'OpenAI API key not configured';
}
```

### 2. Lỗi kết nối
```dart
try {
  final response = await _callChatGPT(prompt);
  return response ?? 'I\'m having trouble analyzing your data right now.';
} catch (e) {
  return 'Sorry, I encountered an error while analyzing your business data.';
}
```

### 3. Dữ liệu không đủ
```dart
if (invoices.isEmpty && customers.isEmpty && products.isEmpty) {
  return 'I don\'t see any business data yet. Please add some invoices, customers, or products first.';
}
```

## Bảo mật

### 1. Cách ly dữ liệu
- Mỗi user chỉ thấy dữ liệu của mình
- Sử dụng `_currentUserId` để filter dữ liệu

### 2. API Key
- Không commit API key vào repository
- Sử dụng file `.env` và `.gitignore`

### 3. Validation
- Validate input trước khi gửi đến OpenAI
- Sanitize response trước khi hiển thị

## Troubleshooting

### 1. AI không trả lời
- Kiểm tra OpenAI API key
- Kiểm tra kết nối internet
- Kiểm tra logs trong console

### 2. Dữ liệu không chính xác
- Đảm bảo user đã đăng nhập
- Kiểm tra repositories có dữ liệu
- Kiểm tra Firebase permissions

### 3. Giao diện không hiển thị
- Kiểm tra dependencies injection
- Kiểm tra widget tree
- Kiểm tra console errors

## Phát triển tiếp theo

### 1. Tính năng mới
- Voice chat
- Image analysis
- Multi-language support
- Advanced analytics

### 2. Tối ưu hóa
- Cache responses
- Batch processing
- Rate limiting
- Error recovery

### 3. Monitoring
- Usage analytics
- Performance metrics
- Error tracking
- User feedback

## Liên hệ

Nếu có vấn đề hoặc câu hỏi, vui lòng tạo issue trong repository hoặc liên hệ team development. 