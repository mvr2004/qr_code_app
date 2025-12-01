import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

enum QRType {
  url,
  text,
  contact,
  wifi,
  location,
  event,
  email,
  sms,
  payment,
  phone,
  unknown
}

class QRContentWidget extends StatelessWidget {
  final String content;
  final bool showPreview;
  final bool showActions;
  final QRType? forcedType; // Para forçar um tipo específico

  const QRContentWidget({
    super.key,
    required this.content,
    this.showPreview = true,
    this.showActions = true,
    this.forcedType,
  });

  @override
  Widget build(BuildContext context) {
    final QRType type = forcedType ?? _detectType(content);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPreview) _buildContentPreview(context, type),
        if (showActions) ...[
          const SizedBox(height: 12),
          _buildActionButtons(context, type),
        ],
      ],
    );
  }

  Widget _buildContentPreview(BuildContext context, QRType type) {
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
          // Indicador do tipo
          _buildTypeIndicator(type),
          const SizedBox(height: 8),
          
          // Conteúdo formatado conforme o tipo
          _buildFormattedContent(context, type),
        ],
      ),
    );
  }

  Widget _buildTypeIndicator(QRType type) {
    final Map<QRType, Map<String, dynamic>> typeInfo = {
      QRType.url: {
        'icon': Icons.link,
        'label': 'Link da Web',
        'color': Colors.blue,
      },
      QRType.text: {
        'icon': Icons.text_snippet,
        'label': 'Texto Simples',
        'color': Colors.grey,
      },
      QRType.contact: {
        'icon': Icons.contact_page,
        'label': 'Contacto',
        'color': Colors.purple,
      },
      QRType.wifi: {
        'icon': Icons.wifi,
        'label': 'Rede Wi-Fi',
        'color': Colors.orange,
      },
      QRType.location: {
        'icon': Icons.location_on,
        'label': 'Localização',
        'color': Colors.red,
      },
      QRType.event: {
        'icon': Icons.event,
        'label': 'Evento',
        'color': Colors.teal,
      },
      QRType.email: {
        'icon': Icons.email,
        'label': 'Email',
        'color': Colors.green,
      },
      QRType.sms: {
        'icon': Icons.sms,
        'label': 'SMS',
        'color': Colors.indigo,
      },
      QRType.payment: {
        'icon': Icons.payment,
        'label': 'Pagamento',
        'color': Colors.green.shade700,
      },
      QRType.phone: {
        'icon': Icons.phone,
        'label': 'Telefone',
        'color': Colors.purple.shade700,
      },
      QRType.unknown: {
        'icon': Icons.qr_code,
        'label': 'QR Code',
        'color': Colors.grey,
      },
    };

    final info = typeInfo[type] ?? typeInfo[QRType.unknown]!;
    
    return Row(
      children: [
        Icon(info['icon'] as IconData, color: info['color'] as Color, size: 16),
        const SizedBox(width: 4),
        Text(
          info['label'] as String,
          style: TextStyle(
            color: info['color'] as Color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFormattedContent(BuildContext context, QRType type) {
    switch (type) {
      case QRType.url:
        return GestureDetector(
          onTap: () => _launchUrl(content, context),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      
      case QRType.email:
        return GestureDetector(
          onTap: () => _launchEmail(content, context),
          child: Text(
            _extractEmail(content),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.green,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      
      case QRType.phone:
        return GestureDetector(
          onTap: () => _launchPhone(content, context),
          child: Text(
            _extractPhone(content),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.purple,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      
      case QRType.wifi:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _parseWifiConfig(content),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _parseWifiDetails(content),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        );
      
      case QRType.contact:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _parseContactName(content),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (_parseContactPhone(content).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '📱 ${_parseContactPhone(content)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (_parseContactEmail(content).isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '✉️ ${_parseContactEmail(content)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        );
      
      case QRType.location:
        return GestureDetector(
          onTap: () => _launchLocation(content, context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _parseLocation(content),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Toque para abrir no mapa',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      
      case QRType.event:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _parseEventTitle(content),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _parseEventDetails(content),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      
      case QRType.sms:
        return GestureDetector(
          onTap: () => _launchSMS(content, context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _parseSMS(content),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.indigo,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Toque para enviar SMS',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      
      case QRType.payment:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _parsePaymentInfo(content),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Método: ${_parsePaymentMethod(content)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      
      case QRType.text:
      case QRType.unknown:
      default:
        return SelectableText(
          content,
          style: const TextStyle(fontSize: 14),
        );
    }
  }

  Widget _buildActionButtons(BuildContext context, QRType type) {
    switch (type) {
      case QRType.url:
        return Row(
          children: [
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
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, content),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
            ),
          ],
        );
      
      case QRType.email:
        return Row(
          children: [
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
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, _extractEmail(content)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
            ),
          ],
        );
      
      case QRType.phone:
        return Row(
          children: [
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
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, _extractPhone(content)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
            ),
          ],
        );
      
      case QRType.contact:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _saveContact(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.contact_page),
                label: const Text('Adicionar Contacto'),
              ),
            ),
          ],
        );
      
      case QRType.wifi:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _connectToWifi(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.wifi),
                label: const Text('Ligar ao Wi-Fi'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, content),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
            ),
          ],
        );
      
      case QRType.location:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchLocation(content, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.map),
                label: const Text('Abrir no Mapa'),
              ),
            ),
          ],
        );
      
      case QRType.event:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addToCalendar(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Adicionar ao Calendário'),
              ),
            ),
          ],
        );
      
      case QRType.sms:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchSMS(content, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.sms),
                label: const Text('Enviar SMS'),
              ),
            ),
          ],
        );
      
      case QRType.payment:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _initiatePayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.payment),
                label: const Text('Pagar'),
              ),
            ),
          ],
        );
      
      case QRType.text:
      case QRType.unknown:
      default:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, content),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copiar Texto'),
              ),
            ),
          ],
        );
    }
  }

  // DETECÇÃO DE TIPOS
  QRType _detectType(String text) {
    if (_isUrl(text)) return QRType.url;
    if (_isEmail(text)) return QRType.email;
    if (_isPhone(text)) return QRType.phone;
    if (_isWifiConfig(text)) return QRType.wifi;
    if (_isContact(text)) return QRType.contact;
    if (_isLocation(text)) return QRType.location;
    if (_isEvent(text)) return QRType.event;
    if (_isSMS(text)) return QRType.sms;
    if (_isPayment(text)) return QRType.payment;
    return QRType.text;
  }

  bool _isUrl(String text) {
    final lower = text.toLowerCase();
    return lower.startsWith('http://') || 
           lower.startsWith('https://') ||
           lower.startsWith('www.') ||
           RegExp(r'^[a-zA-Z0-9]+\.[a-zA-Z]{2,}(/.*)?$').hasMatch(text) ||
           RegExp(r'\.(com|pt|org|net|io|app|dev|info|br|uk|fr|de|es|it)$', caseSensitive: false).hasMatch(text);
  }

  bool _isEmail(String text) {
    return text.toLowerCase().startsWith('mailto:') ||
           RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(text);
  }

  bool _isPhone(String text) {
    return text.toLowerCase().startsWith('tel:') ||
           RegExp(r'^[\+]?[0-9\s\-\(\)]{8,20}$').hasMatch(text.replaceAll(' ', ''));
  }

  bool _isWifiConfig(String text) {
    final lower = text.toLowerCase();
    return lower.startsWith('wifi:') ||
           (lower.contains('ssid') && (lower.contains('pass') || lower.contains('psk')));
  }

  bool _isContact(String text) {
    final lower = text.toLowerCase();
    return lower.contains('begin:vcard') ||
           lower.contains('mecard:') ||
           lower.contains('n:') ||
           lower.contains('tel:') && lower.contains('email:') ||
           lower.startsWith('vcard');
  }

  bool _isLocation(String text) {
    final lower = text.toLowerCase();
    return lower.startsWith('geo:') ||
           lower.contains('maps.google.com') ||
           lower.contains('maps.apple.com') ||
           (RegExp(r'^-?\d+\.\d+,\s*-?\d+\.\d+$').hasMatch(text) && !lower.contains('http'));
  }

  bool _isEvent(String text) {
    final lower = text.toLowerCase();
    return lower.contains('begin:vevent') ||
           lower.contains('summary:') && lower.contains('dtstart:') ||
           lower.startsWith('vevent');
  }

  bool _isSMS(String text) {
    return text.toLowerCase().startsWith('smsto:') ||
           text.toLowerCase().startsWith('sms:');
  }

  bool _isPayment(String text) {
    final lower = text.toLowerCase();
    return lower.contains('mbway') ||
           lower.contains('paypal') ||
           lower.contains('pix') ||
           lower.contains('iban') ||
           lower.contains('bitcoin:') ||
           lower.contains('ethereum:') ||
           RegExp(r'^[a-z]{2,}://pay').hasMatch(lower);
  }

  // PARSERS PARA CADA TIPO
  String _extractEmail(String text) {
    if (text.toLowerCase().startsWith('mailto:')) {
      return text.substring(7);
    }
    return text;
  }

  String _extractPhone(String text) {
    if (text.toLowerCase().startsWith('tel:')) {
      return text.substring(4);
    }
    return text;
  }

  String _parseWifiConfig(String text) {
    if (text.toLowerCase().startsWith('wifi:')) {
      final config = text.substring(5);
      final Map<String, String> params = {};
      
      for (final param in config.split(';')) {
        if (param.contains(':')) {
          final parts = param.split(':');
          if (parts.length >= 2) {
            params[parts[0].toLowerCase()] = parts.sublist(1).join(':');
          }
        }
      }
      
      final ssid = params['s'] ?? params['ssid'] ?? 'Desconhecida';
      final hasPassword = params.containsKey('p') || params.containsKey('pass') || 
                         params.containsKey('psk') || params.containsKey('password');
      
      return 'Rede: $ssid\n${hasPassword ? '🔒 Com password' : '🔓 Rede aberta'}';
    }
    return text;
  }

  String _parseWifiDetails(String text) {
    if (text.toLowerCase().startsWith('wifi:')) {
      final config = text.substring(5);
      final Map<String, String> params = {};
      
      for (final param in config.split(';')) {
        if (param.contains(':')) {
          final parts = param.split(':');
          if (parts.length >= 2) {
            params[parts[0].toLowerCase()] = parts.sublist(1).join(':');
          }
        }
      }
      
      final security = params['t'] ?? params['type'] ?? 'WPA/WPA2';
      return 'Tipo: $security';
    }
    return '';
  }

  String _parseContactName(String text) {
    if (text.toLowerCase().contains('begin:vcard')) {
      final lines = text.split('\n');
      for (final line in lines) {
        if (line.toLowerCase().startsWith('n:')) {
          final parts = line.substring(2).split(';');
          if (parts.length >= 2) {
            return '${parts[1]} ${parts[0]}'.trim();
          }
        }
      }
    } else if (text.toLowerCase().startsWith('mecard:')) {
      final content = text.substring(7);
      final params = content.split(';');
      for (final param in params) {
        if (param.toLowerCase().startsWith('n:')) {
          return param.substring(2);
        }
      }
    }
    return 'Contacto';
  }

  String _parseContactPhone(String text) {
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().startsWith('tel:')) {
        return line.substring(4);
      }
    }
    return '';
  }

  String _parseContactEmail(String text) {
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().startsWith('email:')) {
        return line.substring(6);
      }
    }
    return '';
  }

  String _parseLocation(String text) {
    if (text.toLowerCase().startsWith('geo:')) {
      final coords = text.substring(4).split(',');
      if (coords.length >= 2) {
        return '${coords[0]}, ${coords[1]}';
      }
    }
    return text;
  }

  String _parseEventTitle(String text) {
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().startsWith('summary:')) {
        return line.substring(8);
      }
    }
    return 'Evento';
  }

  String _parseEventDetails(String text) {
    String date = '';
    String location = '';
    
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().startsWith('dtstart:')) {
        date = line.substring(8);
      } else if (line.toLowerCase().startsWith('location:')) {
        location = line.substring(9);
      }
    }
    
    String result = '';
    if (date.isNotEmpty) {
      result += '📅 $date\n';
    }
    if (location.isNotEmpty) {
      result += '📍 $location';
    }
    return result;
  }

  String _parseSMS(String text) {
    if (text.toLowerCase().startsWith('smsto:')) {
      final parts = text.substring(6).split(':');
      if (parts.length >= 2) {
        return 'Para: ${parts[0]}\nMensagem: ${parts[1]}';
      }
      return text.substring(6);
    } else if (text.toLowerCase().startsWith('sms:')) {
      return text.substring(4);
    }
    return text;
  }

  String _parsePaymentInfo(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('mbway')) return 'MB Way';
    if (lower.contains('paypal')) return 'PayPal';
    if (lower.contains('pix')) return 'PIX Brasil';
    if (lower.contains('bitcoin:')) return 'Bitcoin';
    if (lower.contains('ethereum:')) return 'Ethereum';
    if (lower.contains('iban')) return 'Transferência Bancária';
    return 'Pagamento';
  }

  String _parsePaymentMethod(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('mbway')) return 'MB Way';
    if (lower.contains('paypal')) return 'PayPal';
    if (lower.contains('pix')) return 'PIX';
    if (lower.contains('bitcoin:')) return 'Criptomoeda';
    if (lower.contains('ethereum:')) return 'Criptomoeda';
    if (lower.contains('iban')) return 'IBAN';
    return 'Desconhecido';
  }

  // MÉTODOS DE AÇÃO
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

  Future<void> _launchLocation(String location, BuildContext context) async {
    String url = location;
    
    if (location.toLowerCase().startsWith('geo:')) {
      final coords = location.substring(4).split(',');
      if (coords.length >= 2) {
        url = 'https://maps.google.com/maps?q=${coords[0]},${coords[1]}';
      }
    } else if (!location.toLowerCase().startsWith('http')) {
      url = 'https://maps.google.com/maps?q=$location';
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(context, 'Não foi possível abrir o mapa');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Localização inválida');
    }
  }

  Future<void> _launchSMS(String sms, BuildContext context) async {
    String url = sms;
    
    if (!sms.toLowerCase().startsWith('smsto:') && !sms.toLowerCase().startsWith('sms:')) {
      url = 'sms:$sms';
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(context, 'Não foi possível abrir o SMS');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'SMS inválido');
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copiado para a área de transferência'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveContact(BuildContext context) {
  // Extrair informações do contacto
  final name = _parseContactName(content);
  final phone = _parseContactPhone(content);
  final email = _parseContactEmail(content);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
        title: const Text('Informação do Contacto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: $name', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Telefone: $phone'),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _copyToClipboard(context, phone);
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copiar Telefone'),
              ),
            ],
            if (email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Email: $email'),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _copyToClipboard(context, email);
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copiar Email'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(context, content);
            },
            child: const Text('Copiar Tudo'),
          ),
        ],
      ),
    );
  }

    void _connectToWifi(BuildContext context) {
    // Extrair informações do Wi-Fi
    final config = content.substring(5);
    final Map<String, String> params = {};
    
    for (final param in config.split(';')) {
      if (param.contains(':')) {
        final parts = param.split(':');
        if (parts.length >= 2) {
          params[parts[0].toLowerCase()] = parts.sublist(1).join(':');
        }
      }
    }
    
    final ssid = params['s'] ?? params['ssid'] ?? 'Desconhecida';
    final password = params['p'] ?? params['pass'] ?? params['psk'] ?? params['password'] ?? '';
    final security = params['t'] ?? params['type'] ?? 'WPA/WPA2';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi, color: Colors.orange),
            SizedBox(width: 8),
            Text('Configuração Wi-Fi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rede: $ssid', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Text('Tipo: $security'),
            const SizedBox(height: 8),
            if (password.isNotEmpty) ...[
              Text('Password: $password'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _copyToClipboard(context, password);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copiar Password'),
              ),
            ] else
              const Text('🔓 Rede sem password'),
            const SizedBox(height: 12),
            const Text(
              'Vá às definições Wi-Fi do seu dispositivo para conectar manualmente.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

    void _addToCalendar(BuildContext context) {
    final title = _parseEventTitle(content);
    final details = _parseEventDetails(content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.event, color: Colors.teal),
            SizedBox(width: 8),
            Text('Detalhes do Evento'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Divider(height: 24),
              if (details.isNotEmpty) ...[
                Text(details),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.teal, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Adicione manualmente ao calendário do seu dispositivo',
                        style: TextStyle(fontSize: 12, color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(context, content);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy),
            label: const Text('Copiar Detalhes'),
          ),
        ],
      ),
    );
  }

 void _initiatePayment(BuildContext context) {
    final paymentInfo = _parsePaymentInfo(content);
    final method = _parsePaymentMethod(content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text('Informação de Pagamento'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paymentInfo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text('Método: $method', style: const TextStyle(fontSize: 14)),
              const Divider(height: 24),
              const Text('Dados:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  content,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verifique sempre os dados antes de efetuar qualquer pagamento',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(context, content);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy),
            label: const Text('Copiar Dados'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}