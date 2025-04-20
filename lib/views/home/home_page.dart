import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_spynaly/views/auth/AuthChoicePage.dart';
// import 'package:app_spynaly/views/devices/connected_devices_page.dart';
import 'package:app_spynaly/widgets/drawer_widget.dart';  // استيراد الـ Drawer

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Callback لتحديث البيانات عند الرجوع من ProfilePage
  void refreshUserData() {
    _loadUserData(); // تعيد تحميل بيانات المستخدم
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      setState(() {
        _user = user;
        _userName = doc.data()?['name'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _user = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 24, 82, 120),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الصفحة الرئيسية',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            fontFamily: 'Cairo',
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: IconButton(
              icon: const Icon(
                Icons.account_circle,
                size: 35,
                color: Colors.white,
              ),
              tooltip: 'الحساب',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthChoicePage(),
                  ),
                );
              },
            ),
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: DrawerWidget( 
        user: _user,
        userName: _userName,
        refreshUserData: refreshUserData,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      // Image.asset(
                      //   'assets/images/images_Home/LogoShort.png',
                      //   width: 110,
                      //   height: 100,
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
    );
  }
}