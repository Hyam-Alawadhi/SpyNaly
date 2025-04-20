import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfilePage({super.key, this.onProfileUpdated});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = true;

  String email = '';
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email ?? '';
      photoUrl = user.photoURL;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        _nameController.text = data?['name'] ?? '';
        _locationController.text = data?['location'] ?? '';
      }

      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': _nameController.text.trim(),
            'location': _locationController.text.trim(),
            'photoURL': photoUrl,
          }, SetOptions(merge: true));

          await user.updatePhotoURL(photoUrl);

          final newPassword = _passwordController.text.trim();
          if (newPassword.isNotEmpty) {
            await user.updatePassword(newPassword);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ التعديلات بنجاح')),
          );

          if (widget.onProfileUpdated != null) {
            widget.onProfileUpdated!();
          }

          Navigator.pop(context);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يرجى تسجيل الدخول مجددًا لتحديث كلمة المرور'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ: ${e.message}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ غير متوقع: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على المستخدم')),
      );
      return;
    }

    final file = File(pickedImage.path);
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_profiles')
        .child('${user.uid}.jpg');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.putFile(file);

      final url = await ref.getDownloadURL();
      setState(() {
        photoUrl = url;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع الصورة بنجاح')),
      );
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء رفع الصورة: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        title: Text(
          "تعديل الحساب",
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl!)
                              : const AssetImage(
                                  "assets/images/images_profile/profile.png",
                                ) as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: colorScheme.primary,
                            radius: 18,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.edit,
                                size: 18,
                                color: colorScheme.onPrimary,
                              ),
                              onPressed: _pickAndUploadImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'الرجاء إدخال الاسم'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: email,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور الجديدة',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "إلغاء",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                          ),
                          onPressed: _saveProfile,
                          child: Text(
                            "حفظ",
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
