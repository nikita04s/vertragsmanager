import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vertragsmanager/src/features/contracts/presentation/contract_edit_screen.dart';
import 'package:vertragsmanager/src/features/contracts/presentation/scan_contract_screen.dart';

class AddContractScreen extends StatelessWidget {
  const AddContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(title: const Text("Hinzufügen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _ActionCard(
              icon: CupertinoIcons.camera_viewfinder,
              title: "Vertrag scannen",
              subtitle: "Foto oder Dokument",
              color: Colors.blue,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ScanContractScreen(source: ImageSource.camera)),
              ),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: CupertinoIcons.photo,
              title: "Aus Galerie wählen",
              subtitle: "Screenshot importieren",
              color: Colors.purple,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ScanContractScreen(source: ImageSource.gallery)),
              ),
            ),
             const SizedBox(height: 12),
            _ActionCard(
              icon: CupertinoIcons.pencil,
              title: "Manuell erstellen",
              subtitle: "Daten selbst eingeben",
              color: Colors.orange,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ContractEditScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(20),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black)),
                Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ],
            ),
            const Spacer(),
            Icon(CupertinoIcons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}