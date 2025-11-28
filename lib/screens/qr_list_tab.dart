import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/qr_code_item.dart';
import 'qr_detail_screen.dart';

class QRListTab extends StatefulWidget {
  final List<QRCodeItem> qrCodes;
  final VoidCallback onDelete;
  final VoidCallback onAdd;

  const QRListTab({
    super.key,
    required this.qrCodes,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  State<QRListTab> createState() => _QRListTabState();
}

class _QRListTabState extends State<QRListTab> {
  void _addQRCode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String content = '';

        return AlertDialog(
          title: const Text('Adicionar QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Conteúdo',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => content = value,
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
                if (title.isNotEmpty && content.isNotEmpty) {
                  final newQRCode = QRCodeItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    content: content,
                    createdAt: DateTime.now(),
                    color: _getRandomColor(widget.qrCodes.length),
                    source: 'manual',
                  );
                  
                  setState(() {
                    widget.qrCodes.add(newQRCode);
                  });
                  widget.onAdd();
                  
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('QR Code "$title" adicionado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteQRCode(String id) {
    setState(() {
      widget.qrCodes.removeWhere((item) => item.id == id);
    });
    widget.onDelete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code removido com sucesso!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showQRCodeDetails(QRCodeItem qrCode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRDetailScreen(qrCode: qrCode),
      ),
    );
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

  Color _getRandomColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.qrCodes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum QR Code guardado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gere um QR Code, leia com a câmera\nou adicione manualmente',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: widget.qrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = widget.qrCodes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: qrCode.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: qrCode.color),
                      ),
                      child: Icon(
                        qrCode.source == 'scanned'
                            ? Icons.qr_code_scanner
                            : Icons.qr_code,
                        color: qrCode.color,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      qrCode.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          qrCode.content.length > 30
                              ? '${qrCode.content.substring(0, 30)}...'
                              : qrCode.content,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(qrCode.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteQRCode(qrCode.id);
                        } else if (value == 'copy') {
                          Clipboard.setData(ClipboardData(text: qrCode.content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Conteúdo copiado!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(Icons.copy, size: 20),
                              SizedBox(width: 8),
                              Text('Copiar Conteúdo'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showQRCodeDetails(qrCode),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQRCode,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}