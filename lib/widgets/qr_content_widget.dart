import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

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
  final QRType? forcedType;

  const QRContentWidget({
    super.key,
    required this.content,
    this.showPreview = true,
    this.showActions = true,
    this.forcedType,
  });

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    final QRType type = forcedType ?? _detectType(content);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPreview) _buildContentPreview(context, type, localization),
        if (showActions) ...[
          const SizedBox(height: 12),
          _buildActionButtons(context, type, localization),
        ],
      ],
    );
  }

  Widget _buildContentPreview(BuildContext context, QRType type, LocalizationService localization) {
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
          _buildTypeIndicator(type, localization),
          const SizedBox(height: 8),
          _buildFormattedContent(context, type, localization),
        ],
      ),
    );
  }

  Widget _buildTypeIndicator(QRType type, LocalizationService localization) {
    final Map<QRType, Map<String, dynamic>> typeInfo = {
      QRType.url: {
        'icon': Icons.link,
        'label': localization.translate('content_type_url'),
        'color': Colors.blue,
      },
      QRType.text: {
        'icon': Icons.text_snippet,
        'label': localization.translate('content_type_text'),
        'color': Colors.grey,
      },
      QRType.contact: {
        'icon': Icons.contact_page,
        'label': localization.translate('content_type_contact'),
        'color': Colors.purple,
      },
      QRType.wifi: {
        'icon': Icons.wifi,
        'label': localization.translate('content_type_wifi'),
        'color': Colors.orange,
      },
      QRType.location: {
        'icon': Icons.location_on,
        'label': localization.translate('content_type_location'),
        'color': Colors.red,
      },
      QRType.event: {
        'icon': Icons.event,
        'label': localization.translate('content_type_event'),
        'color': Colors.teal,
      },
      QRType.email: {
        'icon': Icons.email,
        'label': localization.translate('content_type_email'),
        'color': Colors.green,
      },
      QRType.sms: {
        'icon': Icons.sms,
        'label': localization.translate('content_type_sms'),
        'color': Colors.indigo,
      },
      QRType.payment: {
        'icon': Icons.payment,
        'label': localization.translate('content_type_payment'),
        'color': Colors.green.shade700,
      },
      QRType.phone: {
        'icon': Icons.phone,
        'label': localization.translate('content_type_phone'),
        'color': Colors.purple.shade700,
      },
      QRType.unknown: {
        'icon': Icons.qr_code,
        'label': localization.translate('content_type_unknown'),
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

  Widget _buildFormattedContent(BuildContext context, QRType type, LocalizationService localization) {
    switch (type) {
      case QRType.url:
        return GestureDetector(
          onTap: () => _launchUrl(content, context, localization),
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
          onTap: () => _launchEmail(content, context, localization),
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
          onTap: () => _launchPhone(content, context, localization),
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
              _parseWifiConfig(content, localization),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _parseWifiDetails(content, localization),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        );
      
      case QRType.contact:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _parseContactName(content, localization),
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
          onTap: () => _launchLocation(content, context, localization),
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
                localization.translate('content_tap_to_open_map'),
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
              _parseEventTitle(content, localization),
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
          onTap: () => _launchSMS(content, context, localization),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _parseSMS(content, localization),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.indigo,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                localization.translate('content_tap_to_send_sms'),
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
              _parsePaymentInfo(content, localization),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${localization.translate('content_payment_method')}: ${_parsePaymentMethod(content, localization)}',
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

  Widget _buildActionButtons(BuildContext context, QRType type, LocalizationService localization) {
    switch (type) {
      case QRType.url:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(content, context, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.open_in_browser),
                label: Text(localization.translate('action_open_link')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, content, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: Text(localization.translate('action_copy')),
              ),
            ),
          ],
        );
      
      case QRType.email:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchEmail(content, context, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.email),
                label: Text(localization.translate('action_send_email')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, _extractEmail(content), localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: Text(localization.translate('action_copy')),
              ),
            ),
          ],
        );
      
      case QRType.phone:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchPhone(content, context, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.phone),
                label: Text(localization.translate('action_call')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, _extractPhone(content), localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: Text(localization.translate('action_copy')),
              ),
            ),
          ],
        );
      
      case QRType.contact:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _saveContact(context, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.contact_page),
                label: Text(localization.translate('action_add_contact')),
              ),
            ),
          ],
        );
      
      case QRType.wifi:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _connectToWifi(context, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.wifi),
                label: Text(localization.translate('action_connect_wifi')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, content, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: Text(localization.translate('action_copy')),
              ),
            ),
          ],
        );
      
      case QRType.location:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchLocation(content, context, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.map),
                label: Text(localization.translate('action_open_map')),
              ),
            ),
          ],
        );
      
      case QRType.event:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addToCalendar(context, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.calendar_today),
                label: Text(localization.translate('action_add_calendar')),
              ),
            ),
          ],
        );
      
      case QRType.sms:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchSMS(content, context, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.sms),
                label: Text(localization.translate('action_send_sms')),
              ),
            ),
          ],
        );
      
      case QRType.payment:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _initiatePayment(context, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.payment),
                label: Text(localization.translate('action_pay')),
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
                onPressed: () => _copyToClipboard(context, content, localization),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: Text(localization.translate('action_copy_text')),
              ),
            ),
          ],
        );
    }
  }

  // DETECÇÃO DE TIPOS (mantém o mesmo)
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
           lower.contains('iban') ||
           lower.contains('bitcoin:') ||
           lower.contains('ethereum:') ||
           RegExp(r'^[a-z]{2,}://pay').hasMatch(lower);
  }

  // PARSERS PARA CADA TIPO - agora recebem LocalizationService como parâmetro
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

  String _parseWifiConfig(String text, LocalizationService localization) {
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
      
      final ssid = params['s'] ?? params['ssid'] ?? localization.translate('content_unknown');
      final hasPassword = params.containsKey('p') || params.containsKey('pass') || 
                         params.containsKey('psk') || params.containsKey('password');
      
      return '${localization.translate('content_network')}: $ssid\n${hasPassword ? localization.translate('content_with_password') : localization.translate('content_open_network')}';
    }
    return text;
  }

  String _parseWifiDetails(String text, LocalizationService localization) {
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
      return '${localization.translate('content_type')}: $security';
    }
    return '';
  }

  String _parseContactName(String text, LocalizationService localization) {
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
    return localization.translate('content_contact');
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

  String _parseEventTitle(String text, LocalizationService localization) {
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().startsWith('summary:')) {
        return line.substring(8);
      }
    }
    return localization.translate('content_event');
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

  String _parseSMS(String text, LocalizationService localization) {
    if (text.toLowerCase().startsWith('smsto:')) {
      final parts = text.substring(6).split(':');
      if (parts.length >= 2) {
        return '${localization.translate('content_to')}: ${parts[0]}\n${localization.translate('content_message')}: ${parts[1]}';
      }
      return text.substring(6);
    } else if (text.toLowerCase().startsWith('sms:')) {
      return text.substring(4);
    }
    return text;
  }

  String _parsePaymentInfo(String text, LocalizationService localization) {
    final lower = text.toLowerCase();
    if (lower.contains('mbway')) return localization.translate('payment_mbway');
    if (lower.contains('paypal')) return localization.translate('payment_paypal');
    if (lower.contains('bitcoin:')) return localization.translate('payment_bitcoin');
    if (lower.contains('ethereum:')) return localization.translate('payment_ethereum');
    if (lower.contains('iban')) return localization.translate('payment_bank_transfer');
    return localization.translate('content_payment');
  }

  String _parsePaymentMethod(String text, LocalizationService localization) {
    final lower = text.toLowerCase();
    if (lower.contains('mbway')) return localization.translate('payment_method_mbway');
    if (lower.contains('paypal')) return localization.translate('payment_method_paypal');
    if (lower.contains('bitcoin:')) return localization.translate('payment_method_crypto');
    if (lower.contains('ethereum:')) return localization.translate('payment_method_crypto');
    if (lower.contains('iban')) return localization.translate('payment_method_iban');
    return localization.translate('content_unknown');
  }

  // MÉTODOS DE AÇÃO - agora recebem LocalizationService como parâmetro
  Future<void> _launchUrl(String url, BuildContext context, LocalizationService localization) async {
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
        _showErrorSnackbar(context, localization.translate('error_cannot_open_link'), localization);
      }
    } catch (e) {
      _showErrorSnackbar(context, localization.translate('error_invalid_link'), localization);
    }
  }

  Future<void> _launchEmail(String email, BuildContext context, LocalizationService localization) async {
    String formattedEmail = email;
    if (!email.toLowerCase().startsWith('mailto:')) {
      formattedEmail = 'mailto:$email';
    }

    try {
      final Uri uri = Uri.parse(formattedEmail);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(context, localization.translate('error_cannot_open_email'), localization);
      }
    } catch (e) {
      _showErrorSnackbar(context, localization.translate('error_invalid_email'), localization);
    }
  }

  Future<void> _launchPhone(String phone, BuildContext context, LocalizationService localization) async {
    String formattedPhone = phone;
    if (!phone.toLowerCase().startsWith('tel:')) {
      formattedPhone = 'tel:$phone';
    }

    try {
      final Uri uri = Uri.parse(formattedPhone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(context, localization.translate('error_cannot_make_call'), localization);
      }
    } catch (e) {
      _showErrorSnackbar(context, localization.translate('error_invalid_phone'), localization);
    }
  }

  Future<void> _launchLocation(String location, BuildContext context, LocalizationService localization) async {
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
        _showErrorSnackbar(context, localization.translate('error_cannot_open_map'), localization);
      }
    } catch (e) {
      _showErrorSnackbar(context, localization.translate('error_invalid_location'), localization);
    }
  }

  Future<void> _launchSMS(String sms, BuildContext context, LocalizationService localization) async {
    String url = sms;
    
    if (!sms.toLowerCase().startsWith('smsto:') && !sms.toLowerCase().startsWith('sms:')) {
      url = 'sms:$sms';
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(context, localization.translate('error_cannot_open_sms'), localization);
      }
    } catch (e) {
      _showErrorSnackbar(context, localization.translate('error_invalid_sms'), localization);
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text, LocalizationService localization) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localization.translate('message_copied_to_clipboard')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveContact(BuildContext context, LocalizationService localization) {
    final name = _parseContactName(content, localization);
    final phone = _parseContactPhone(content);
    final email = _parseContactEmail(content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('dialog_contact_info')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localization.translate('content_name')}: $name', 
                 style: const TextStyle(fontWeight: FontWeight.bold)),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('${localization.translate('content_phone')}: $phone'),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _copyToClipboard(context, phone, localization);
                },
                icon: const Icon(Icons.copy, size: 16),
                label: Text(localization.translate('action_copy_phone')),
              ),
            ],
            if (email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('${localization.translate('content_email')}: $email'),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _copyToClipboard(context, email, localization);
                },
                icon: const Icon(Icons.copy, size: 16),
                label: Text(localization.translate('action_copy_email')),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('close')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(context, content, localization);
            },
            child: Text(localization.translate('action_copy_all')),
          ),
        ],
      ),
    );
  }

  void _connectToWifi(BuildContext context, LocalizationService localization) {
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
    
    final ssid = params['s'] ?? params['ssid'] ?? localization.translate('content_unknown');
    final password = params['p'] ?? params['pass'] ?? params['psk'] ?? params['password'] ?? '';
    final security = params['t'] ?? params['type'] ?? 'WPA/WPA2';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.wifi, color: Colors.orange),
            const SizedBox(width: 8),
            Text(localization.translate('dialog_wifi_config')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localization.translate('content_network')}: $ssid', 
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Text('${localization.translate('content_type')}: $security'),
            const SizedBox(height: 8),
            if (password.isNotEmpty) ...[
              Text('${localization.translate('content_password')}: $password'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _copyToClipboard(context, password, localization);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.copy),
                label: Text(localization.translate('action_copy_password')),
              ),
            ] else
              Text('🔓 ${localization.translate('content_open_network')}'),
            const SizedBox(height: 12),
            Text(
              localization.translate('message_wifi_manual_connect'),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('close')),
          ),
        ],
      ),
    );
  }

  void _addToCalendar(BuildContext context, LocalizationService localization) {
    final title = _parseEventTitle(content, localization);
    final details = _parseEventDetails(content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.event, color: Colors.teal),
            const SizedBox(width: 8),
            Text(localization.translate('dialog_event_details')),
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
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.teal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localization.translate('message_add_to_calendar_manual'),
                        style: const TextStyle(fontSize: 12, color: Colors.teal),
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
            child: Text(localization.translate('close')),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(context, content, localization);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy),
            label: Text(localization.translate('action_copy_details')),
          ),
        ],
      ),
    );
  }

  void _initiatePayment(BuildContext context, LocalizationService localization) {
    final paymentInfo = _parsePaymentInfo(content, localization);
    final method = _parsePaymentMethod(content, localization);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(localization.translate('dialog_payment_info')),
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
              Text('${localization.translate('content_payment_method')}: $method', 
                   style: const TextStyle(fontSize: 14)),
              const Divider(height: 24),
              Text(localization.translate('content_data'), 
                   style: const TextStyle(fontWeight: FontWeight.bold)),
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
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localization.translate('warning_check_payment_data'),
                        style: const TextStyle(fontSize: 12, color: Colors.red),
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
            child: Text(localization.translate('close')),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(context, content, localization);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy),
            label: Text(localization.translate('action_copy_data')),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message, LocalizationService localization) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}