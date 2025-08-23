import 'package:flutter/material.dart';

class InvoiceTemplatePage extends StatefulWidget {
  const InvoiceTemplatePage({super.key});

  @override
  State<InvoiceTemplatePage> createState() => _InvoiceTemplatePageState();
}

class _InvoiceTemplatePageState extends State<InvoiceTemplatePage> {
  static const List<Map<String, dynamic>> _templates = [
    {
      'id': 'professional_business',
      'name': 'Standard Business',
      'title': 'Standard Business Invoice',
      'description': 'A professional and clean template suitable for most',
      'icon': Icons.business_center,
      'color': Color(0xFF1E3A8A),
      'category': 'Standard Business',
      'previewImage': 'assets/images/templates/standard_business.jpg',
    },
    {
      'id': 'service_based',
      'name': 'Service Based',
      'title': 'Service Based Invoice',
      'description': 'Designed for service providers, focusing on',
      'icon': Icons.miscellaneous_services,
      'color': Color(0xFF0F766E),
      'category': 'Service Based',
      'previewImage': 'assets/images/templates/service_based.jpg',
    },
    {
      'id': 'modern_creative',
      'name': 'Product Sales',
      'title': 'Product Sales Invoice',
      'description': 'Optimized for product sales, with clear sections',
      'icon': Icons.shopping_cart,
      'color': Color(0xFF7C3AED),
      'category': 'Product Sales',
      'previewImage': 'assets/images/templates/product_sales.jpg',
    },
    {
      'id': 'corporate_formal',
      'name': 'Retainer',
      'title': 'Retainer Agreement Invoice',
      'description': 'For ongoing services billed on a retainer basis.',
      'icon': Icons.repeat,
      'color': Color(0xFF1F2937),
      'category': 'Retainer',
      'previewImage': 'assets/images/templates/retainer.jpg',
    },
    {
      'id': 'minimal_clean',
      'name': 'Project',
      'title': 'Project Milestone Invoice',
      'description': 'Ideal for project-based billing, allowing invoicing',
      'icon': Icons.assignment,
      'color': Color(0xFF374151),
      'category': 'Project',
      'previewImage': 'assets/images/templates/project.jpg',
    },
  ];

  String? _selectedTemplateId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_selectedTemplateId == null && args is Map && args['currentTemplateId'] is String) {
      _selectedTemplateId = args['currentTemplateId'] as String;
    }
    _selectedTemplateId ??= _templates.first['id'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Template',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose an Invoice Template',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a template that best fits your billing needs and brand style.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Template list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                final isSelected = _selectedTemplateId == template['id'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTemplateId = template['id'] as String;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.black : const Color(0xFFE5E7EB),
                          width: isSelected ? 2 : 1,
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Template preview
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  template['previewImage'] as String,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback nếu không tìm thấy ảnh
                                    return Container(
                                      color: Colors.grey[100],
                                      child: Icon(
                                        template['icon'] as IconData,
                                        color: template['color'] as Color,
                                        size: 24,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Template info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      template['category'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Template title
                                  Text(
                                    template['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Template description
                                  Text(
                                    template['description'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Selection radio
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.grey[400]!,
                                  width: 2,
                                ),
                                color: isSelected ? Colors.black : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedTemplateId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm Selection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}