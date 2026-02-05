import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importieren
import 'package:vertragsmanager/src/features/contracts/presentation/contract_edit_screen.dart';
import 'package:vertragsmanager/src/features/contracts/presentation/scan_contract_screen.dart'; // Importieren

class AddContractScreen extends StatelessWidget {
  const AddContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Neuen Vertrag hinzufügen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Button 1: Kamera Scan
            _BigButton(
              icon: Icons.camera_alt,
              text: "Vertrag scannen (Kamera)",
              color: Colors.blue.shade100,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // Wir geben 'ImageSource.camera' mit
                    builder: (context) => const ScanContractScreen(source: ImageSource.camera),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Button 2: Datei / Galerie Scan
            _BigButton(
              icon: Icons.image_search, // Icon geändert
              text: "Bild/Screenshot hochladen",
              color: Colors.green.shade100,
              onTap: () {
                 Navigator.of(context).push(
                  MaterialPageRoute(
                    // Wir geben 'ImageSource.gallery' mit
                    builder: (context) => const ScanContractScreen(source: ImageSource.gallery),
                  ),
                );
              },
            ),
             const SizedBox(height: 16),

            // Button 3: Manuell
            _BigButton(
              icon: Icons.edit,
              text: "Manuell eingeben",
              color: Colors.orange.shade100,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ContractEditScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ... _BigButton Klasse bleibt gleich wie vorher ...

// Hilfs-Widget für die fetten Buttons
class _BigButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _BigButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120, // Schön groß wie in der Skizze
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}