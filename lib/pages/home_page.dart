import 'package:flutter/material.dart';
import 'package:ray/pages/addtional/ImagePublic.dart';
import 'package:ray/pages/addtional/imagedetail.dart';
import 'package:ray/pages/auth/login_screen.dart';
import 'package:ray/pages/pengaturan.dart';
import 'package:ray/pages/profile_page.dart';
import 'package:ray/pages/uploadimage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _imageData = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    fetchFilesInUploads(); // Fetch pertama kali
  }

  Future<void> fetchFilesInUploads() async {
    try {
      // Ambil metadata file dari tabel 'images'
      final response = await Supabase.instance.client
          .from('images')
          .select('image_url, uid, id, uploaded_at, description, users(username)')
          .order('uploaded_at',
              ascending: false); // Urutkan dari terbaru ke terlama

      final List<dynamic> data = response;

      if (data.isNotEmpty) {
        List<Map<String, dynamic>> imageData = [];

        for (var file in data) {
          final String fileName = file['image_url'];
          final String description = file['description'];
          final String uuid = file['uid'];
          final String id = file['id'];
          final String username = file['users']['username'];

          final String url = Supabase.instance.client.storage
              .from('images')
              .getPublicUrl('uploads/$fileName');

          imageData.add({
            'url': url,
            'username': username,
            'uid': uuid,
            'description': description,
            'id': id
          });
        }

        setState(() {
          _imageData = imageData;
        });
      } else {
        print('Tidak ada file di tabel metadata.');
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
    }
  }

  void _changeIndex(int index) {
    setState(() {
      _currentIndex = 0;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ray Pic',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Horizon')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 30),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
              fetchFilesInUploads();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _imageData.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(), // Loading spinner
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, // Ganti menjadi 1 untuk satu baris
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio:
                        1.2, // Sesuaikan agar gambar terlihat lebih panjang
                  ),
                  itemCount: _imageData.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePublic(
                              imageUrl: _imageData[index]['url'],
                              username: _imageData[index]['username'] ?? 'Unknown',
                              caption: _imageData[index]['description'] ?? 'No Caption',
                              uuid: _imageData[index]['uid'],
                              id: _imageData[index]['id'],
                            ),
                          ),
                        );
                      },

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  _imageData[index]['url'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Text(
                                'Diunggah oleh:',
                                style: TextStyle(fontSize: 10),
                              ),
                              const SizedBox(width: 5), // Spasi antara teks
                              Text(
                                _imageData[index]['username'] ?? "No Username",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),
                          Text(
                            _imageData[index]['description'] ??
                                "No Description",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadImage()),
                ).then((result) {
                  if (result == true) {
                    fetchFilesInUploads(); // Refresh gambar setelah kembali
                  }
                });
              },
              backgroundColor: const Color(0xFFF4D793),
              child: const Icon(
                Icons.add,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _changeIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
