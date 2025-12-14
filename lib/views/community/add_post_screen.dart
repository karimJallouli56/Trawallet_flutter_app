import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:trawallet_final_version/widgets/input_field.dart';
import 'package:trawallet_final_version/models/post.dart';

class AddPostScreen extends StatefulWidget {
  final String userId;
  final String userAvatar;
  final String username;

  const AddPostScreen({
    super.key,
    required this.userId,
    required this.userAvatar,
    required this.username,
  });

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  List<File> _selectedImages = [];
  String? _selectedLocation;
  String _selectedCategory = 'photo';
  bool _isUploading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((img) => File(img.path)));
        });
      }
    } catch (e) {
      print('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCategoryOption('photo', '📸', 'Photo', Colors.blue),
            _buildCategoryOption('tip', '💡', 'Tip', Colors.orange),
            _buildCategoryOption('review', '⭐', 'Review', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(
    String value,
    String emoji,
    String label,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
      title: Text(label),
      trailing: _selectedCategory == value
          ? Icon(Icons.check_circle, color: Colors.teal)
          : null,
      onTap: () {
        setState(() => _selectedCategory = value);
        Navigator.pop(context);
      },
    );
  }

  void _showLocationPicker() {
    final TextEditingController locationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.fromLTRB(24, 0, 24, 24),
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          title: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add Location',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputField(
                label: "Location",
                icon: Icons.location_on,
                controller: locationController,
                withBorder: true,
              ),
            ],
          ),
          actions: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedLocation = locationController.text;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    try {
      for (int i = 0; i < _selectedImages.length; i++) {
        print('Uploading image ${i + 1} of ${_selectedImages.length}');
        final file = _selectedImages[i];
        if (!await file.exists()) {
          throw Exception('Image file does not exist');
        }
        final fileSize = await file.length();
        print('File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Image ${i + 1} is too large (max 5MB)');
        }
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final filePath = 'posts/${widget.userId}/$fileName';
        final bytes = await file.readAsBytes();
        print('Uploading to path: $filePath');
        await supabase.storage
            .from('post-images')
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception('Upload timeout for image ${i + 1}');
              },
            );

        print('Upload successful for image ${i + 1}');
        final imageUrl = supabase.storage
            .from('post-images')
            .getPublicUrl(filePath);

        print('Public URL: $imageUrl');
        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } on StorageException catch (e) {
      print('Supabase Storage error: ${e.message}');
      print('Status code: ${e.statusCode}');
      throw Exception('Storage error: ${e.message}');
    } on TimeoutException catch (e) {
      print('Upload timeout: $e');
      throw Exception('Upload took too long. Please try again.');
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  Future<void> _handlePost() async {
    if (_contentController.text.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content or images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      print('=== STARTING POST CREATION ===');
      print('Content: ${_contentController.text}');
      print('Images count: ${_selectedImages.length}');
      print('Location: $_selectedLocation');
      print('Category: $_selectedCategory');

      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        print('=== UPLOADING IMAGES ===');
        imageUrls = await _uploadImages();
        print('=== IMAGES UPLOADED: ${imageUrls.length} ===');
      }

      print('=== CALLING Post.addPost ===');
      print('UserId: ${widget.userId}');
      print('Username: ${widget.username}');
      print('UserAvatar: ${widget.userAvatar}');

      final postId = await Post.addPost(
        userId: widget.userId,
        username: widget.username,
        userAvatar: widget.userAvatar,
        content: _contentController.text,
        images: imageUrls,
        location: _selectedLocation,
        category: _selectedCategory,
      );

      print('=== POST CREATED: $postId ===');

      if (!mounted) {
        print('=== WIDGET NOT MOUNTED ===');
        return;
      }

      setState(() => _isUploading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e, stack) {
      print('=== ERROR OCCURRED ===');
      print('Error: $e');
      print('Stack trace: $stack');

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPost =
        _contentController.text.isNotEmpty || _selectedImages.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        if (_isUploading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait, upload in progress...'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.teal,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isUploading ? null : () => Navigator.pop(context),
          ),
          title: const Text(
            'Create Post',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: (canPost && !_isUploading) ? _handlePost : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.teal,
                          ),
                        ),
                      )
                    : const Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  widget.userAvatar,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_selectedLocation != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedLocation!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _contentController,
                            maxLines: null,
                            enabled: !_isUploading,
                            decoration: InputDecoration(
                              hintText: "What's on your mind?",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 18,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 18),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),

                        if (_selectedImages.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (!_isUploading)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.photo_library,
                          color: Colors.teal,
                          size: 32,
                        ),
                        onPressed: _isUploading ? null : _pickImages,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.blue.shade500,
                          size: 32,
                        ),
                        onPressed: _isUploading ? null : _pickCamera,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: Colors.red.shade400,
                          size: 32,
                        ),
                        onPressed: _isUploading ? null : _showLocationPicker,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.category,
                          color: Colors.orange.shade500,
                          size: 32,
                        ),
                        onPressed: _isUploading ? null : _showCategoryPicker,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isUploading)
              Container(
                color: Colors.black26,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.teal),
                          SizedBox(height: 16),
                          Text(
                            'Uploading post...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please wait',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
