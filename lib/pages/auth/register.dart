import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ray/auth/auth_service.dart';
import 'package:ray/pages/auth/login_screen.dart';
import 'package:ray/pages/home_page.dart';

import '../../style/handle.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  bool isObscure = true;

  final AuthService _authService = AuthService();

  Future<void> _register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom')),
      );
      return;
    }

    try {
      final result = await _authService.signUpWithEmailPassword(
        email,
        password,
        username,
      );

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Registrasi gagal')),
        );
        return;
      }

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Berhasil'),
              content: const Text(
                  'Akun anda sudah terdaftar, anda akan diarahkan kehalaman Login.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const login()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error saat registrasi: ${e.runtimeType} - $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat registrasi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 75),
              const Center(
                child:CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage('assets/image/image.png'), // Perbaikan di sini
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Ray Pic',
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                      fontFamily: 'horizon'),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  'Daftar',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              CustomTextfield(
                textCapitalization: TextCapitalization.none,
                controller: usernameController,
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.emailAddress,
                hintText: 'username',
                icon: Icon(Icons.person, color: colorScheme.primary),
              ),
              SizedBox(height: 10,),
              CustomTextfield(
                textCapitalization: TextCapitalization.none,
                controller: emailController,
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.emailAddress,
                hintText: 'Email',
                icon: Icon(Icons.email, color: colorScheme.primary),
              ),
              const SizedBox(height: 20),
              CustomTextfield(
                textCapitalization: TextCapitalization.none,
                controller: passwordController,
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.visiblePassword,
                hintText: 'Password',
                isObscure: isObscure,
                visible: true,
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: Icon(Icons.lock, color: colorScheme.primary),
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Register', style: TextStyle(color: Colors.white),),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sudah punya akun? ",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const login()),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          themeNotifier.toggleTheme();
        },
        backgroundColor: colorScheme.primary,
        child: Icon(
          themeNotifier.themeMode == ThemeMode.dark
              ? Icons.dark_mode // Ikon untuk mode gelap
              : Icons.light_mode, // Ikon untuk mode terang
          color: Colors.white,
        ),
      ),

    );
  }
}
