import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import 'article_list_screen.dart';

class PetSelectionScreen extends StatelessWidget {
  final String topic;

  PetSelectionScreen({required this.topic});

  final List<Map<String, String>> pets = [
    {'name': 'Köpek', 'image': 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=400'},
    {'name': 'Kedi', 'image': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=400'},
    {'name': 'Kuş', 'image': 'https://images.unsplash.com/photo-1552728089-57105a832560?auto=format&fit=crop&q=80&w=400'},
    {'name': 'Balık', 'image': 'https://images.unsplash.com/photo-1524704796725-9fc3044a58b2?auto=format&fit=crop&q=80&w=400'},
    {'name': 'Kemirgen', 'image': 'https://images.unsplash.com/photo-1425082661705-1834bfd0999c?auto=format&fit=crop&q=80&w=400'},
  ];

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('${appLang.translateDynamic(topic)} - ${appLang.translateDynamic('Tür Seçimi')}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            elevation: 0,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleListScreen(petType: pet['name']!, topic: topic),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(
                    image: NetworkImage(pet['image']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  appLang.translatePetType(pet['name']!),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



