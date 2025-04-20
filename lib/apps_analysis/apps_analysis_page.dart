import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class AppsAnalysisPage extends StatefulWidget {
  const AppsAnalysisPage({super.key});

  @override
  State<AppsAnalysisPage> createState() => _AppsAnalysisPageState();
}

class _AppsAnalysisPageState extends State<AppsAnalysisPage> {
  List<Map<String, dynamic>> _analyzedApps = [];
  bool _isLoading = true;

  final List<String> _suspiciousApps = [
    "com.fake.spyapp",
    "com.example.hacktool",
    "com.sniffer.proxy",
  ];

  final Map<String, String> _dangerousPermissions = {
    "Permission.microphone": "خطيرة",
    "Permission.location": "خطيرة",
    "Permission.sms": "خطيرة",
    "Permission.contacts": "متوسطة",
    "Permission.camera": "خطيرة",
    "Permission.storage": "متوسطة",
    "Permission.photos": "متوسطة",
  };

  @override
  void initState() {
    super.initState();
    _analyzeInstalledApps();
  }

  Future<void> _analyzeInstalledApps() async {
    setState(() => _isLoading = true);
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: false,
      includeAppIcons: true,
    );

    List<Map<String, dynamic>> results = [];

    for (var app in apps) {
      final isSuspicious = _suspiciousApps.contains(app.packageName);

      List<String> permissions = [];
      String level = "آمنة";

      if (await Permission.microphone.status.isGranted) {
        permissions.add("Permission.microphone");
        level = _updateRiskLevel(level, "خطيرة");
      }
      if (await Permission.location.status.isGranted) {
        permissions.add("Permission.location");
        level = _updateRiskLevel(level, "خطيرة");
      }
      if (await Permission.sms.status.isGranted) {
        permissions.add("Permission.sms");
        level = _updateRiskLevel(level, "خطيرة");
      }
      if (await Permission.contacts.status.isGranted) {
        permissions.add("Permission.contacts");
        level = _updateRiskLevel(level, "متوسطة");
      }
      if (await Permission.camera.status.isGranted) {
        permissions.add("Permission.camera");
        level = _updateRiskLevel(level, "خطيرة");
      }
      if (await Permission.storage.status.isGranted) {
        permissions.add("Permission.storage");
        level = _updateRiskLevel(level, "متوسطة");
      }

      if (isSuspicious) {
        level = "خطيرة";
      }

      results.add({
        'appName': app.appName,
        'package': app.packageName,
        'classification': level,
        'permissions': permissions,
        'suspicious': isSuspicious,
      });
    }

    // تخزين النتائج
    await FirebaseFirestore.instance.collection('apps_analysis').doc('user1').set({
      'results': results,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _analyzedApps = results;
      _isLoading = false;
    });
  }

  String _updateRiskLevel(String current, String newLevel) {
    if (newLevel == "خطيرة") return "خطيرة";
    if (newLevel == "متوسطة" && current == "آمنة") return "متوسطة";
    return current;
  }

  void _showAppDetails(Map<String, dynamic> appData) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appData['appName']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("التصنيف: ${appData['classification']}"),
            if (appData['suspicious']) const Text("⚠️ تطبيق مشبوه", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            Text("الأذونات الممنوحة:"),
            for (var p in appData['permissions']) Text("• $p"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text("تعطيل الأذونات"),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.parse("package:${appData['package']}");
              await launchUrl(uri);
            },
            child: const Text("إلغاء التثبيت"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إغلاق"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تحليل التطبيقات المثبتة"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _analyzeInstalledApps,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _analyzedApps.length,
              itemBuilder: (context, index) {
                final app = _analyzedApps[index];
                return ListTile(
                  title: Text(app['appName']),
                  subtitle: Text("التصنيف: ${app['classification']}"),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () => _showAppDetails(app),
                );
              },
            ),
    );
  }
}
