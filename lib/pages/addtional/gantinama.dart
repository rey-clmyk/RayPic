import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GantiUsername extends StatefulWidget {
  const GantiUsername({super.key});

  @override
  State<GantiUsername> createState() => _GantiUsernameState();
}

class _GantiUsernameState extends State<GantiUsername> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isValid = false;
  String? _errorMessage;

  void _validateUsername(String value) {
    final trimmedValue = value.trim(); // Hilangkan spasi di awal dan akhir
    final regex = RegExp(r'^[a-zA-Z0-9_.]+$');

    setState(() {
      if (trimmedValue.isEmpty) {
        _isValid = false;
        _errorMessage = "Username tidak boleh kosong";
      } else if (trimmedValue.length < 5) {
        _isValid = false;
        _errorMessage = "Username harus minimal 5 karakter";
      } else if (!regex.hasMatch(trimmedValue)) {
        _isValid = false;
        _errorMessage = "Username hanya boleh a-Z,0-9,.dan _ ";
      } else {
        _isValid = true;
        _errorMessage = null;
      }
    });
  }



  Future<void> _changeUsername() async {
    if (!_isValid) return;

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User belum login")),
        );
        return;
      }

      await supabase.from('users').update({
        'username': _usernameController.text.trim(),
      }).eq('id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username berhasil diubah")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengubah username: \$e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ganti Username")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              onChanged: _validateUsername,
              decoration: InputDecoration(
                hintText: "Username",
                errorText: _errorMessage,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Username dapat dilihat secara publik, dilarang mengandung SARA, kata kasar",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _changeUsername : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValid ? Colors.green : Colors.grey,
                ),
                child: Text("Ganti",style: TextStyle(color: _isValid ? Colors.white : Colors.white70),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
