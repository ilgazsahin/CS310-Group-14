import 'package:flutter/material.dart';
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
  final _hostController = TextEditingController();
  final _ticketPriceController = TextEditingController();

  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _hostController.dispose();
    _ticketPriceController.dispose();
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

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved (demo only)')),
      );
      Navigator.pop(context);
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add image box
                Container(
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
                  child: Center(
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
                      ],
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
                              decoration: _inputDecoration('DD/MM/YYYY')
                                  .copyWith(
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
                                  ? 'Required' : null,
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
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        child: TextField(
                          controller: _hostController,
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
                        onPressed: () {},
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(width: 4),
                      const Text('Add Host'),
                    ],
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
                              isExpanded: true, // avoid overflow
                              decoration: _inputDecoration('Select a Category')
                                  .copyWith(border: InputBorder.none),
                              items: const [
                                DropdownMenuItem(
                                    value: 'Workshop',
                                    child: Text('Workshop')),
                                DropdownMenuItem(
                                    value: 'Party', child: Text('Party')),
                                DropdownMenuItem(
                                    value: 'Sports', child: Text('Sports')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
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
                            child: TextField(
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
    return InputDecoration(
      hintText: hint,
      border: InputBorder.none,
    );
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
