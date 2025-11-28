import 'package:flutter/material.dart';
import '../models/qr_code_item.dart';
import '../services/storage_service.dart';
import 'qr_list_tab.dart';
import 'qr_scanner_tab.dart';
import 'qr_generator_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<QRCodeItem> _savedQRCodes = [];
  late List<Widget> _tabs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedQRCodes();
  }

  Future<void> _loadSavedQRCodes() async {
    final qrCodes = await StorageService.loadQRCodes();
    setState(() {
      _savedQRCodes.clear();
      _savedQRCodes.addAll(qrCodes);
    });
    
    _initializeTabs();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveQRCodes() async {
    await StorageService.saveQRCodes(_savedQRCodes);
  }

  void _initializeTabs() {
    _tabs = [
      QRListTab(
        qrCodes: _savedQRCodes,
        onDelete: _saveQRCodes,
        onAdd: _saveQRCodes,
      ),
      QRScannerTab(
        onQRCodeScanned: (qrCode) {
          setState(() {
            _savedQRCodes.add(qrCode);
          });
          _saveQRCodes();
          _currentIndex = 0;
        },
      ),
      QRGeneratorTab(
        onQRCodeGenerated: (qrCode) {
          setState(() {
            _savedQRCodes.add(qrCode);
          });
          _saveQRCodes();
          _currentIndex = 0;
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code App'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Listagem'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Ler QR'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Gerar QR'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}