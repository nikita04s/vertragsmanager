import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vertragsmanager/src/features/contracts/domain/contract.dart';
import 'package:vertragsmanager/src/features/contracts/domain/contract_provider.dart';

class ContractEditScreen extends ConsumerStatefulWidget {
  // Wenn diese ID gesetzt ist, bearbeiten wir einen existierenden Vertrag
  final String? existingId; 
  
  final String? initialTitle;
  final double? initialPrice;
  final DateTime? initialDate;
  final String? initialCategory;
  final bool? initialIsMonthly;

  const ContractEditScreen({
    super.key,
    this.existingId, // NEU
    this.initialTitle,
    this.initialPrice,
    this.initialDate,
    this.initialCategory,
    this.initialIsMonthly,
  });

  @override
  ConsumerState<ContractEditScreen> createState() => _ContractEditScreenState();
}

class _ContractEditScreenState extends ConsumerState<ContractEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _priceController;

  String _selectedCategory = 'Abo';
  DateTime? _selectedDate;
  bool _isMonthly = true; 

  final List<String> _categories = [
    'Abo', 'Wohnen', 'Versicherung', 'Mobilität', 'Sonstiges'
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.initialTitle ?? '');

    String priceText = '';
    if (widget.initialPrice != null && widget.initialPrice! > 0) {
      priceText = widget.initialPrice!.toStringAsFixed(2).replaceAll('.', ',');
    }
    _priceController = TextEditingController(text: priceText);

    _selectedDate = widget.initialDate;

    if (widget.initialCategory != null && _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }
    
    if (widget.initialIsMonthly != null) {
      _isMonthly = widget.initialIsMonthly!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate = _selectedDate ?? DateTime.now().add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000), 
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveContract() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;

      // ENTSCHEIDUNG: Update oder Neu?
      if (widget.existingId != null) {
        // --- UPDATE ---
        final updatedContract = Contract(
          id: widget.existingId!, // Wir behalten die alte ID!
          title: _titleController.text,
          price: price,
          category: _selectedCategory,
          endDate: _selectedDate,
          isMonthly: _isMonthly,
        );
        ref.read(contractProvider.notifier).updateContract(updatedContract);
      } else {
        // --- NEU ERSTELLEN ---
        final newContract = Contract(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          price: price,
          category: _selectedCategory,
          endDate: _selectedDate,
          isMonthly: _isMonthly,
        );
        ref.read(contractProvider.notifier).addContract(newContract);
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existingId != null ? 'Änderungen gespeichert!' : 'Vertrag erstellt!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Titel passt sich an
        title: Text(widget.existingId != null ? "Vertrag bearbeiten" : "Neuer Vertrag"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Name des Vertrags', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Kosten (€)', suffixText: '€', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SwitchListTile(
                  title: Text(_isMonthly ? "Zahlung: Monatlich" : "Zahlung: Jährlich"),
                  subtitle: Text(_isMonthly ? "Preis pro Monat" : "Preis pro Jahr"),
                  value: _isMonthly,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (val) => setState(() => _isMonthly = val),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Kategorie', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Nächste Kündigungsfrist / Ablauf',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null ? 'Bitte Datum wählen' : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveContract,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("SPEICHERN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}