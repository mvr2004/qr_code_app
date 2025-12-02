import 'package:flutter/material.dart';
import '../models/qr_code_item.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';

class QRGeneratorTab extends StatefulWidget {
  final Function(QRCodeItem) onQRCodeGenerated;

  const QRGeneratorTab({super.key, required this.onQRCodeGenerated});

  @override
  State<QRGeneratorTab> createState() => _QRGeneratorTabState();
}

class _QRGeneratorTabState extends State<QRGeneratorTab> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  Color _qrColor = Colors.blue;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  void _generateQRCode() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    
    final text = _textController.text.trim();
    final title = _titleController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('generate_error_empty_text')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('generate_error_empty_title')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newQRCode = QRCodeItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: text,
      createdAt: DateTime.now(),
      color: _qrColor,
      source: 'generated',
    );

    widget.onQRCodeGenerated(newQRCode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localization.translate('generate_success_message', replace: title)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    _clearFields();
  }

  void _clearFields() {
    setState(() {
      _textController.clear();
      _titleController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cor do QR Code
          Text(
            localization.translate('generate_qr_color'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableColors.length,
              itemBuilder: (context, index) {
                final color = _availableColors[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _qrColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _qrColor == color ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: _qrColor == color
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Título
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: localization.translate('generate_title_label'),
              hintText: localization.translate('generate_title_hint'),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Conteúdo
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: localization.translate('generate_content_label'),
              hintText: localization.translate('generate_content_hint'),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 30),

          // Botões de ação
          ElevatedButton.icon(
            onPressed: _generateQRCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.qr_code_2),
            label: Text(
              localization.translate('generate_save_button'),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _clearFields,
            icon: const Icon(Icons.clear),
            label: Text(localization.translate('generate_clear_button')),
          ),

          // Informação
          const SizedBox(height: 20),
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    localization.translate('generate_info_text'),
                    style: const TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}