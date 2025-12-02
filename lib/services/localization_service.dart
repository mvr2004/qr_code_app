import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _locale = const Locale('pt', 'PT');

  Locale get locale => _locale;

  // Idiomas suportados
  static const List<Locale> supportedLocales = [
    Locale('pt', 'PT'),
    Locale('en', 'US'),
  ];

  // Inicializar o idioma guardado
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'pt';
    _locale = Locale(languageCode, languageCode == 'pt' ? 'PT' : 'US');
    notifyListeners();
  }

  // Alterar idioma
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }

  // Traduções - completas
  static final Map<String, Map<String, String>> _translations = {
    'app_title': {
      'pt': 'QR Code App',
      'en': 'QR Code App',
    },
    'tab_list': {
      'pt': 'Listagem',
      'en': 'List',
    },
    'tab_scan': {
      'pt': 'Ler QR',
      'en': 'Scan QR',
    },
    'tab_generate': {
      'pt': 'Gerar QR',
      'en': 'Generate QR',
    },
    'close': {
      'pt': 'Fechar',
      'en': 'Close',
    },
    'language': {
      'pt': 'Idioma',
      'en': 'Language',
    },
    'portuguese': {
      'pt': 'Português',
      'en': 'Portuguese',
    },
    'english': {
      'pt': 'Inglês',
      'en': 'English',
    },
    
    // QR Scanner Tab
    'scan_qr_code_scanned_successfully': {
      'pt': 'QR Code lido com sucesso!',
      'en': 'QR Code scanned successfully!',
    },
    'scan_close': {
      'pt': 'Fechar',
      'en': 'Close',
    },
    'scan_qr_code_color': {
      'pt': 'Cor do QR Code:',
      'en': 'QR Code Color:',
    },
    'scan_selected_color': {
      'pt': 'Cor selecionada:',
      'en': 'Selected color:',
    },
    'scan_save_title': {
      'pt': 'Título para guardar',
      'en': 'Title to save',
    },
    'scan_save_hint': {
      'pt': 'Ex: Website lido, Contacto, etc.',
      'en': 'Ex: Scanned website, Contact, etc.',
    },
    'scan_save_placeholder': {
      'pt': 'Deixe em branco para usar data/hora como título',
      'en': 'Leave blank to use date/time as title',
    },
    'scan_save_cancel': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'scan_save_save': {
      'pt': 'Guardar',
      'en': 'Save',
    },
    'scan_qr_saved_successfully': {
      'pt': 'QR Code "%s" guardado com sucesso!',
      'en': 'QR Code "%s" saved successfully!',
    },
    'scan_position_qr_code': {
      'pt': 'Posicione o QR Code dentro do retângulo',
      'en': 'Position the QR Code within the rectangle',
    },
    'scan_qr_code_read': {
      'pt': 'QR Code Lido',
      'en': 'QR Code Read',
    },
    'scan_content_read': {
      'pt': 'Conteúdo lido:',
      'en': 'Content read:',
    },
    'scan_read_another_qr': {
      'pt': 'Ler Outro QR Code',
      'en': 'Scan Another QR Code',
    },
    'scan_save_qr_code': {
      'pt': 'Guardar QR Code',
      'en': 'Save QR Code',
    },
    
    // QR List Tab
    'list_search_placeholder': {
      'pt': 'Pesquisar por título, conteúdo...',
      'en': 'Search by title, content...',
    },
    'list_search_clear': {
      'pt': 'Limpar',
      'en': 'Clear',
    },
    'list_results_found': {
      'pt': 'resultado(s) encontrado(s)',
      'en': 'result(s) found',
    },
    'list_no_results': {
      'pt': 'Nenhum resultado encontrado',
      'en': 'No results found',
    },
    'list_no_qr_codes': {
      'pt': 'Nenhum QR Code guardado',
      'en': 'No QR Codes saved',
    },
    'list_search_suggestions': {
      'pt': 'Tente pesquisar com outros termos',
      'en': 'Try searching with other terms',
    },
    'list_add_suggestions': {
      'pt': 'Gere um QR Code ou leia com a câmera',
      'en': 'Generate a QR Code or scan with camera',
    },
    'list_copy_content': {
      'pt': 'Copiar Conteúdo',
      'en': 'Copy Content',
    },
    'list_delete': {
      'pt': 'Eliminar',
      'en': 'Delete',
    },
    'list_content_copied': {
      'pt': 'Conteúdo copiado!',
      'en': 'Content copied!',
    },
    'list_qr_deleted_successfully': {
      'pt': 'QR Code removido com sucesso!',
      'en': 'QR Code deleted successfully!',
    },
    
    // QR Generator Tab
    'generate_qr_color': {
      'pt': 'Cor do QR Code:',
      'en': 'QR Code Color:',
    },
    'generate_title_label': {
      'pt': 'Título do QR Code *',
      'en': 'QR Code Title *',
    },
    'generate_title_hint': {
      'pt': 'Ex: Website pessoal, Contacto, etc.',
      'en': 'Ex: Personal website, Contact, etc.',
    },
    'generate_content_label': {
      'pt': 'Conteúdo do QR Code *',
      'en': 'QR Code Content *',
    },
    'generate_content_hint': {
      'pt': 'URL, texto, número, email, etc...',
      'en': 'URL, text, number, email, etc...',
    },
    'generate_save_button': {
      'pt': 'Gerar e Guardar QR Code',
      'en': 'Generate and Save QR Code',
    },
    'generate_clear_button': {
      'pt': 'Limpar Campos',
      'en': 'Clear Fields',
    },
    'generate_info_text': {
      'pt': 'O QR Code será guardado na lista e poderá ser visualizado '
          'na página de detalhes!',
      'en': 'The QR Code will be saved in the list and can be viewed '
          'on the details page!',
    },
    'generate_error_empty_text': {
      'pt': 'Por favor, digite algum texto para gerar o QR Code!',
      'en': 'Please enter some text to generate the QR Code!',
    },
    'generate_error_empty_title': {
      'pt': 'Por favor, adicione um título para o QR Code!',
      'en': 'Please add a title for the QR Code!',
    },
    'generate_success_message': {
      'pt': 'QR Code "%s" gerado e guardado com sucesso!',
      'en': 'QR Code "%s" generated and saved successfully!',
    },
    
    // QR Detail Screen
    'detail_share': {
      'pt': 'Partilhar',
      'en': 'Share',
    },
    'detail_copy': {
      'pt': 'Copiar',
      'en': 'Copy',
    },
    'detail_created_at': {
      'pt': 'Criado em:',
      'en': 'Created at:',
    },
    'detail_source': {
      'pt': 'Origem:',
      'en': 'Source:',
    },
    'detail_copy_button': {
      'pt': 'Copiar Conteúdo',
      'en': 'Copy Content',
    },
    'detail_share_button': {
      'pt': 'Partilhar',
      'en': 'Share',
    },
    'detail_content_copied': {
      'pt': 'Conteúdo copiado para a área de transferência!',
      'en': 'Content copied to clipboard!',
    },
    
    // Source labels
    'source_scanned': {
      'pt': 'Lido com câmera',
      'en': 'Scanned with camera',
    },
    'source_generated': {
      'pt': 'Gerado',
      'en': 'Generated',
    },
    'source_manual': {
      'pt': 'Adicionado manualmente',
      'en': 'Added manually',
    },
    
    // qrcontentwidjet
    'content_type_url': {
      'pt': 'Link da Web',
      'en': 'Web Link',
    },
    'content_type_text': {
      'pt': 'Texto Simples',
      'en': 'Plain Text',
    },
    'content_type_contact': {
      'pt': 'Contacto',
      'en': 'Contact',
    },
    'content_type_wifi': {
      'pt': 'Rede Wi-Fi',
      'en': 'Wi-Fi Network',
    },
    'content_type_location': {
      'pt': 'Localização',
      'en': 'Location',
    },
    'content_type_event': {
      'pt': 'Evento',
      'en': 'Event',
    },
    'content_type_email': {
      'pt': 'Email',
      'en': 'Email',
    },
    'content_type_sms': {
      'pt': 'SMS',
      'en': 'SMS',
    },
    'content_type_payment': {
      'pt': 'Pagamento',
      'en': 'Payment',
    },
    'content_type_phone': {
      'pt': 'Telefone',
      'en': 'Phone',
    },
    'content_type_unknown': {
      'pt': 'QR Code',
      'en': 'QR Code',
    },
    'content_tap_to_open_map': {
      'pt': 'Toque para abrir no mapa',
      'en': 'Tap to open in map',
    },
    'content_tap_to_send_sms': {
      'pt': 'Toque para enviar SMS',
      'en': 'Tap to send SMS',
    },
    'content_payment_method': {
      'pt': 'Método',
      'en': 'Method',
    },
    'content_unknown': {
      'pt': 'Desconhecida',
      'en': 'Unknown',
    },
    'content_network': {
      'pt': 'Rede',
      'en': 'Network',
    },
    'content_with_password': {
      'pt': '🔒 Com password',
      'en': '🔒 With password',
    },
    'content_open_network': {
      'pt': '🔓 Rede aberta',
      'en': '🔓 Open network',
    },
    'content_type': {
      'pt': 'Tipo',
      'en': 'Type',
    },
    'content_contact': {
      'pt': 'Contacto',
      'en': 'Contact',
    },
    'content_event': {
      'pt': 'Evento',
      'en': 'Event',
    },
    'content_to': {
      'pt': 'Para',
      'en': 'To',
    },
    'content_message': {
      'pt': 'Mensagem',
      'en': 'Message',
    },
    'payment_mbway': {
      'pt': 'MB Way',
      'en': 'MB Way',
    },
    'payment_paypal': {
      'pt': 'PayPal',
      'en': 'PayPal',
    },
    'payment_bitcoin': {
      'pt': 'Bitcoin',
      'en': 'Bitcoin',
    },
    'payment_ethereum': {
      'pt': 'Ethereum',
      'en': 'Ethereum',
    },
    'payment_bank_transfer': {
      'pt': 'Transferência Bancária',
      'en': 'Bank Transfer',
    },
    'content_payment': {
      'pt': 'Pagamento',
      'en': 'Payment',
    },
    'payment_method_mbway': {
      'pt': 'MB Way',
      'en': 'MB Way',
    },
    'payment_method_paypal': {
      'pt': 'PayPal',
      'en': 'PayPal',
    },
    'payment_method_crypto': {
      'pt': 'Criptomoeda',
      'en': 'Cryptocurrency',
    },
    'payment_method_iban': {
      'pt': 'IBAN',
      'en': 'IBAN',
    },
    'action_open_link': {
      'pt': 'Abrir Link',
      'en': 'Open Link',
    },
    'action_copy': {
      'pt': 'Copiar',
      'en': 'Copy',
    },
    'action_send_email': {
      'pt': 'Enviar Email',
      'en': 'Send Email',
    },
    'action_call': {
      'pt': 'Ligar',
      'en': 'Call',
    },
    'action_add_contact': {
      'pt': 'Adicionar Contacto',
      'en': 'Add Contact',
    },
    'action_connect_wifi': {
      'pt': 'Ligar ao Wi-Fi',
      'en': 'Connect to Wi-Fi',
    },
    'action_open_map': {
      'pt': 'Abrir no Mapa',
      'en': 'Open in Map',
    },
    'action_add_calendar': {
      'pt': 'Adicionar ao Calendário',
      'en': 'Add to Calendar',
    },
    'action_send_sms': {
      'pt': 'Enviar SMS',
      'en': 'Send SMS',
    },
    'action_pay': {
      'pt': 'Pagar',
      'en': 'Pay',
    },
    'action_copy_text': {
      'pt': 'Copiar Texto',
      'en': 'Copy Text',
    },
    'error_cannot_open_link': {
      'pt': 'Não foi possível abrir o link',
      'en': 'Could not open link',
    },
    'error_invalid_link': {
      'pt': 'Link inválido',
      'en': 'Invalid link',
    },
    'error_cannot_open_email': {
      'pt': 'Não foi possível abrir o email',
      'en': 'Could not open email',
    },
    'error_invalid_email': {
      'pt': 'Email inválido',
      'en': 'Invalid email',
    },
    'error_cannot_make_call': {
      'pt': 'Não foi possível fazer a chamada',
      'en': 'Could not make call',
    },
    'error_invalid_phone': {
      'pt': 'Número de telefone inválido',
      'en': 'Invalid phone number',
    },
    'error_cannot_open_map': {
      'pt': 'Não foi possível abrir o mapa',
      'en': 'Could not open map',
    },
    'error_invalid_location': {
      'pt': 'Localização inválida',
      'en': 'Invalid location',
    },
    'error_cannot_open_sms': {
      'pt': 'Não foi possível abrir o SMS',
      'en': 'Could not open SMS',
    },
    'error_invalid_sms': {
      'pt': 'SMS inválido',
      'en': 'Invalid SMS',
    },
    'message_copied_to_clipboard': {
      'pt': 'Copiado para a área de transferência',
      'en': 'Copied to clipboard',
    },
    'dialog_contact_info': {
      'pt': 'Informação do Contacto',
      'en': 'Contact Information',
    },
    'content_name': {
      'pt': 'Nome',
      'en': 'Name',
    },
    'content_phone': {
      'pt': 'Telefone',
      'en': 'Phone',
    },
    'action_copy_phone': {
      'pt': 'Copiar Telefone',
      'en': 'Copy Phone',
    },
    'content_email': {
      'pt': 'Email',
      'en': 'Email',
    },
    'action_copy_email': {
      'pt': 'Copiar Email',
      'en': 'Copy Email',
    },
    'action_copy_all': {
      'pt': 'Copiar Tudo',
      'en': 'Copy All',
    },
    'dialog_wifi_config': {
      'pt': 'Configuração Wi-Fi',
      'en': 'Wi-Fi Configuration',
    },
    'content_password': {
      'pt': 'Password',
      'en': 'Password',
    },
    'action_copy_password': {
      'pt': 'Copiar Password',
      'en': 'Copy Password',
    },
    'message_wifi_manual_connect': {
      'pt': 'Vá às definições Wi-Fi do seu dispositivo para conectar manualmente.',
      'en': 'Go to your device Wi-Fi settings to connect manually.',
    },
    'dialog_event_details': {
      'pt': 'Detalhes do Evento',
      'en': 'Event Details',
    },
    'message_add_to_calendar_manual': {
      'pt': 'Adicione manualmente ao calendário do seu dispositivo',
      'en': 'Add manually to your device calendar',
    },
    'action_copy_details': {
      'pt': 'Copiar Detalhes',
      'en': 'Copy Details',
    },
    'dialog_payment_info': {
      'pt': 'Informação de Pagamento',
      'en': 'Payment Information',
    },
    'content_data': {
      'pt': 'Dados',
      'en': 'Data',
    },
    'warning_check_payment_data': {
      'pt': 'Verifique sempre os dados antes de efetuar qualquer pagamento',
      'en': 'Always check data before making any payment',
    },
    'action_copy_data': {
      'pt': 'Copiar Dados',
      'en': 'Copy Data',
    },
    
  };

  String translate(String key, {String? replace}) {
    final translations = _translations[key];
    if (translations == null) return key;
    
    String text = translations[_locale.languageCode] ?? translations['pt'] ?? key;
    
    if (replace != null && text.contains('%s')) {
      text = text.replaceFirst('%s', replace);
    }
    
    return text;
  }
}