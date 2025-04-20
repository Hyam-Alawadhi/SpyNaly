import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: const Color.fromARGB(255, 207, 66, 66),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool isConnected = await _checkInternetConnection();
      if (!isConnected) {
        _showErrorSnackBar('يرجى التحقق من اتصالك بالإنترنت');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
          _showErrorSnackBar('كلمات المرور غير متطابقة');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_emailController.text.trim());
        if (signInMethods.isNotEmpty) {
          _showErrorSnackBar('البريد الإلكتروني مُستخدم بالفعل');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance.collection('users').doc(credential.user?.uid).set({
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("تم إنشاء الحساب بنجاح: ${credential.user?.email}");
        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        String message = 'حدث خطأ أثناء التسجيل';
        if (e.code == 'email-already-in-use') {
          message = 'البريد الإلكتروني مُستخدم بالفعل';
        } else if (e.code == 'weak-password') {
          message = 'كلمة المرور ضعيفة جداً';
        }
        _showErrorSnackBar(message);
      } catch (e) {
        _showErrorSnackBar('حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.');
        print('خطأ غير متوقع: $e');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
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
                        'إنشاء حساب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
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
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'الاسم الكامل',
                                    prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى إدخال الاسم الكامل';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'البريد الإلكتروني',
                                    prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
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
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                                      return 'يرجى إدخال بريد إلكتروني صحيح';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور',
                                    prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
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
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'تأكيد كلمة المرور',
                                    prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                        });
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
                                      return 'يرجى تأكيد كلمة المرور';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 40),
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: _register,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black87,
                                          ),
                                          child: const Text(
                                            'إنشاء حساب',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("هل لديك حساب بالفعل؟ ", style: TextStyle(color: Colors.black54)),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(context, '/login');
                                      },
                                      child: const Text(
                                        'تسجيل الدخول',
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}