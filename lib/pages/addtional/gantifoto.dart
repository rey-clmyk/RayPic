import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GantiFoto extends StatefulWidget {
  final String profileImageUrl;

  const GantiFoto({super.key, required this.profileImageUrl});

  @override
  State<GantiFoto> createState() => _GantiFotoState();
}

class _GantiFotoState extends State<GantiFoto> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'uploads/$fileName';
      await supabase.storage.from('images').upload(path, _selectedImage!);

      await supabase
          .from('users')
          .update({'avatar_url': fileName}).eq('id', user.id);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Foto berhasil diubah")));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal mengunggah foto: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ganti Foto")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2,
            width: double.infinity,
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _selectedImage != null
                  ? Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              )
                  : (widget.profileImageUrl.isNotEmpty
                  ? Image.network(
                widget.profileImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
              )
                  : Image.asset(
                'assets/image/image.png',
                fit: BoxFit.cover,
              )),
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Ganti Foto"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _selectedImage != null ? _uploadImage : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Ganti", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
