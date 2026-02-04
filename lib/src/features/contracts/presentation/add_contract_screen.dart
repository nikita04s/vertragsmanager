import 'package:flutter/material.dart';
import 'package:vertragsmanager/src/features/contracts/presentation/contract_edit_screen.dart';

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
            // Button 1: Kamera
            _BigButton(
              icon: Icons.camera_alt,
              text: "Kamera Scan",
              color: Colors.blue.shade100,
              onTap: () {
                // Später: Kamera Logik
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Kamera-Feature kommt später!")),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Button 2: Manuell
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
            const SizedBox(height: 16),

            // Button 3: Datei
            _BigButton(
              icon: Icons.upload_file,
              text: "Datei hochladen",
              color: Colors.green.shade100,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Datei-Upload kommt später!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

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