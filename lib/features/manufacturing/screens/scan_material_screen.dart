import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_app/features/inventory/providers/inventory_provider.dart';
import 'package:smartfab_app/routes.dart';

class ScanMaterialScreen extends StatefulWidget {
  const ScanMaterialScreen({Key? key}) : super(key: key);

  @override
  State<ScanMaterialScreen> createState() => _ScanMaterialScreenState();
}

class _ScanMaterialScreenState extends State<ScanMaterialScreen> {
  bool _isScanning = false;
  String? _scannedCode;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Start scanning automatically when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanBarcode();
    });
  }
  
  Future<void> _scanBarcode() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });
    
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666',
        'Cancel',
        true,
        ScanMode.QR,
      );
      
      if (barcodeScanRes != '-1') { // -1 is returned when user cancels
        setState(() {
          _scannedCode = barcodeScanRes;
        });
        
        // Process the scanned code
        await _processScan(barcodeScanRes);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error scanning barcode: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }
  
  Future<void> _processScan(String code) async {
    try {
      // Assuming the QR code contains a material ID
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      final material = await inventoryProvider.getMaterialById(code);
      
      if (material != null) {
        if (mounted) {
          // Navigate to material details
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.materialDetails,
            arguments: {'materialId': material.id},
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Material not found for code: $code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing scan: ${e.toString()}';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Material'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: _isScanning ? Theme.of(context).primaryColor : Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                _isScanning
                    ? 'Scanning...'
                    : _scannedCode != null
                        ? 'Code Scanned'
                        : 'Ready to Scan',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (_scannedCode != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Scanned Code:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _scannedCode!,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(_scannedCode != null ? 'Scan Again' : 'Start Scan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
