import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'contract.dart';

// Der StateNotifier kümmert sich um die Kommunikation mit Supabase
class ContractNotifier extends StateNotifier<List<Contract>> {
  ContractNotifier() : super([]) {
    // Sobald die App startet: Daten laden!
    loadContracts();
  }

  // 1. DATEN LADEN (READ)
  Future<void> loadContracts() async {
    try {
      final response = await Supabase.instance.client
          .from('contracts')
          .select()
          .order('created_at', ascending: false); // Neueste oben

      final data = response as List<dynamic>;

      // Wir wandeln die JSON-Daten von der Datenbank in unsere Dart-Objekte um
      state = data.map((map) => Contract(
        id: map['id'],
        title: map['title'],
        price: (map['price'] as num).toDouble(), // Sicherstellen, dass es eine Zahl ist
        category: map['category'] ?? 'Sonstiges',
        endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      )).toList();
    } catch (e) {
      print("Fehler beim Laden: $e");
    }
  }

  // 2. DATEN HINZUFÜGEN (CREATE)
  Future<void> addContract(Contract contract) async {
    try {
      await Supabase.instance.client.from('contracts').insert({
        'title': contract.title,
        'price': contract.price,
        'category': contract.category,
        'end_date': contract.endDate?.toIso8601String(),
      });
      
      // Liste neu laden, damit der neue Eintrag sofort erscheint
      await loadContracts(); 
    } catch (e) {
      print("Fehler beim Speichern: $e");
    }
  }

  // 3. LÖSCHEN (DELETE)
  Future<void> removeContract(String id) async {
    try {
      await Supabase.instance.client.from('contracts').delete().eq('id', id);
      await loadContracts(); // Liste aktualisieren
    } catch (e) {
      print("Fehler beim Löschen: $e");
    }
  }
}

// Der Provider bleibt gleich, damit die UI nichts vom Umbau merkt
final contractProvider = StateNotifierProvider<ContractNotifier, List<Contract>>((ref) {
  return ContractNotifier();
});