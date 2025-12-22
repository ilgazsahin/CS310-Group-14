import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _authorNameController;
  late final TextEditingController _imageUrlController;

  // Multiple images support
  final List<File> _selectedImages = []; // New images to upload
  final List<String> _imageUrls = []; // Existing URLs + new URLs entered by user

  // image picker
  final ImagePicker _imagePicker = ImagePicker();

  final StorageService _storageService = StorageService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final post = widget.post;

    // Initialize controllers with existing post data
    _titleController = TextEditingController(text: post.title);
    _contentController = TextEditingController(text: post.content);
    _authorNameController = TextEditingController(text: post.authorName ?? '');
    _imageUrlController = TextEditingController();

    // Initialize with existing image URLs
    _imageUrls.addAll(post.imageUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorNameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
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
        _selectedImages.add(File(picked.path));
      });
    }
  }

  void _removeImage(int index, bool isFile) {
    setState(() {
      if (isFile) {
        _selectedImages.removeAt(index);
      } else {
        _imageUrls.removeAt(index);
      }
    });
  }

  void _addImageUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty) {
      // Basic URL validation
      final urlPattern = RegExp(r'^https?://.+', caseSensitive: false);
      if (urlPattern.hasMatch(url)) {
        setState(() {
          _imageUrls.add(url);
          _imageUrlController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter a valid URL (starting with http:// or https://)',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImagePreview(File image, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(image, fit: BoxFit.cover, width: 100, height: 100),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removeImage(index, true),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlPreview(String url, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.error_outline, color: Colors.red),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removeImage(index, false),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      if (title.isEmpty) {
        throw 'Please enter a title';
      }

      if (content.isEmpty) {
        throw 'Please enter post content';
      }

      // Upload new images and collect URLs
      List<String> allImageUrls = List.from(_imageUrls); // Start with existing + new URL images

      // Upload new file images
      if (_selectedImages.isNotEmpty) {
        final tempPostId = widget.post.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        for (int i = 0; i < _selectedImages.length; i++) {
          try {
            final imageUrl = await _storageService.uploadPostImage(
              _selectedImages[i],
              '${tempPostId}_${DateTime.now().millisecondsSinceEpoch}_$i',
            );
            allImageUrls.add(imageUrl);
          } catch (e) {
            // Continue with other images even if one fails
            print('Failed to upload image $i: $e');
          }
        }
      }

      // Get author name
      final authorName = _authorNameController.text.trim();

      // Update post (preserve original createdBy and createdAt)
      final updatedPost = widget.post.copyWith(
        title: title,
        content: content,
        imageUrls: allImageUrls,
        authorName: authorName.isNotEmpty ? authorName : null,
        updatedAt: DateTime.now(),
      );

      if (widget.post.id == null) {
        throw 'Post ID is missing. Cannot update.';
      }

      await Provider.of<PostProvider>(
        context,
        listen: false,
      ).updatePost(widget.post.id!, updatedPost);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Post Updated'),
            content: const Text('Your post has been updated successfully.'),
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
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              'Failed to update post:\n${e.toString()}\n\nPlease check:\n1. You are logged in\n2. Security rules are deployed\n3. Firestore is enabled',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kCreatePurple,
        foregroundColor: Colors.white,
        title: const Text('Edit Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(text: 'Post Title*'),
                _RoundedField(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration('Enter post title'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 24),

                const _SectionLabel(text: 'Your Name*'),
                _RoundedField(
                  child: TextFormField(
                    controller: _authorNameController,
                    decoration: _inputDecoration('Enter your name'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 24),

                const _SectionLabel(text: 'Content*'),
                _RoundedField(
                  height: 200,
                  child: TextFormField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: _inputDecoration(
                      'Write your post content here...',
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 24),

                const _SectionLabel(text: 'Images (Optional)'),
                const SizedBox(height: 8),

                // Image URL input
                Row(
                  children: [
                    Expanded(
                      child: _RoundedField(
                        child: TextFormField(
                          controller: _imageUrlController,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _addImageUrl(),
                          decoration: _inputDecoration('Enter image URL'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addImageUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kCreatePurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Add URL'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add from Gallery/Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCreatePurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Image previews (existing + new)
                if (_selectedImages.isNotEmpty || _imageUrls.isNotEmpty) ...[
                  const _SectionLabel(text: 'Image Previews'),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ..._selectedImages.asMap().entries.map((entry) {
                        return _buildImagePreview(entry.value, entry.key);
                      }),
                      ..._imageUrls.asMap().entries.map((entry) {
                        return _buildUrlPreview(entry.value, entry.key);
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _updatePost,
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
                        : const Text('Update Post'),
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
        color: Theme.of(context).cardColor,
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

