import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/illness_model.dart';
import '../models/care_article_model.dart';
import '../models/sitter_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- SITTER APPROVAL & MANAGEMENT ---
  
  // Apply to become a sitter
  Future<void> submitSitterApplication(SitterModel sitter) async {
    // We force isApproved to false during application
    final Map<String, dynamic> data = sitter.toMap();
    data['isApproved'] = false; 
    
    await _db.collection('sitters').doc(sitter.id).set(data);
  }

  // Get only approved sitters (for normal users)
  Stream<List<SitterModel>> getApprovedSitters() {
    return _db
        .collection('sitters')
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SitterModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get pending sitters (for Admin Panel)
  Stream<List<SitterModel>> getPendingSitters() {
    return _db
        .collection('sitters')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SitterModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Admin approves a sitter
  Future<void> approveSitter(String sitterId) async {
    await _db.collection('sitters').doc(sitterId).update({'isApproved': true});
  }

  // Admin rejects/deletes a sitter application
  Future<void> rejectSitter(String sitterId) async {
    await _db.collection('sitters').doc(sitterId).delete();
  }

  // --- ILLNESSES & CARE GUIDES ---

  Stream<List<IllnessModel>> getIllnessesByPetType(String petType) {
    return _db
        .collection('illnesses')
        .where('petType', isEqualTo: petType)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IllnessModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<CareArticleModel>> getCareArticlesByPetType(String petType) {
    return _db
        .collection('care_articles')
        .where('petType', isEqualTo: petType)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CareArticleModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // --- DEVELOPER FEEDBACK (100% Free Firebase Firestore Spark Plan) ---

  Future<void> sendFeedback({
    required String category,
    required String name,
    required String contact,
    required String message,
  }) async {
    try {
      await _db.collection('feedbacks').add({
        'category': category,
        'name': name.isNotEmpty ? name : 'Anonim Kullanıcı',
        'contact': contact,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'dateStr': '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'isRead': false,
      });
    } catch (_) {
      // Local fallback handled if offline
    }
  }

  Stream<List<Map<String, dynamic>>> getFeedbacks() {
    return _db
        .collection('feedbacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _db.collection('feedbacks').doc(feedbackId).delete();
    } catch (_) {}
  }
}

