import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/qr_code_item.dart';
import '../widgets/qr_content_widget.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';

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
      
      final localization = Provider.of<LocalizationService>(context, listen: false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('scan_qr_code_scanned_successfully')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: localization.translate('scan_close'),
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

  Widget _buildColorSelector({
    required Color selectedColor,
    required Function(Color) onColorChanged,
  }) {
    final localization = Provider.of<LocalizationService>(context);
    
    final List<Color> availableColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.lightGreen,
      Colors.deepOrange,
      Colors.deepPurple,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.translate('scan_qr_code_color'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              return GestureDetector(
                onTap: () {
                  onColorChanged(color);
                },
                child: Container(
                  width: 45,
                  height: 45,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor == color ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: selectedColor == color
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${localization.translate('scan_selected_color')} ${selectedColor.value.toRadixString(16).toUpperCase()}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _saveQRCode() {
    if (_scannedContent == null) return;

    final localization = Provider.of<LocalizationService>(context, listen: false);
    
    // Variáveis locais para o diálogo
    Color selectedColor = Colors.green;
    String title = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(localization.translate('scan_save_button')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QRContentWidget(
                      content: _scannedContent!,
                      showActions: false,
                    ),
                    const SizedBox(height: 16),
                    
                    // Seletor de cor DENTRO do diálogo
                    _buildColorSelector(
                      selectedColor: selectedColor,
                      onColorChanged: (newColor) {
                        setStateDialog(() {
                          selectedColor = newColor;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: localization.translate('scan_save_title'),
                        border: const OutlineInputBorder(),
                        hintText: localization.translate('scan_save_hint'),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => title = value,
                      autofocus: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localization.translate('scan_save_placeholder'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localization.translate('scan_save_cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.isEmpty) {
                      final now = DateTime.now();
                      title = 'QR Code ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}';
                    }

                    final newQRCode = QRCodeItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      content: _scannedContent!,
                      createdAt: DateTime.now(),
                      color: selectedColor,
                      source: 'scanned',
                    );

                    widget.onQRCodeScanned(newQRCode);
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localization.translate('scan_qr_saved_successfully', replace: title)),
                        backgroundColor: selectedColor,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    
                    _resetScanner();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                  ),
                  child: Text(
                    localization.translate('scan_save_save'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildScannerView() {
    final localization = Provider.of<LocalizationService>(context);
    
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: _handleBarcode,
        ),
        // Overlay com guias de scanner
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
        // Retângulo de scanner
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Botões de controle
        Positioned(
          top: 50,
          right: 20,
          child: IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                _torchEnabled = !_torchEnabled;
              });
              cameraController.toggleTorch();
            },
          ),
        ),
        // Instruções
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
              const SizedBox(height: 10),
              Text(
                localization.translate('scan_position_qr_code'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final localization = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('scan_qr_code_read')),
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
                    Text(
                      localization.translate('scan_content_read'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QRContentWidget(
                      content: _scannedContent!,
                      showPreview: true,
                      showActions: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botões de ação específicos do conteúdo
            QRContentWidget(
              content: _scannedContent!,
              showPreview: false,
              showActions: true,
            ),
            
            const SizedBox(height: 20),
            
            // Botões principais
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(localization.translate('scan_read_another_qr')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveQRCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.save),
                    label: Text(localization.translate('scan_save_qr_code')),
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