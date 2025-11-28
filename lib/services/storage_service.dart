import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/qr_code_item.dart';

class StorageService {
  static const String _qrCodesKey = 'qr_codes';

  // Carregar QR codes guardados
  static Future<List<QRCodeItem>> loadQRCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? qrCodesJson = prefs.getString(_qrCodesKey);
    
    if (qrCodesJson != null) {
      final List<dynamic> decoded = json.decode(qrCodesJson);
      return decoded.map((item) => QRCodeItem.fromJson(item)).toList();
    }
    
    return [];
  }

  // Guardar QR codes
  static Future<void> saveQRCodes(List<QRCodeItem> qrCodes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      qrCodes.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_qrCodesKey, encoded);
  }
}