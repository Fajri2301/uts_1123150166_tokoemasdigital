import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/supabase_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final Function(String imageUrl)? onImageUploaded;

  const ImageUploadWidget({Key? key, this.onImageUploaded}) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _picker = ImagePicker();
  
  String? _imageUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera, color: Color(0xFFFFD700)),
              title: const Text(
                'Ambil Foto',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFFD700)),
              title: const Text(
                'Pilih dari Galeri',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _uploadImage(File(image.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Generate unique filename
      const uuid = Uuid();
      String extension = imageFile.path.split('.').last;
      String fileName = 'product_${uuid.v4().substring(0, 8)}.$extension';

      // Upload to Supabase Storage
      String publicUrl = await _supabaseService.uploadImage(
        imageFile.path,
        fileName,
      );

      setState(() {
        _imageUrl = publicUrl;
        _uploadProgress = 100.0;
      });

      if (widget.onImageUploaded != null) {
        widget.onImageUploaded!(publicUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar berhasil diupload'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload gambar: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Upload Gambar Produk',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: _isUploading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mengupload... ${_uploadProgress.toStringAsFixed(0)}%',
                        style: const TextStyle(color: Color(0xFFB0B0B0)),
                      ),
                    ],
                  )
                : _imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                        child: Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Color(0xFF666666),
                              ),
                            );
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Color(0xFF666666),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap untuk pilih gambar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0B0B0),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        if (_imageUrl != null && !_isUploading) ...[
          const SizedBox(height: 8),
          Text(
            'URL Gambar:',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB0B0B0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _imageUrl!,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFFFD700),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
