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
  final TextEditingController _searchController = TextEditingController();
  List<QRCodeItem> _filteredQRCodes = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredQRCodes = widget.qrCodes;
    _searchController.addListener(_filterQRCodes);
  }

  void _filterQRCodes() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      _isSearching = query.isNotEmpty;
      
      if (query.isEmpty) {
        _filteredQRCodes = widget.qrCodes;
      } else {
        _filteredQRCodes = widget.qrCodes.where((qrCode) {
          return qrCode.title.toLowerCase().contains(query) ||
                 qrCode.content.toLowerCase().contains(query) ||
                 qrCode.source.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _filteredQRCodes = widget.qrCodes;
    });
  }


  void _deleteQRCode(String id) {
    setState(() {
      widget.qrCodes.removeWhere((item) => item.id == id);
      _filterQRCodes(); // Atualiza a pesquisa
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
      body: Column(
        children: [
          // Barra de Pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por título, conteúdo...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // Indicador de resultados da pesquisa
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredQRCodes.length} resultado(s) encontrado(s)',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearSearch,
                    child: const Text('Limpar'),
                  ),
                ],
              ),
            ),

          // Lista de QR Codes
          Expanded(
            child: _filteredQRCodes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredQRCodes.length,
                    itemBuilder: (context, index) {
                      final qrCode = _filteredQRCodes[index];
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isSearching ? Icons.search_off : Icons.qr_code,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching ? 'Nenhum resultado encontrado' : 'Nenhum QR Code guardado',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Tente pesquisar com outros termos'
                // Atualizando a mensagem para não mencionar adição manual
                : 'Gere um QR Code ou leia com a câmera',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (_isSearching) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Limpar Pesquisa'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}