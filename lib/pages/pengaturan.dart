import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ray/pages/addtional/gantifoto.dart';
import 'package:ray/pages/auth/login_screen.dart';
import 'package:ray/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../style/handle.dart';
import 'addtional/gantinama.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Map<String, dynamic>? userProfile;
  String? profileImageUrl;
  bool isLoading = true;

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

      final response =
          await supabase.from('users').select().eq('id', user.id).maybeSingle();

      if (response != null) {
        setState(() {
          userProfile = response;
          fetchProfileImage();
        });
      } else {
        debugPrint("Profil tidak ditemukan");
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
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

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileSection(context),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text('Tema Gelap',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      value: themeNotifier.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeNotifier.toggleTheme();
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red
                        ),
                        child: const Text("Sign Out",style: TextStyle(
                          color: Colors.white
                        ),),
                      ),
                    )
                  ],
                ),
              ),
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.border_color, size: 16),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  userProfile?['email'] ?? "Email",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
