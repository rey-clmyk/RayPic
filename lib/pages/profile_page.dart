import 'package:flutter/material.dart';
import 'package:ray/pages/addtional/gantinama.dart';
import 'package:ray/pages/addtional/imagedetail.dart';
import 'package:ray/pages/pengaturan.dart';
import 'package:ray/pages/uploadimage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'addtional/gantifoto.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userProfile;
  String? profileImageUrl;
  int uploadedPhotos = 0;
  int _currentIndex = 1;
  List<Map<String, dynamic>> _userImages = [];

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint("User belum login");
        return;
      }

      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          userProfile = response;
          fetchProfileImage();
          fetchUploadedPhotos(user.id);
          fetchUserImages(user.id);
        });
      } else {
        debugPrint("Profil tidak ditemukan");
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  void fetchProfileImage() {
    if (userProfile?['avatar_url'] != null) {
      profileImageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl('uploads/${userProfile!['avatar_url']}');
    } else {
      profileImageUrl = null;
    }
    setState(() {});
  }

  Future<void> fetchUploadedPhotos(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('images')
          .select('id')
          .eq('uid', userId);

      setState(() {
        uploadedPhotos = response.length;
      });
    } catch (e) {
      debugPrint("Error fetching uploaded photos: $e");
    }
  }

  Future<void> fetchUserImages(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('images')
          .select('*')
          .eq('uid', userId)
          .order('uploaded_at', ascending: false);

      final List<dynamic> data = response;

      if (data.isNotEmpty) {
        List<Map<String, dynamic>> imageData = [];

        for (var file in data) {
          final String fileName = file['image_url'];
          final String caption = file['description'];
          final String uuid = file['uid'];
          final String id = file['id'];

          // Ambil username berdasarkan uid
          final userResponse = await Supabase.instance.client
              .from('users')
              .select('username')
              .eq('id', uuid)
              .single();

          final String username = userResponse['username'];

          final String url = Supabase.instance.client.storage
              .from('images')
              .getPublicUrl('uploads/$fileName');

          imageData.add({
            'url': url,
            'username': username,
            'caption': caption,
            'uuid': uuid,
            'id': id
          });
        }

        setState(() {
          _userImages = imageData;
        });
      } else {
        debugPrint('Tidak ada gambar yang diunggah oleh user.');
      }
    } catch (error) {
      debugPrint('Terjadi kesalahan saat mengambil gambar: $error');
    }
  }


  void _changeIndex(int index) {
    setState(() {
      _currentIndex = 1;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ray Pic',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Horizon')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 30),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileSection(context),star_border menjadi
                const SizedBox(height: 20),
                _buildUserImagesSection(),
              ],
            ),
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
                    fetchProfileImage();
                    fetchUserProfile(); // Pastikan ini tidak null sebelum digunakan
                  }
                });
              },
              backgroundColor: const Color(0xFFF4D793),
              child: const Icon(Icons.add),
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

  Widget _buildProfileSection(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GantiFoto(
                  profileImageUrl: profileImageUrl ?? 'assets/image/image.png',
                ),
              ),
            ).then((_) => fetchUserProfile());
          },
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl!)
                : const AssetImage('assets/image/image.png') as ImageProvider,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GantiUsername()),
              ).then((_) => fetchUserProfile());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        userProfile?['username'] ?? "Username",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.border_color,size: 16,),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  userProfile?['email'] ?? "Email",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Foto diunggah: $uploadedPhotos",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserImagesSection() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _userImages.length,
        itemBuilder: (context, index) {
          final image = _userImages[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageUser(
                    imageUrl: image['url']??'yo',
                    username: image['username']??'yo',
                    caption: image['caption']??'yo',
                    uuid: image['uuid']??'yo',
                    id: image['id']??1,
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
                        _userImages[index]['url'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _userImages[index]['caption'] ??
                      "No Description",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),          );
        },
      ),
    );
  }

}