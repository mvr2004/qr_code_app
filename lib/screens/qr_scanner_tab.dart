import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/qr_code_item.dart';
import '../widgets/qr_content_widget.dart'; 

class QRScannerTab extends StatefulWidget {
  final Function(QRCodeItem) onQRCodeScanned;

  const QRScannerTab({super.key, required this.onQRCodeScanned});

  @override
  State<QRScannerTab> createState() => _QRScannerTabState();
}

class _QRScannerTabState extends State<QRScannerTab> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  bool _torchEnabled = false;
  String? _lastScannedCode;
  String? _scannedContent;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null && code.isNotEmpty && code != _lastScannedCode) {
      _isProcessing = true;
      _lastScannedCode = code;
      
      setState(() {
        _scannedContent = code;
      });

      cameraController.stop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('QR Code lido com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Fechar',
            onPressed: _resetScanner,
          ),
        ),
      );
    }
  }

  void _resetScanner() {
    setState(() {
      _scannedContent = null;
      _lastScannedCode = null;
      _isProcessing = false;
    });
    cameraController.start();
  }

  void _saveQRCode() {
    if (_scannedContent == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';

        return AlertDialog(
          title: const Text('Guardar QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QRContentWidget(
                content: _scannedContent!,
                showActions: false, // Não mostra ações no diálogo
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Título para guardar',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => title = value,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isEmpty) {
                  title = 'QR Code ${DateTime.now().toString().substring(0, 16)}';
                }

                final newQRCode = QRCodeItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  content: _scannedContent!,
                  createdAt: DateTime.now(),
                  color: Colors.green,
                  source: 'scanned',
                );

                widget.onQRCodeScanned(newQRCode);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('QR Code "$title" guardado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                _resetScanner();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: _handleBarcode,
        ),
        // ... (resto do scanner igual)
      ],
    );
  }

  Widget _buildResultView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Lido'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _resetScanner,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conteúdo lido:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QRContentWidget(
                      content: _scannedContent!,
                      showPreview: true,
                      showActions: false, // As ações vão nos botões abaixo
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botões de ação específicos do conteúdo
            QRContentWidget(
              content: _scannedContent!,
              showPreview: false, // Só mostra as ações
              showActions: true,
            ),
            
            const SizedBox(height: 12),
            
            // Botões principais
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ler Outro QR Code'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveQRCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar QR Code'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_scannedContent != null) {
      return _buildResultView();
    }
    
    return _buildScannerView();
  }
}