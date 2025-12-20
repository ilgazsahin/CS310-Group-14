import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _ticketPriceController;
  late final TextEditingController _locationController;
  late final TextEditingController _imageUrlController;

  // multiple host controllers
  late final List<TextEditingController> _hostControllers;

  // image picker + selected image
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _originalImageUrl;

  String? _selectedCategory;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;

    // Initialize controllers with existing event data
    _titleController = TextEditingController(text: event.title);
    _dateController = TextEditingController(text: event.date);
    _timeController = TextEditingController(text: event.time);
    _descriptionController = TextEditingController(text: event.description);
    _ticketPriceController = TextEditingController(text: event.ticketPrice ?? '');
    _locationController = TextEditingController(text: event.location);
    _imageUrlController = TextEditingController(text: event.imageUrl ?? '');
    _originalImageUrl = event.imageUrl;

    // Initialize host controllers with existing hosts
    _hostControllers = event.hosts
        .map((host) => TextEditingController(text: host))
        .toList();
    if (_hostControllers.isEmpty) {
      _hostControllers.add(TextEditingController());
    }

    _selectedCategory = event.category;

    // Listen to image URL changes to update preview
    _imageUrlController.addListener(() {
      setState(() {}); // Update UI when URL changes
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _ticketPriceController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();

    // dispose all host controllers
    for (final c in _hostControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() {
        _dateController.text =
            '${result.day.toString().padLeft(2, '0')}/${result.month.toString().padLeft(2, '0')}/${result.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (result != null) {
      setState(() {
        _timeController.text =
            '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _getImageWidget() {
    // Show uploaded image if available
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    // Show URL image preview if URL is provided
    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Invalid Image URL',
                    style: TextStyle(
                      color: Colors.red.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    }

    // Show placeholder
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kCreatePurple,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Add Image',
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to choose from gallery or camera',
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    // Show dialog to choose source
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        // Clear URL when new image is selected
        _imageUrlController.clear();
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final hosts = _hostControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (hosts.isEmpty) {
        throw 'Please add at least one host';
      }

      // Handle image: Use URL if provided, otherwise upload file if selected
      String? imageUrl;
      String? tempEventId;

      // Priority: Image URL > Uploaded Image > Original Image
      final imageUrlText = _imageUrlController.text.trim();
      if (imageUrlText.isNotEmpty) {
        // Use provided image URL
        imageUrl = imageUrlText;
      } else if (_selectedImage != null) {
        // Upload new image file
        tempEventId = widget.event.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await _storageService.uploadEventImage(
          _selectedImage!,
          tempEventId,
        );
      } else {
        // Keep original image
        imageUrl = _originalImageUrl;
      }

      // Create updated event
      final updatedEvent = widget.event.copyWith(
        title: _titleController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? 'Sabancı University'
            : _locationController.text.trim(),
        date: _dateController.text.trim(),
        time: _timeController.text.trim(),
        description: _descriptionController.text.trim(),
        ticketPrice: _ticketPriceController.text.trim().isEmpty
            ? null
            : _ticketPriceController.text.trim(),
        hosts: hosts,
        category: _selectedCategory,
        imageUrl: imageUrl,
      );

      // Update in Firestore
      if (widget.event.id != null) {
        await _firestoreService.updateEvent(widget.event.id!, updatedEvent);
        print('Event updated successfully with ID: ${widget.event.id}'); // Debug log

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Event Updated'),
              content: const Text('Your event has been updated successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context).pop(); // go back to previous screen
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        throw 'Event ID is missing. Cannot update event.';
      }
    } catch (e) {
      print('Error updating event: $e'); // Debug log
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              'Failed to update event:\n${e.toString()}\n\nPlease check:\n1. You are logged in\n2. Security rules are deployed\n3. Firestore is enabled',
              style: const TextStyle(fontSize: 12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildHostRow(int index) {
    final isLast = index == _hostControllers.length - 1;
    final controller = _hostControllers[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: _inputDecoration(
                'Host Name',
              ).copyWith(border: InputBorder.none),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kCreatePurple,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
            ),
            onPressed: () {
              setState(() {
                if (isLast) {
                  // add new host
                  _hostControllers.add(TextEditingController());
                } else {
                  // remove this host
                  _hostControllers.removeAt(index).dispose();
                }
              });
            },
            child: Icon(isLast ? Icons.add : Icons.remove),
          ),
          const SizedBox(width: 4),
          Text(isLast ? 'Add Host' : 'Remove'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kCreatePurple,
        foregroundColor: Colors.white,
        title: const Text('Edit Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add image box (now tappable)
                Stack(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _getImageWidget(),
                      ),
                    ),
                    if (_selectedImage != null ||
                        _imageUrlController.text.trim().isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                              _imageUrlController.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Image URL input (alternative to file upload)
                const _SectionLabel(text: 'Or Enter Image URL (optional)'),
                _RoundedField(
                  child: TextFormField(
                    controller: _imageUrlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      'https://example.com/image.jpg',
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        // Basic URL validation
                        final urlPattern = RegExp(
                          r'^https?://.+',
                          caseSensitive: false,
                        );
                        if (!urlPattern.hasMatch(value.trim())) {
                          return 'Please enter a valid URL (starting with http:// or https://)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Note: If you provide both an image file and URL, the URL will be used.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),

                const _SectionLabel(text: 'Event Title*'),
                _RoundedField(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration(''),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel(text: 'Date*'),
                          _RoundedField(
                            child: TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _pickDate,
                              decoration: _inputDecoration('DD/MM/YYYY')
                                  .copyWith(
                                    suffixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel(text: 'Time*'),
                          _RoundedField(
                            child: TextFormField(
                              controller: _timeController,
                              readOnly: true,
                              onTap: _pickTime,
                              decoration: _inputDecoration('HH:MM').copyWith(
                                suffixIcon: const Icon(Icons.access_time),
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const _SectionLabel(text: 'Description*'),
                _RoundedField(
                  height: 120,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: _inputDecoration(''),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 24),

                const _SectionLabel(text: 'Host Info'),
                Column(
                  children: List.generate(
                    _hostControllers.length,
                    (index) => _buildHostRow(index),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel(text: 'Category*'),
                          _RoundedField(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                'Select a Category',
                              ).copyWith(border: InputBorder.none),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Academic',
                                  child: Text('Academic'),
                                ),
                                DropdownMenuItem(
                                  value: 'Clubs',
                                  child: Text('Clubs'),
                                ),
                                DropdownMenuItem(
                                  value: 'Social',
                                  child: Text('Social'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Please select a category'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel(text: 'Ticket Price (TL)'),
                          _RoundedField(
                            child: TextFormField(
                              controller: _ticketPriceController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: _inputDecoration('0').copyWith(
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('TL', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // optional
                                }
                                final normalized = value
                                    .replaceAll(',', '.')
                                    .trim();
                                final price = double.tryParse(normalized);
                                if (price == null || price < 0) {
                                  return 'Please enter a valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const _SectionLabel(text: 'Location*'),
                _RoundedField(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: _inputDecoration(
                      'e.g., FASS - Sabancı University',
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kCreatePurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Update Event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final Widget child;
  final double? height;

  const _RoundedField({required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

