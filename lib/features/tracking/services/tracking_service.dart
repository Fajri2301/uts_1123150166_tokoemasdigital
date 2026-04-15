import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';

class TrackingService {
  final FirestoreService _firestoreService = FirestoreService();

  // Dapatkan transaksi user
  Stream<QuerySnapshot> getUserTransactions(String userId) {
    return _firestoreService.getUserTransactions(userId);
  }

  // Update status transaksi (admin only)
  Future<bool> updateTransactionStatus(String transactionId, String newStatus) async {
    try {
      await _firestoreService.updateDocument('transactions', transactionId, {
        'status': newStatus,
      });
      return true;
    } catch (e) {
      throw Exception('Gagal update status: $e');
    }
  }

  // Ambil detail transaksi
  Future<Map<String, dynamic>?> getTransactionDetail(String transactionId) async {
    try {
      final doc = await _firestoreService.getDocument('transactions', transactionId);
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Gagal ambil detail transaksi: $e');
    }
  }

  // Validasi status yang diperbolehkan
  List<String> getValidStatuses() {
    return ['pending', 'diproses', 'dikirim', 'selesai'];
  }

  // Dapatkan urutan status berdasarkan status saat ini
  List<String> getNextStatuses(String currentStatus) {
    List<String> allStatuses = ['diproses', 'dikirim', 'selesai'];
    int currentIndex = allStatuses.indexOf(currentStatus);
    if (currentIndex >= 0) {
      return allStatuses.sublist(currentIndex);
    }
    return allStatuses;
  }

  // Label status dalam bahasa Indonesia
  String getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  // Icon untuk setiap status
  String getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return 'pending';
      case 'diproses':
        return 'construction';
      case 'dikirim':
        return 'local_shipping';
      case 'selesai':
        return 'check_circle';
      default:
        return 'help';
    }
  }
}
