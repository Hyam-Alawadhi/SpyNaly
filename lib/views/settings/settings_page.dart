import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_spynaly/Themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("إعدادات التطبيق", textDirection: TextDirection.rtl),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
  title: const Text("الوضع الداكن"),
  value: Provider.of<ThemeProvider>(context).isDarkMode,
  onChanged: (value) {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
  },
),
            ListTile(
              title: const Text("اللغة"),
              subtitle: const Text("العربية"),
              onTap: () {
                // لاحقًا نضيف دعم تغيير اللغة
              },
            ),
          ],
        ),
      ),
    );
  }
}
