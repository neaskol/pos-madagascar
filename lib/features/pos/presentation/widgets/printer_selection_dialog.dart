import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../../data/services/thermal_printer_service.dart';

/// Dialog de sélection d'imprimante thermique - Phase 3.3
class PrinterSelectionDialog extends StatefulWidget {
  final ThermalPrinterService printerService;

  const PrinterSelectionDialog({
    super.key,
    required this.printerService,
  });

  @override
  State<PrinterSelectionDialog> createState() => _PrinterSelectionDialogState();
}

class _PrinterSelectionDialogState extends State<PrinterSelectionDialog> {
  List<BluetoothDevice> _availablePrinters = [];
  bool _isLoading = true;
  bool _isConnecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPrinters();
  }

  Future<void> _loadPrinters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final printers = await widget.printerService.getAvailablePrinters();
      setState(() {
        _availablePrinters = printers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la recherche: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _connectToPrinter(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.printerService.connect(device);
      if (success && mounted) {
        Navigator.of(context).pop(device);
      } else {
        setState(() {
          _errorMessage = 'Impossible de se connecter à l\'imprimante';
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sélectionner une imprimante'),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: _isConnecting ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        if (!_isLoading && !_isConnecting)
          TextButton.icon(
            onPressed: _loadPrinters,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    if (_availablePrinters.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 48,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune imprimante Bluetooth trouvée',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Assurez-vous que l\'imprimante est allumée et jumelée',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _availablePrinters.length,
      itemBuilder: (context, index) {
        final device = _availablePrinters[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.print,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(device.name ?? 'Imprimante inconnue'),
          subtitle: Text(device.address ?? ''),
          trailing: _isConnecting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          enabled: !_isConnecting,
          onTap: () => _connectToPrinter(device),
        );
      },
    );
  }
}
