import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_spynaly/views/profile/profile_page.dart';
import 'package:app_spynaly/views/auth/forgot_password_page.dart';
import 'package:app_spynaly/views/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _navigateAfterLogin(User user) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final hasName = doc.data()?['name'] != null;

    if (!doc.exists || !hasName) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _navigateAfterLogin(credential.user!);
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ أثناء تسجيل الدخول';

      switch (e.code) {
        case 'user-not-found':
          message = 'هذا البريد الإلكتروني غير مسجل';
          break;
        case 'wrong-password':
          message = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          message = 'صيغة البريد الإلكتروني غير صحيحة';
          break;
        case 'user-disabled':
          message = 'تم تعطيل هذا الحساب';
          break;
        case 'too-many-requests':
          message = 'تم إيقاف الحساب مؤقتاً بسبب محاولات فاشلة كثيرة';
          break;
        default:
          message = 'خطأ غير متوقع: ${e.message}';
      }

      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _loginWithGoogle() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // تسجيل الخروج من أي حساب Google سابق
    await GoogleSignIn().signOut();

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // المستخدم ألغى العملية
      setState(() => _isLoading = false);
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user == null) {
      setState(() {
        _errorMessage = 'لم يتم العثور على معلومات المستخدم بعد تسجيل الدخول.';
        _isLoading = false;
      });
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // إضافة بيانات جديدة للمستخدم
      await userDoc.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await _navigateAfterLogin(user);
  } on FirebaseAuthException catch (e) {
    setState(() {
      _errorMessage = 'خطأ في Firebase: ${e.message}';
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'حدث خطأ أثناء تسجيل الدخول باستخدام Google';
    });
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 24, 82, 120),
                    Color.fromARGB(255, 238, 255, 206),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: size.height,
                  width: size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'مرحبا',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                 'تسجيل الدخول',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 24.0,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'البريد الإلكتروني',
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Colors.grey[600],
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال البريد الإلكتروني';
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                                      ).hasMatch(value)) {
                                        return 'يرجى إدخال بريد إلكتروني صحيح';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 25),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: 'كلمة المرور',
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.grey[600],
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          setState(
                                            () =>
                                                _isPasswordVisible =
                                                    !_isPasswordVisible,
                                          );
                                        },
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال كلمة المرور';
                                      }
                                      if (value.length < 6) {
                                        return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () {
                                         Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                                        );
                                        // رابط استعادة كلمة المرور
                                      },
                                      child: const Text(
                                        'هل نسيت كلمة المرور؟',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  _isLoading
                                      ? const CircularProgressIndicator()
                                      : Column(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black87,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                              onPressed: _login,
                                              child: const Text(
                                                'تسجيل الدخول',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text('أو'),
                                          const SizedBox(height: 16),
                                          GestureDetector(
                                            onTap: _loginWithGoogle,
                                            child: Container(
                                              width: double.infinity,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                  255,
                                                  23,
                                                  111,
                                                  169,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Row(
                                                textDirection: TextDirection.ltr, // <-- أضف هذا السطر لتحديد اتجاه النص من اليسار لليمين
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/google_logo.png',
                                                    width: 24,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Text(
                                                    'تسجيل الدخول باستخدام Google',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "ليس لديك حساب؟ ",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                   Navigator.pushReplacementNamed(
                                                    context,
                                                    '/register',
                                                );
                                                  // التوجيه إلى صفحة التسجيل
                                                },
                                                child: const Text(
                                                  'إنشاء حساب',
                                                  style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}