import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ticketPriceController = TextEditingController();

  // multiple host controllers
  final List<TextEditingController> _hostControllers = [
    TextEditingController(),
  ];

  // image picker + selected image
  final ImagePicker _imagePicker =  ImagePicker();
  File? _selectedImage;

  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _ticketPriceController.dispose();

    // dispose all host controllers
    for (final c in _hostControllers) {
      c.dispose();
    }

    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: now,
    );
    if (result != null) {
      setState(() {
        _dateController.text =
        '${result.day.toString().padLeft(2, '0')}/${result.month.toString().padLeft(2, '0')}/${result.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (result != null) {
      setState(() {
        _timeController.text =
        '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final hosts = _hostControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // TODO: send hosts + _selectedImage + other data to backend if needed

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Event Created'),
          content: const Text('Your event has been saved successfully.'),
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
  }

  // builds a single host row; last row shows "+" to add, others show "-" to remove
  Widget _buildHostRow(int index) {
    final controller = _hostControllers[index];
    final isLast = index == _hostControllers.length - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: _inputDecoration('Host Name').copyWith(
                border: InputBorder.none,
              ),
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
        title: const Text('Create New Event'),
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
                    child: _selectedImage == null
                        ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: kCreatePurple,
                            child: const Icon(Icons.add,
                                color: Colors.white),
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
                            'Tap to choose from gallery',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
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
                              decoration:
                              _inputDecoration('DD/MM/YYYY').copyWith(
                                suffixIcon: const Icon(Icons.calendar_today),
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
                    const SizedBox(width: 12),
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
                    // Category (2/3 width)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel(text: 'Category*'),
                          _RoundedField(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              decoration: _inputDecoration('Select a Category')
                                  .copyWith(border: InputBorder.none),
                              items: const [
                                DropdownMenuItem(
                                    value: 'Academic',
                                    child: Text('Academic')),
                                DropdownMenuItem(
                                    value: 'Clubs', child: Text('Clubs')),
                                DropdownMenuItem(
                                    value: 'Social', child: Text('Social')),
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
                    const SizedBox(width: 12),
                    // Ticket price (1/3 width)
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel(text: 'Ticket Price'),
                          _RoundedField(
                            child: TextFormField(
                              controller: _ticketPriceController,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: _inputDecoration('0').copyWith(
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(Icons.currency_lira),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null; // optional
                                }
                                final normalized =
                                value.replaceAll(',', '.').trim();
                                final price = double.tryParse(normalized);
                                if (price == null || price < 0) {
                                  return 'Enter a valid price';
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

                const _SectionLabel(text: 'Location'),
                Container(
                  height: 200,
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
                  child: const Center(
                    child: Icon(
                      Icons.map,
                      size: 60,
                      color: kCreatePurple,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kCreatePurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Create Event'),
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
    return const InputDecoration(
      hintText: '',
      border: InputBorder.none,
    ).copyWith(hintText: hint);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: kCreatePurple,
          fontWeight: FontWeight.w600,
          fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
