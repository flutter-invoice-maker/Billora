import 'package:flutter/material.dart';
import '../../domain/entities/scan_library_item.dart';

class ScanLibraryEditPage extends StatefulWidget {
  final ScanLibraryItem scanItem;

  const ScanLibraryEditPage({super.key, required this.scanItem});

  @override
  State<ScanLibraryEditPage> createState() => _ScanLibraryEditPageState();
}

class _ScanLibraryEditPageState extends State<ScanLibraryEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fileNameController;
  late TextEditingController _noteController;
  late List<String> _tags;
  late bool _isProcessed;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: widget.scanItem.fileName);
    _noteController = TextEditingController(text: widget.scanItem.note ?? '');
    _tags = List.from(widget.scanItem.tags);
    _isProcessed = widget.scanItem.isProcessed;
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Scan Item'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 20),
                _buildEditSection(),
                const SizedBox(height: 20),
                _buildTagsSection(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Item Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Store Name', widget.scanItem.scannedBill.storeName),
          _buildInfoRow('Total Amount', '\$${widget.scanItem.scannedBill.totalAmount.toStringAsFixed(2)}'),
          _buildInfoRow('Scan Date', _formatDate(widget.scanItem.scannedBill.scanDate)),
          _buildInfoRow('Created', _formatDate(widget.scanItem.createdAt)),
        ],
      ),
    );
  }

  Widget _buildEditSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Edit Fields',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _fileNameController,
            decoration: const InputDecoration(
              labelText: 'File Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            validator: (value) => value?.isEmpty == true ? 'File name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isProcessed,
                onChanged: (value) => setState(() => _isProcessed = value ?? false),
                activeColor: Colors.blue,
              ),
              const SizedBox(width: 8),
              const Text(
                'Mark as Processed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: _tags.asMap().entries.map((entry) {
                final index = entry.key;
                final tag = entry.value;
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(index),
                  deleteIcon: const Icon(Icons.close, size: 18),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Add New Tag',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add),
                  ),
                  onSubmitted: _addTag,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _addTag(_getCurrentTagInput()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              side: const BorderSide(color: Colors.grey),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _clearTagInput();
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  String _getCurrentTagInput() {
    // This would get the current tag input value
    // For now, return empty string
    return '';
  }

  void _clearTagInput() {
    // This would clear the tag input field
    // For now, do nothing
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() != true) return;

    final updatedItem = widget.scanItem.copyWith(
      fileName: _fileNameController.text,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      tags: _tags,
      isProcessed: _isProcessed,
      lastModifiedAt: DateTime.now(),
    );

    // Save to actual data source - this will be implemented when data persistence is added
    
    Navigator.pop(context, updatedItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 