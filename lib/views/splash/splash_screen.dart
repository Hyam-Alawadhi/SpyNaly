import 'package:flutter/material.dart';
import '/views/home/home_page.dart'; // استيراد الصفحة الرئيسية

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> introPages = [
    {
      "image": "assets/images/images_splash/monitoringg.png",
      // "title": "Network Monitor",
      "subtitle": "راقب شبكتك، احمِ خصوصيتك، واكتشف التسلل"
    },
    {
      "image": "assets/images/images_splash/security.png",
      // "title": "Instant Protection",
      "subtitle": " اكشف التطبيقات المشبوهة، وأمّن بياناتك"
    },
    {
      "image": "assets/images/images_splash/monitoring.png",
      // "title": "Connected Devices",
      "subtitle": "تعرف على الأجهزة المتصلة بجهازك"
    },
    {
      "image": "assets/images/images_splash/privacy1.png",
      // "title": "Secure Privacy",
      "subtitle": "تحكم في الأذونات، واحمِ بياناتك من التجسس"
    }
  ];

  void _nextPage() {
    if (_currentPage < introPages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(82, 14, 146, 199), // لون الخلفية حسب الطلب
      body: Column(
        children: [
          // ✅ شعار ثابت في الأعلى بحجم صغير
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Image.asset(
              'assets/images/images_splash/Logo_name.png', // شعار التطبيق
              height: 100, // تصغير الحجم
            ),
          ),
          SizedBox(height: 5),

          // ✅ محتوى متغير داخل PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: introPages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildPage(
                  introPages[index]["image"]!,
                  //introPages[index]["title"]!,
                  introPages[index]["subtitle"]!,
                );
              },
            ),
          ),
          _buildBottomNavigation()
        ],
      ),
    );
  }

  Widget _buildPage(String image, /*String title,*/ String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ✅ الصورة التي تتغير مع كل صفحة
        Image.asset(image, height: 200),
        SizedBox(height: 40),

        // ✅ العنوان معلق حالياً، يمكن إعادته إذا لزم الأمر
        //   /*
        // Text(
        //   title,
        //   style: TextStyle(
        //     fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white
        //   ),
        // ),
        // SizedBox(height: 10),
        // */

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            subtitle,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            introPages.length,
            (index) => _buildDot(index),
          ),
        ),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              // backgroundColor: const Color.fromARGB(255, 76, 130, 175),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _nextPage,
            child: Text(
              _currentPage == introPages.length - 1 ? "ابدأ" : "التالي",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
