import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_spynaly/views/auth/AuthChoicePage.dart';
import 'package:app_spynaly/views/profile/profile_page.dart';

class DrawerWidget extends StatelessWidget {
  final User? user;
  final String userName;
  final VoidCallback refreshUserData;

  const DrawerWidget({
    super.key,
    required this.user,
    required this.userName,
    required this.refreshUserData,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 24, 82, 120),
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 5, right: 5),
            child: Column(
              children: [
                // صورة الملف الشخصي
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: user?.photoURL != null
                        ? Image.network(
                            user!.photoURL!,
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                // اسم المستخدم
                Text(
                  user != null ? userName : 'مرحبا بك',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // البريد الإلكتروني للمستخدم
                Text(
                  user?.email ?? 'الرجاء تسجيل الدخول',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                'ملفي الشخصي',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(onProfileUpdated: refreshUserData),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.phonelink),
            title: const Text(
              'الأجهزة المتصلة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/connected_devices');
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text(
              'تحليل التطبيقات',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/apps_analysis');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              'الإعدادات',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthChoicePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
