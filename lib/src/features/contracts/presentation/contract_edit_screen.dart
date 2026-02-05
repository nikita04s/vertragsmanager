import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vertragsmanager/src/features/contracts/domain/contract.dart';
import 'package:vertragsmanager/src/features/contracts/domain/contract_provider.dart';

class ContractEditScreen extends ConsumerStatefulWidget {
  final String? existingId; 
  final String? initialTitle;
  final double? initialPrice;
  final DateTime? initialDate;
  final String? initialCategory;
  final bool? initialIsMonthly;

  const ContractEditScreen({
    super.key,
    this.existingId,
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
    // iOS Style Date Picker (Modal Bottom Sheet)
    final initialDate = _selectedDate ?? DateTime.now().add(const Duration(days: 30));
    
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2040),
                onDateTimeChanged: (val) {
                  // Hier setzen wir nur den State, schließen aber NICHTS
                  setState(() => _selectedDate = val);
                },
              ),
            ),
            // HIER IST DIE ÄNDERUNG:
            CupertinoButton(
              child: const Text('Fertig'),
              onPressed: () {
                // WICHTIG: rootNavigator: true
                // Das sagt Flutter: "Suche auf der allerhöchsten Ebene nach dem Popup"
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop(); 
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void _saveContract() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
      
      final contract = Contract(
        id: widget.existingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        price: price,
        category: _selectedCategory,
        endDate: _selectedDate,
        isMonthly: _isMonthly,
      );

      // Speichern in Riverpod / Datenbank
      if (widget.existingId != null) {
        ref.read(contractProvider.notifier).updateContract(contract);
      } else {
        ref.read(contractProvider.notifier).addContract(contract);
      }

      // NAVIGATION LOGIK
      if (mounted) {
        if (widget.existingId != null) {
          // Fall A: Wir bearbeiten einen existierenden Vertrag.
          // Wir kommen direkt von der Liste, also reicht ein Schritt zurück.
          Navigator.of(context).pop();
        } else {
          // Fall B: Wir erstellen einen NEUEN Vertrag.
          // Der Weg war: Liste -> Auswahl-Screen -> Edit-Screen.
          // Wir wollen "Auswahl" und "Edit" überspringen und direkt zur Liste (Start).
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Grouped Background
      appBar: AppBar(
        title: Text(widget.existingId != null ? "Bearbeiten" : "Neuer Vertrag"),
        actions: [
          TextButton(
            onPressed: _saveContract,
            child: const Text("Speichern", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SECTION 1: BASISDATEN
            _buildSectionLabel("ALLGEMEIN"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildTextInput(_titleController, "Name", "z.B. Netflix", isLast: false),
                  const Divider(height: 1, indent: 16),
                  _buildTextInput(_priceController, "Preis (€)", "0,00", isLast: true, isNumber: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SECTION 2: DETAILS
            _buildSectionLabel("DETAILS"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Kategorie Picker (Custom Row)
                  _buildRowButton(
                    label: "Kategorie",
                    value: _selectedCategory,
                    onTap: () => _showCategoryPicker(),
                    isLast: false,
                  ),
                  const Divider(height: 1, indent: 16),
                  
                  // Zahlungsintervall Switch
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Monatliche Zahlung", style: TextStyle(fontSize: 16)),
                        CupertinoSwitch(
                          value: _isMonthly,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) => setState(() => _isMonthly = val),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 16),
                  
                  // Datum Picker
                  _buildRowButton(
                    label: "Kündigungsfrist",
                    value: _selectedDate == null 
                        ? "Auswählen" 
                        : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                    onTap: _pickDate,
                    isLast: true,
                    textColor: _selectedDate == null ? Colors.grey : Colors.blue,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                "Wir erinnern dich 30 Tage vor Ablauf der Kündigungsfrist.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hilfswidgets für den Clean Code
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String label, String placeholder, {bool isLast = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
              style: const TextStyle(fontSize: 16),
              validator: (val) => val!.isEmpty ? "" : null, // Fehler werden nicht rot angezeigt, verhindert nur Speichern
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowButton({required String label, required String value, required VoidCallback onTap, bool isLast = false, Color? textColor}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Row(
              children: [
                Text(value, style: TextStyle(fontSize: 16, color: textColor ?? Colors.grey.shade600)),
                const SizedBox(width: 6),
                const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: CupertinoPicker(
          itemExtent: 32,
          onSelectedItemChanged: (index) => setState(() => _selectedCategory = _categories[index]),
          children: _categories.map((c) => Text(c)).toList(),
        ),
      ),
    );
  }
}