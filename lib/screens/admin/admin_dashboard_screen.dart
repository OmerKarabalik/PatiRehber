import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/firestore_service.dart';
import '../../models/sitter_model.dart';
import '../../localization/app_language.dart';
import 'developer_inbox_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLang.translateDynamic('Yönetici Paneli')),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.mark_email_unread_rounded),
            tooltip: appLang.translateDynamic('Gelen Kutusu'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DeveloperInboxScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<SitterModel>>(
        stream: _firestore.getPendingSitters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final pendingSitters = snapshot.data ?? [];

          if (pendingSitters.isEmpty) {
            return Center(child: Text(appLang.translateDynamic('Bekleyen bakıcı başvurusu yok.')));
          }

          return ListView.builder(
            itemCount: pendingSitters.length,
            itemBuilder: (context, index) {
              final sitter = pendingSitters[index];
              return Card(
                margin: EdgeInsets.all(10.w),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(sitter.name),
                  subtitle: Text('${sitter.city} - ${sitter.district}\n${appLang.translateDynamic('Saatlik')}: ₺${sitter.hourlyRate}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          _firestore.approveSitter(sitter.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${sitter.name} - OK')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _firestore.rejectSitter(sitter.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${sitter.name} - Deleted')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



