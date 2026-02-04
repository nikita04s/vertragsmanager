import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanContractScreen extends StatefulWidget {
  // Wir geben beim Starten mit, ob Kamera oder Galerie gewünscht ist
  final ImageSource source;

  const ScanContractScreen({super.key, required this.source});

  @override
  State<ScanContractScreen> createState() => _ScanContractScreenState();
}

class _ScanContractScreenState extends State<ScanContractScreen> {
  String _scannedText = "Starte Analyse...";
  bool _isScanning = true; // Wir starten sofort

  @override
  void initState() {
    super.initState();
    // Sofort beim Öffnen die Kamera/Galerie starten
    _scanDocument();
  }

  Future<void> _scanDocument() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: widget.source);
      
      if (photo == null) {
        // Wenn Nutzer abbricht, zurück zum Menü
        if (mounted) Navigator.of(context).pop();
        return;
      }

      setState(() {
        _isScanning = true;
        _scannedText = "Analysiere Bild...";
      });

      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      if (mounted) {
        setState(() {
          _scannedText = recognizedText.text.isEmpty 
              ? "Kein Text erkannt." 
              : recognizedText.text;
          _isScanning = false;
        });
      }
      textRecognizer.close();
    } catch (e) {
      if (mounted) {
        setState(() {
          _scannedText = "Fehler: $e";
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vertrag wird analysiert")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isScanning) const LinearProgressIndicator(),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(child: Text(_scannedText)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}