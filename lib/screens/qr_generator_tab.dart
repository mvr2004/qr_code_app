import 'package:flutter/material.dart';
import '../models/qr_code_item.dart';

class QRGeneratorTab extends StatefulWidget {
  final Function(QRCodeItem) onQRCodeGenerated;

  const QRGeneratorTab({super.key, required this.onQRCodeGenerated});

  @override
  State<QRGeneratorTab> createState() => _QRGeneratorTabState();
}

class _QRGeneratorTabState extends State<QRGeneratorTab> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String _qrData = '';
  Color _qrColor = Colors.black;
  double _qrSize = 200.0;

  final List<Color> _availableColors = [
    Colors.black,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
  ];

  void _generateQRCode() {
    final text = _textController.text.trim();
    final title = _titleController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite algum texto para gerar o QR Code!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, adicione um título para o QR Code!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _qrData = text;
    });

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
        content: Text('QR Code "$title" gerado e guardado com sucesso!'),
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
      _qrData = '';
    });
  }

  Widget _buildQRCodePreview() {
    if (_qrData.isEmpty) {
      return Container(
        width: _qrSize,
        height: _qrSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_2, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'QR Code aparecerá aqui',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      width: _qrSize,
      height: _qrSize,
      decoration: BoxDecoration(
        border: Border.all(color: _qrColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.qr_code_2,
              size: _qrSize * 0.7,
              color: _qrColor,
            ),
          ),
          Center(
            child: Text(
              'QR Code\n$_qrData',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _qrColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título do QR Code *',
              hintText: 'Ex: Website pessoal, Contacto, etc.',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Conteúdo do QR Code *',
              hintText: 'URL, texto, número, email, etc...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cor do QR Code:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          const Text(
            'Tamanho do QR Code:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _qrSize,
            min: 150.0,
            max: 300.0,
            divisions: 5,
            label: _qrSize.round().toString(),
            onChanged: (value) {
              setState(() {
                _qrSize = value;
              });
            },
          ),
          const SizedBox(height: 30),
          Center(
            child: _buildQRCodePreview(),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _generateQRCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.qr_code_2),
            label: const Text(
              'Gerar e Guardar QR Code',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _clearFields,
            icon: const Icon(Icons.clear),
            label: const Text('Limpar Campos'),
          ),
          const SizedBox(height: 20),
          const Card(
            color: Colors.blueAccent,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'O QR Code será automaticamente guardado e ficará disponível '
                'mesmo após fechar a aplicação!',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
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