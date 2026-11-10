import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../localization/app_language.dart';
import '../models/global_state.dart';
import 'ad_service.dart';

class PdfPassportService {
  /// Generates the PDF document bytes for a pet's health passport
  static Future<Uint8List> generatePassportBytes({
    required Map<String, dynamic> pet,
    List<Map<String, dynamic>>? vaccines,
    List<Map<String, dynamic>>? healthRecords,
    String? languageCode,
  }) async {
    final pdf = pw.Document();

    // Use Roboto font from Google Fonts for full Turkish and international UTF-8 support
    pw.Font regularFont;
    pw.Font boldFont;
    try {
      regularFont = await PdfGoogleFonts.robotoRegular();
      boldFont = await PdfGoogleFonts.robotoBold();
    } catch (_) {
      regularFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    final petName = pet['name']?.toString() ?? 'İsimsiz';
    final petType = pet['type']?.toString() ?? 'Köpek';
    final breed = pet['breed']?.toString() ?? 'Belirtilmedi';
    final gender = pet['gender']?.toString() ?? 'Erkek';
    final birthDate = pet['birthDate']?.toString() ?? '-';
    final age = pet['age']?.toString() ?? '-';
    final weight = (pet['weight'] != null) ? '${pet['weight']} kg' : '-';
    final chipNo = pet['chipNo']?.toString() ?? 'TR-KAYITSIZ';
    final bloodType = pet['bloodType']?.toString() ?? '-';
    final isNeutered = pet['isNeutered'] == true ? 'Evet / Yes' : 'Hayır / No';
    final allergies = pet['allergies']?.toString() ?? 'Yok / None';
    final notes = pet['notes']?.toString() ?? '-';

    final petVaccines = vaccines ?? [];
    final petRecords = healthRecords ?? [];

    final primaryColor = PdfColor.fromHex('#1B5E20');
    final accentColor = PdfColor.fromHex('#2E7D32');
    final goldColor = PdfColor.fromHex('#D4AF37');
    final darkText = PdfColor.fromHex('#1A202C');
    final lightBg = PdfColor.fromHex('#F4F7F6');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          return [
            // Header Certificate Banner
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              padding: const pw.EdgeInsets.all(16),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FixedColumnWidth(55),
                },
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  pw.TableRow(
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PATİREHBER DİJİTAL SAĞLIK SİSTEMİ',
                            style: pw.TextStyle(
                              color: goldColor,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.2,
                              font: boldFont,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'ULUSLARARASI EVCİL HAYVAN SAĞLIK & AŞI PASAPORTU',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'INTERNATIONAL PET HEALTH & VACCINATION CERTIFICATE',
                            style: const pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        width: 50,
                        height: 50,
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: 'PATIREHBER:CHIP=$chipNo;PET=$petName;VET=VERIFIED',
                          color: PdfColors.white,
                          drawText: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // Pet Identification Card
            pw.Container(
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              padding: const pw.EdgeInsets.all(12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Text(
                            '1. KİMLİK & MİKROÇİP BİLGİLERİ (IDENTIFICATION)',
                            style: pw.TextStyle(
                              color: primaryColor,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9.5,
                              font: boldFont,
                            ),
                          ),
                          pw.Text(
                            'Mikroçip No: $chipNo',
                            style: pw.TextStyle(
                              color: primaryColor,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9.5,
                              font: boldFont,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Divider(color: PdfColors.grey300, thickness: 0.8),
                  pw.SizedBox(height: 4),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          _buildPdfInfoCell('İsim (Name):', petName, boldFont),
                          _buildPdfInfoCell('Tür (Species):', petType, boldFont),
                          _buildPdfInfoCell('Irk (Breed):', breed, boldFont),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _buildPdfInfoCell('Cinsiyet (Gender):', gender, boldFont),
                          _buildPdfInfoCell('Doğum Tarihi (Birth):', birthDate, boldFont),
                          _buildPdfInfoCell('Yaş (Age):', age, boldFont),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _buildPdfInfoCell('Ağırlık (Weight):', weight, boldFont),
                          _buildPdfInfoCell('Kısırlaştırma (Neutered):', isNeutered, boldFont),
                          _buildPdfInfoCell('Kan Grubu (Blood Type):', bloodType, boldFont),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // Medical Warning / Allergies Box
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFF9C4'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColor.fromHex('#FBC02D')),
              ),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'DİKKAT / TIBBİ UYARI: ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        color: PdfColor.fromHex('#D84315'),
                        font: boldFont,
                      ),
                    ),
                    pw.TextSpan(
                      text: 'Alerjiler: $allergies | Notlar: $notes',
                      style: pw.TextStyle(fontSize: 8.5, color: darkText),
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 14),

            // Section 2: Vaccination Schedule Table
            pw.Text(
              '2. AŞI VE PARAZİT UYGULAMA KAYITLARI (VACCINATION REGISTRY)',
              style: pw.TextStyle(
                color: primaryColor,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
            pw.SizedBox(height: 6),

            if (petVaccines.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Center(
                  child: pw.Text('Henüz kayıtlı aşı bulunmamaktadır.', style: const pw.TextStyle(fontSize: 9)),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.7),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: accentColor),
                    children: [
                      _buildTableHeaderCell('Aşı Adı / Vaccine'),
                      _buildTableHeaderCell('Uygulama Tarihi / Date'),
                      _buildTableHeaderCell('Hekim / Klinik / Vet'),
                      _buildTableHeaderCell('Durum / Status'),
                    ],
                  ),
                  ...petVaccines.map((v) {
                    final status = v['status']?.toString() ?? 'Tamamlandı';
                    final isDone = status.toLowerCase().contains('tamam') || status.toLowerCase().contains('done');
                    return pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.white),
                      children: [
                        _buildTableCell(v['title']?.toString() ?? '-'),
                        _buildTableCell(v['date']?.toString() ?? '-'),
                        _buildTableCell(v['vet']?.toString() ?? 'Patili Klinik'),
                        _buildTableCell(
                          status,
                          textColor: isDone ? PdfColor.fromHex('#2E7D32') : PdfColor.fromHex('#E65100'),
                          bold: true,
                        ),
                      ],
                    );
                  }),
                ],
              ),

            pw.SizedBox(height: 14),

            // Section 3: Recent Medical Records (if available)
            if (petRecords.isNotEmpty) ...[
              pw.Text(
                '3. GEÇMİŞ SAĞLIK KAYITLARI & MUAYENELER (MEDICAL HISTORY)',
                style: pw.TextStyle(
                  color: primaryColor,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.7),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(4.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: accentColor),
                    children: [
                      _buildTableHeaderCell('İşlem / Muayene'),
                      _buildTableHeaderCell('Tarih'),
                      _buildTableHeaderCell('Açıklama & Teşhis Detayı'),
                    ],
                  ),
                  ...petRecords.take(5).map((r) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(r['title']?.toString() ?? '-'),
                        _buildTableCell(r['date']?.toString() ?? '-'),
                        _buildTableCell(r['notes']?.toString() ?? r['clinic']?.toString() ?? '-'),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 14),
            ],

            // Section 4: Emergency Contacts & Official Stamp
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FixedColumnWidth(16),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ACİL İLETİŞİM & YARDIM (EMERGENCY CONTACTS)',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: primaryColor, font: boldFont),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text('• 153 Hayvan Ambulansı (7/24 Ücretsiz Belediye Acil Müdahale)', style: const pw.TextStyle(fontSize: 8)),
                          pw.Text('• PatiRehber Acil Nöbetçi Veteriner Canlı Harita Takibi', style: const pw.TextStyle(fontSize: 8)),
                          pw.Text('• Doğrulama Kodu: PTR-${petName.toUpperCase()}-${DateTime.now().year}', style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                      pw.Container(
                        width: 1,
                        height: 40,
                        color: PdfColors.grey300,
                        margin: const pw.EdgeInsets.symmetric(horizontal: 7),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'HEKİM ONAYI / VET STAMP',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.grey700, font: boldFont),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Container(
                            width: 80,
                            height: 28,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey400, style: pw.BorderStyle.dashed),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.Center(
                              child: pw.Text('Kaşe & İmza', style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 7)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // Footer
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Bu belge PatiRehber Dijital Sağlık Platformu tarafından resmi formatta üretilmiştir.',
                      style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 7),
                    ),
                    pw.Text(
                      'Sayfa 1 / 1  •  Tarih: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                      style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 7),
                      textAlign: pw.TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfInfoCell(String label, String value, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label ',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, font: boldFont),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {PdfColor? textColor, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: textColor ?? PdfColors.black,
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Opens the interactive PDF viewer with print & share options
  static Future<void> showPdfPreview(
    BuildContext context, {
    required Map<String, dynamic> pet,
    List<Map<String, dynamic>>? vaccines,
    List<Map<String, dynamic>>? healthRecords,
  }) async {
    final petName = pet['name']?.toString() ?? 'Dostum';
    final appLang = AppLanguage.of(context);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: Text(
              '$petName • ${appLang.translate('digital_passport')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                tooltip: appLang.translate('share'),
                onPressed: () async {
                  final bytes = await generatePassportBytes(
                    pet: pet,
                    vaccines: vaccines,
                    healthRecords: healthRecords,
                  );
                  await Printing.sharePdf(
                    bytes: bytes,
                    filename: 'PatiRehber_${petName}_Saglik_Pasaportu.pdf',
                  );
                },
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => generatePassportBytes(
              pet: pet,
              vaccines: vaccines,
              healthRecords: healthRecords,
            ),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            pdfFileName: 'PatiRehber_${petName}_Saglik_Pasaportu.pdf',
          ),
        ),
      ),
    );
  }

  /// Shows the rewarded video unlock dialog before displaying the PDF
  static void showRewardedPdfFlow(
    BuildContext context, {
    required Map<String, dynamic> pet,
    List<Map<String, dynamic>>? vaccines,
    List<Map<String, dynamic>>? healthRecords,
  }) {
    final petName = pet['name']?.toString() ?? 'Dostum';
    final appLang = AppLanguage.of(context, listen: false);
    final pdfPrice = appLang.priceSinglePdf;

    // PatiPlus Destekçisi ise reklam/ödül penceresini atlayıp doğrudan aç
    if (GlobalState.isPatiPlus) {
      showPdfPreview(
        context,
        pet: pet,
        vaccines: vaccines,
        healthRecords: healthRecords,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF1B5E20), size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$petName • ${appLang.translate('pdf_modal_title')}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appLang.translate('pdf_modal_subtitle'),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.video_library_rounded, color: Color(0xFF2E7D32), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        appLang.translate('pdf_modal_info'),
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF1B5E20), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Button 1: Watch Video & Open PDF (Google AdMob Rewarded Video)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(bottomSheetCtx);
                    AdService.showRewardedAd(
                      context: context,
                      onUserEarnedReward: () {
                        showPdfPreview(
                          context,
                          pet: pet,
                          vaccines: vaccines,
                          healthRecords: healthRecords,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 22),
                  label: Text(
                    appLang.translate('pdf_watch_ad_btn'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Button 2: Voluntary Developer Support (Price Localized)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(bottomSheetCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF1B5E20),
                        content: Text(appLang.translate('pdf_thank_you_support')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    showPdfPreview(
                      context,
                      pet: pet,
                      vaccines: vaccines,
                      healthRecords: healthRecords,
                    );
                  },
                  icon: const Icon(Icons.bolt_rounded, color: Color(0xFFE67E22), size: 22),
                  label: Text(
                    appLang.translate('pdf_support_dev_btn').replaceAll('{price}', pdfPrice),
                    style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE67E22), width: 1.3),
                    backgroundColor: const Color(0xFFFFF8E1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Button 3: Direct Open (or Skip)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(bottomSheetCtx);
                    showPdfPreview(
                      context,
                      pet: pet,
                      vaccines: vaccines,
                      healthRecords: healthRecords,
                    );
                  },
                  child: Text(
                    appLang.translate('pdf_direct_open_btn'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
  }
}
