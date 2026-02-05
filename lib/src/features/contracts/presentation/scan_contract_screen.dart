import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vertragsmanager/src/features/contracts/domain/contract_parser.dart';
import 'package:vertragsmanager/src/features/contracts/presentation/contract_edit_screen.dart';

class ScanContractScreen extends StatefulWidget {
  final ImageSource source; 

  const ScanContractScreen({super.key, required this.source});

  @override
  State<ScanContractScreen> createState() => _ScanContractScreenState();
}

class _ScanContractScreenState extends State<ScanContractScreen> {
  String _statusText = "Modul wird geladen...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processFile();
    });
  }

  Future<void> _processFile() async {
    final ImagePicker picker = ImagePicker();
    
    setState(() {
      _statusText = widget.source == ImageSource.camera 
          ? "Kamera wird gestartet..." 
          : "Galerie wird geöffnet...";
    });

    try {
      final XFile? image = await picker.pickImage(source: widget.source);
      
      if (image == null) {
        if (mounted) Navigator.of(context).pop(); 
        return;
      }

      setState(() => _statusText = "Lese Text aus Bild...");

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String fullText = recognizedText.text;
      textRecognizer.close();

      setState(() => _statusText = "Suche Vertragsdaten...");
      
      // 1. Parser aufrufen (Hier holen wir alle Infos)
      final String parsedTitle = ContractParser.parseTitle(fullText);
      final double parsedPrice = ContractParser.parsePrice(fullText);
      final DateTime? parsedDate = ContractParser.parseDate(fullText);
      final String parsedCategory = ContractParser.parseCategory(parsedTitle);
      
      // NEU: Wir prüfen, ob es monatlich oder jährlich ist
      final bool parsedIsMonthly = ContractParser.parseIsMonthly(fullText);

      if (!mounted) return;

      // 2. Alles an den Edit-Screen übergeben
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ContractEditScreen(
            initialTitle: parsedTitle,
            initialPrice: parsedPrice,
            initialDate: parsedDate,
            initialCategory: parsedCategory,
            initialIsMonthly: parsedIsMonthly, // NEU: Hier geben wir die Info weiter
          ),
        ),
      );

    } catch (e) {
      setState(() => _statusText = "Fehler: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan läuft")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_statusText, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}