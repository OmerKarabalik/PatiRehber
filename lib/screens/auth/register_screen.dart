import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/auth_service.dart';
import '../../localization/app_language.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(appLang.translateDynamic('Kayıt Ol'))),
      body: Padding(
        padding: EdgeInsets.all(20.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: appLang.translateDynamic('E-posta')),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: appLang.translateDynamic('Şifre')),
              obscureText: true,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () async {
                var user = await _auth.registerWithEmailPassword(
                  _emailController.text,
                  _passwordController.text,
                );
                if (user == null) {
                  setState(() => _error = appLang.translateDynamic('Kayıt başarısız oldu. Geçerli bir e-posta girin.'));
                } else {
                  // Navigate to Home
                  Navigator.pop(context);
                }
              },
              child: Text(appLang.translateDynamic('Kayıt Ol')),
            ),
            SizedBox(height: 10.h),
            Text(_error, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}



