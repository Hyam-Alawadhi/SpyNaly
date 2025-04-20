import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthChoicePage extends StatelessWidget {
  final bool isArabic;

  const AuthChoicePage({super.key, this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 24, 82, 120), // أزرق داكن
                    Color.fromARGB(255, 24, 82, 120), // أزرق داكن
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 1.0,
                          left: 20.0,
                          right: 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            Center(
                              child: Image.asset(
                                'assets/images/images_auth/Logo_login.png',
                                height: 170,
                                width: 370,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: size.height * 0.67,
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
                            vertical: 30.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'مرحباً بك',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 24, 82, 120),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'قم بإنشاء حساب أو سجل دخولك للمتابعة',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: 30),
                              _buildButton(
                                context,
                                label: 'إنشاء حساب',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                backgroundColor: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 24, 82, 120),
                                    Color.fromARGB(255, 14, 111, 135),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              _buildButton(
                                context,
                                label: 'تسجيل الدخول',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                backgroundColor: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 24, 82, 120),
                                    Color.fromARGB(255, 14, 111, 135),
                                  ],
                                ),
                                isOutline: true,
                              ),
                              const SizedBox(height: 25),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [],
                              ),
                            ],
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

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    required LinearGradient backgroundColor,
    bool isOutline = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: isOutline ? Colors.transparent : null,
          side:
              isOutline
                  ? const BorderSide(color: Colors.blueGrey, width: 2)
                  : null,
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: backgroundColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20, // تم تكبير حجم الخط
                fontWeight: FontWeight.w900, // خط عريض جدًا
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
      ),
    );
  }
}