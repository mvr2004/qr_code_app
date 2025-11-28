import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/qr_code_item.dart';

class QRDetailScreen extends StatelessWidget {
  final QRCodeItem qrCode;

  const QRDetailScreen({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(qrCode.title),
        backgroundColor: qrCode.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareQRCode(context),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyContent(context),
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
            _buildQRCodeInfo(),
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
      child: Stack(
        children: [
          // Fundo do QR Code
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
          ),
          
          // Ícone central do QR Code
          Center(
            child: Icon(
              Icons.qr_code_2,
              size: 150,
              color: qrCode.color,
            ),
          ),
          
          // Conteúdo no centro (se for pequeno)
          if (qrCode.content.length <= 50)
            Center(
              child: Text(
                qrCode.content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: qrCode.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // Padrões de QR Code simulados nos cantos
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: qrCode.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: qrCode.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: qrCode.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              qrCode.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Conteúdo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                qrCode.content,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Informações adicionais
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Criado em: ${_formatDate(qrCode.createdAt)}',
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
                  'Origem: ${_getSourceLabel(qrCode.source)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            
            // Tipo de conteúdo
            if (_isUrl(qrCode.content)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.link, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Link da Web',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ] else if (_isEmail(qrCode.content)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Endereço de Email',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ] else if (_isPhone(qrCode.content)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    'Número de Telefone',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
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
            label: const Text('Copiar Conteúdo'),
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
            label: const Text('Partilhar'),
          ),
        ),
      ],
    );
  }

  void _copyContent(BuildContext context) {
    Clipboard.setData(ClipboardData(text: qrCode.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conteúdo copiado para a área de transferência!'),
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

  String _getSourceLabel(String source) {
    switch (source) {
      case 'scanned':
        return 'Lido com câmera';
      case 'generated':
        return 'Gerado';
      case 'manual':
        return 'Adicionado manualmente';
      default:
        return source;
    }
  }

  bool _isUrl(String text) {
    return text.toLowerCase().startsWith('http://') || 
           text.toLowerCase().startsWith('https://') ||
           text.toLowerCase().startsWith('www.');
  }

  bool _isEmail(String text) {
    return text.toLowerCase().startsWith('mailto:') ||
           (text.contains('@') && text.contains('.'));
  }

  bool _isPhone(String text) {
    return text.toLowerCase().startsWith('tel:') ||
           RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$').hasMatch(text);
  }
}