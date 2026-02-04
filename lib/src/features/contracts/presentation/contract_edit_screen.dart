import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Wichtig
import 'package:intl/intl.dart';
// Für eindeutige IDs (optional, wir nutzen erstmal random String)
import 'package:vertragsmanager/src/features/contracts/domain/contract.dart';
import 'package:vertragsmanager/src/features/contracts/domain/contract_provider.dart';

// ÄNDERUNG 1: ConsumerStatefulWidget
class ContractEditScreen extends ConsumerStatefulWidget {
  const ContractEditScreen({super.key});

  @override
  ConsumerState<ContractEditScreen> createState() => _ContractEditScreenState();
}

// ÄNDERUNG 2: ConsumerState
class _ContractEditScreenState extends ConsumerState<ContractEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Abo';
  DateTime? _selectedDate;
  final List<String> _categories = ['Abo', 'Wohnen', 'Versicherung', 'Mobilität', 'Sonstiges'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveContract() {
    if (_formKey.currentState!.validate()) {
      // Preis als Double parsen (Komma durch Punkt ersetzen)
      final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
      
      // Neuen Vertrag erstellen
      final newContract = Contract(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID
        title: _titleController.text,
        price: price,
        category: _selectedCategory,
        endDate: _selectedDate,
      );

      // ÄNDERUNG 3: HIER SPEICHERN WIR ECHT!
      // Wir lesen den Provider (notifier) und rufen addContract auf.
      ref.read(contractProvider.notifier).addContract(newContract);
      
      // Zurück zur Liste
      Navigator.of(context).pop(); 
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vertrag erfolgreich hinzugefügt!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hier ist der UI Code genau gleich geblieben wie vorher
    return Scaffold(
      appBar: AppBar(title: const Text("Vertrag bearbeiten")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Name des Vertrags'),
                validator: (value) => value!.isEmpty ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Kosten (€)', suffixText: '€'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Kategorie'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Nächste Kündigungsfrist',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate == null ? 'Bitte Datum wählen' : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveContract,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text("SPEICHERN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}