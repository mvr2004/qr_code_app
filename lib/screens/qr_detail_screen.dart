import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/qr_code_item.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/qr_content_widget.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';

class QRDetailScreen extends StatelessWidget {
  final QRCodeItem qrCode;

  const QRDetailScreen({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(qrCode.title),
        backgroundColor: qrCode.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareQRCode(context),
            tooltip: localization.translate('detail_share'),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyContent(context),
            tooltip: localization.translate('detail_copy'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // QR Code em grande
            _buildLargeQRCode(),
            const SizedBox(height: 30),
            
            // Informações do QR Code
            _buildQRCodeInfo(context),
            const SizedBox(height: 20),
            
            // Ações
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeQRCode() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: qrCode.color, width: 4),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: qrCode.color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: QrImageView(
          data: qrCode.content,
          version: QrVersions.auto,
          backgroundColor: Colors.white,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: qrCode.color,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: qrCode.color,
          ),
        ),
      ),
    );
  }

  Widget _buildQRCodeInfo(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              qrCode.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Usa o componente reutilizável
            QRContentWidget(
              content: qrCode.content,
              showPreview: true,
              showActions: false,
            ),
            
            const SizedBox(height: 16),
            
            // Informações adicionais
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${localization.translate('detail_created_at')} ${_formatDate(qrCode.createdAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.source, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${localization.translate('detail_source')} ${_getSourceLabel(qrCode.source, localization)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _copyContent(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.copy),
            label: Text(localization.translate('detail_copy_button')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _shareQRCode(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.share),
            label: Text(localization.translate('detail_share_button')),
          ),
        ),
      ],
    );
  }

  void _copyContent(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    
    Clipboard.setData(ClipboardData(text: qrCode.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localization.translate('detail_content_copied')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareQRCode(BuildContext context) {
    Share.share(
      'QR Code: ${qrCode.title}\nConteúdo: ${qrCode.content}',
      subject: 'QR Code: ${qrCode.title}',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getSourceLabel(String source, LocalizationService localization) {
    switch (source) {
      case 'scanned':
        return localization.translate('source_scanned');
      case 'generated':
        return localization.translate('source_generated');
      case 'manual':
        return localization.translate('source_manual');
      default:
        return source;
    }
  }
}