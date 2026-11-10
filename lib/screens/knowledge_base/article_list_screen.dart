import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../services/knowledge_base.dart';
import 'article_detail_screen.dart';

class ArticleListScreen extends StatelessWidget {
  final String petType;
  final String topic;

  ArticleListScreen({required this.petType, required this.topic});

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    final articles = KnowledgeBase.getArticlesByPetAndTopic(petType, topic);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('${appLang.translatePetType(petType)} ${appLang.translateDynamic(topic)}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: articles.isEmpty
          ? Center(child: Text(appLang.translateDynamic('İçerik bulunamadı.'), style: Theme.of(context).textTheme.bodyMedium))
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(color: AppTheme.divider),
                  ),
                  margin: EdgeInsets.only(bottom: 16.h),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)));
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.network(
                              article.imageUrl ?? '',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[300], child: Icon(Icons.image_not_supported, color: Colors.grey[500])),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appLang.translateDynamic(article.title), style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                                SizedBox(height: 6.h),
                                Text(appLang.translateDynamic(article.summary), style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}



