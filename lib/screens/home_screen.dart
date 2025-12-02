import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qr_code_item.dart';
import '../services/storage_service.dart';
import '../services/localization_service.dart';
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

  void _showLanguageDialog() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.translate('language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇵🇹', style: TextStyle(fontSize: 30)),
                title: Text(localization.translate('portuguese')),
                trailing: localization.locale.languageCode == 'pt'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  localization.setLocale(const Locale('pt', 'PT'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 30)),
                title: Text(localization.translate('english')),
                trailing: localization.locale.languageCode == 'en'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  localization.setLocale(const Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localization.translate('close')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('app_title')),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageDialog,
            tooltip: localization.translate('language'),
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: localization.translate('tab_list'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code_scanner),
            label: localization.translate('tab_scan'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code),
            label: localization.translate('tab_generate'),
          ),
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