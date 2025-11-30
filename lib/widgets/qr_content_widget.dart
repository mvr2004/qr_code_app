import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QRContentWidget extends StatelessWidget {
  final String content;
  final bool showPreview;
  final bool showActions;

  const QRContentWidget({
    super.key,
    required this.content,
    this.showPreview = true,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPreview) _buildContentPreview(context),
        if (showActions) ...[
          const SizedBox(height: 12),
          _buildActionButtons(context),
        ],
      ],
    );
  }

  Widget _buildContentPreview(BuildContext context) {
    final bool isUrl = _isUrl(content);
    final bool isEmail = _isEmail(content);
    final bool isPhone = _isPhone(content);
    final bool isWifi = _isWifiConfig(content);
    final bool isPassword = _containsPassword(content);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUrl) ...[
            _buildTypeIndicator(Icons.link, 'Link da Web', Colors.blue),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchUrl(content, context),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ] else if (isEmail) ...[
            _buildTypeIndicator(Icons.email, 'Endereço de Email', Colors.green),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchEmail(content, context),
              child: Text(
                content.replaceFirst('mailto:', ''),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ] else if (isPhone) ...[
            _buildTypeIndicator(Icons.phone, 'Número de Telefone', Colors.purple),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchPhone(content, context),
              child: Text(
                content.replaceFirst('tel:', ''),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.purple,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ] else if (isWifi) ...[
            _buildTypeIndicator(Icons.wifi, 'Configuração Wi-Fi', Colors.orange),
            const SizedBox(height: 8),
            Text(
              _parseWifiConfig(content),
              style: const TextStyle(fontSize: 14),
            ),
          ] else if (isPassword) ...[
            _buildTypeIndicator(Icons.security, 'Contém informação sensível', Colors.red),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ] else ...[
            SelectableText(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeIndicator(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool isUrl = _isUrl(content);
    final bool isEmail = _isEmail(content);
    final bool isPhone = _isPhone(content);

    if (!isUrl && !isEmail && !isPhone) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (isUrl) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(content, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Abrir Link'),
            ),
          ),
        ] else if (isEmail) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _launchEmail(content, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.email),
              label: const Text('Enviar Email'),
            ),
          ),
        ] else if (isPhone) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _launchPhone(content, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.phone),
              label: const Text('Ligar'),
            ),
          ),
        ],
      ],
    );
  }

  // Métodos de lançamento
  Future<void> _launchUrl(String url, BuildContext context) async {
    String formattedUrl = url;
    if (!url.toLowerCase().startsWith('http') && !url.toLowerCase().startsWith('www.')) {
      formattedUrl = 'https://$url';
    } else if (url.toLowerCase().startsWith('www.')) {
      formattedUrl = 'https://$url';
    }

    try {
      final Uri uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(context, 'Não foi possível abrir o link');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Link inválido');
    }
  }

  Future<void> _launchEmail(String email, BuildContext context) async {
    String formattedEmail = email;
    if (!email.toLowerCase().startsWith('mailto:')) {
      formattedEmail = 'mailto:$email';
    }

    try {
      final Uri uri = Uri.parse(formattedEmail);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(context, 'Não foi possível abrir o email');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Email inválido');
    }
  }

  Future<void> _launchPhone(String phone, BuildContext context) async {
    String formattedPhone = phone;
    if (!phone.toLowerCase().startsWith('tel:')) {
      formattedPhone = 'tel:$phone';
    }

    try {
      final Uri uri = Uri.parse(formattedPhone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(context, 'Não foi possível fazer a chamada');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Número de telefone inválido');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Métodos de deteção
  bool _isUrl(String text) {
    return text.toLowerCase().startsWith('http://') || 
           text.toLowerCase().startsWith('https://') ||
           text.toLowerCase().startsWith('www.') ||
           RegExp(r'\.(com|pt|org|net|io|app|dev|info)$', caseSensitive: false).hasMatch(text);
  }

  bool _isEmail(String text) {
    return text.toLowerCase().startsWith('mailto:') ||
           (RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text) && !text.contains(' '));
  }

  bool _isPhone(String text) {
    return text.toLowerCase().startsWith('tel:') ||
           RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$').hasMatch(text);
  }

  bool _isWifiConfig(String text) {
    return text.toLowerCase().startsWith('wifi:') ||
           (text.toLowerCase().contains('wpa') && text.toLowerCase().contains('ssid')) ||
           (text.toLowerCase().contains('wep') && text.toLowerCase().contains('ssid'));
  }

  bool _containsPassword(String text) {
    return text.toLowerCase().contains('password') ||
           text.toLowerCase().contains('senha') ||
           text.toLowerCase().contains('pass') ||
           text.toLowerCase().contains('pwd') ||
           text.toLowerCase().contains('secret') ||
           text.toLowerCase().contains('token') ||
           text.toLowerCase().contains('api_key');
  }

  String _parseWifiConfig(String text) {
    if (text.toLowerCase().startsWith('wifi:')) {
      final config = text.substring(5);
      final parts = config.split(';');
      
      String ssid = '';
      String password = '';
      
      for (final part in parts) {
        if (part.toLowerCase().startsWith('s:') || part.toLowerCase().startsWith('ssid:')) {
          ssid = part.substring(part.indexOf(':') + 1);
        } else if (part.toLowerCase().startsWith('p:') || part.toLowerCase().startsWith('pass:')) {
          password = part.substring(part.indexOf(':') + 1);
        }
      }
      
      return 'Rede: ${ssid.isNotEmpty ? ssid : 'Desconhecida'}${password.isNotEmpty ? '\nPassword: ••••••••' : '\nRede aberta'}';
    }
    
    return text;
  }
}