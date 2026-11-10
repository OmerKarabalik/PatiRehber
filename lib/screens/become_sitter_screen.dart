import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/firestore_service.dart';
import '../../models/sitter_model.dart';
import '../../localization/app_language.dart';
import 'package:uuid/uuid.dart';

class BecomeSitterScreen extends StatefulWidget {
  @override
  _BecomeSitterScreenState createState() => _BecomeSitterScreenState();
}

class _BecomeSitterScreenState extends State<BecomeSitterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestore = FirestoreService();
  
  String _name = '';
  String _bio = '';
  double _hourlyRate = 0.0;
  String _city = '';
  String _district = '';
  String _contactPhone = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(appLang.translateDynamic('Profesyonel Bakıcı Ol'))),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    appLang.translateDynamic('PatiRehber ailesine katılın! Başvurunuz yöneticilerimiz tarafından incelendikten sonra sistemde yer alacaktır.'),
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    decoration: InputDecoration(labelText: appLang.translateDynamic('Ad Soyad'), border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? appLang.translate('field_required') : null,
                    onSaved: (val) => _name = val!,
                  ),
                  SizedBox(height: 15.h),
                  TextFormField(
                    decoration: InputDecoration(labelText: appLang.translateDynamic('Kendinizden Bahsedin (Bio)'), border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (val) => val!.isEmpty ? appLang.translate('field_required') : null,
                    onSaved: (val) => _bio = val!,
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: appLang.translateDynamic('İl'), border: OutlineInputBorder()),
                          validator: (val) => val!.isEmpty ? appLang.translate('field_required') : null,
                          onSaved: (val) => _city = val!,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: appLang.translateDynamic('İlçe'), border: OutlineInputBorder()),
                          validator: (val) => val!.isEmpty ? appLang.translate('field_required') : null,
                          onSaved: (val) => _district = val!,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  TextFormField(
                    decoration: InputDecoration(labelText: appLang.translateDynamic('Saatlik Ücretiniz (₺)'), border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? appLang.translate('field_required') : null,
                    onSaved: (val) => _hourlyRate = double.tryParse(val!) ?? 0.0,
                  ),
                  SizedBox(height: 15.h),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: appLang.translateDynamic('Telefon Numaranız'), 
                      border: OutlineInputBorder(),
                      helperText: appLang.translateDynamic('Numaranız profilinizde GİZLİ kalacaktır. Sadece siz isterseniz mesajlarda paylaşabilirsiniz.'),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val!.isEmpty ? appLang.translate('field_required') : null,
                    onSaved: (val) => _contactPhone = val!,
                  ),
                  SizedBox(height: 30.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: _submitForm,
                    child: Text(appLang.translateDynamic('Başvuruyu Tamamla'), style: TextStyle(fontSize: 18.sp, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final sitter = SitterModel(
        id: Uuid().v4(),
        name: _name,
        bio: _bio,
        rating: 0.0,
        reviewsCount: 0,
        hourlyRate: _hourlyRate,
        city: _city,
        district: _district,
        services: ['Saatlik', 'Günlük'], // Varsayılan
        contactPhone: _contactPhone,
        avatarUrl: '', // Boş bırakılabilir
        isApproved: false, // Yönetici onayı bekleyecek
      );

      await _firestore.submitSitterApplication(sitter);

      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLanguage.of(context).translateDynamic('Başvurunuz başarıyla alındı! Yönetici onayından sonra listeleneceksiniz.'))),
      );
      Navigator.pop(context);
    }
  }
}



