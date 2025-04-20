import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _message;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        setState(() {
          _message = 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني';
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            _message = 'البريد الإلكتروني غير مسجل.';
          } else if (e.code == 'invalid-email') {
            _message = 'صيغة البريد الإلكتروني غير صحيحة.';
          } else {
            _message = 'حدث خطأ: ${e.message}';
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نسيت كلمة المرور',  style:TextStyle(color: Colors.white)),centerTitle: true,backgroundColor: const Color.fromARGB(255, 24, 82, 120),iconTheme: const IconThemeData(color: Colors.white),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'أدخل بريدك الإلكتروني لإرسال رابط إعادة تعيين كلمة المرور',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text('إرسال رابط'),
              ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains('تم إرسال') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
