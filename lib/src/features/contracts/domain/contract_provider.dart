import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'contract.dart';

class ContractNotifier extends StateNotifier<List<Contract>> {
  ContractNotifier() : super([]) {
    loadContracts();
  }

  // 1. LADEN
  Future<void> loadContracts() async {
    try {
      final response = await Supabase.instance.client
          .from('contracts')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;

      state = data.map((map) => Contract(
        id: map['id'].toString(), // toString() zur Sicherheit
        title: map['title'],
        price: (map['price'] as num).toDouble(),
        category: map['category'] ?? 'Sonstiges',
        endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
        isMonthly: map['is_monthly'] ?? true, // Falls null, nehmen wir true an
      )).toList();
    } catch (e) {
      print("Fehler beim Laden: $e");
    }
  }

  // 2. HINZUFÜGEN (KORRIGIERT!)
  Future<void> addContract(Contract contract) async {
    try {
      // WICHTIG: Wir senden KEINE 'id' mit. Supabase erstellt diese automatisch.
      await Supabase.instance.client.from('contracts').insert({
        // 'id': contract.id,  <-- Diese Zeile haben wir gelöscht!
        'title': contract.title,
        'price': contract.price,
        'category': contract.category,
        'end_date': contract.endDate?.toIso8601String(),
        'is_monthly': contract.isMonthly,
      });
      
      await loadContracts(); // Liste neu laden
    } catch (e) {
      print("Fehler beim Speichern: $e");
    }
  }

  // 3. UPDATE
  Future<void> updateContract(Contract contract) async {
    try {
      await Supabase.instance.client.from('contracts').update({
        'title': contract.title,
        'price': contract.price,
        'category': contract.category,
        'end_date': contract.endDate?.toIso8601String(),
        'is_monthly': contract.isMonthly,
      }).eq('id', contract.id); // Hier brauchen wir die ID, um den richtigen Eintrag zu finden
      
      await loadContracts();
    } catch (e) {
      print("Fehler beim Update: $e");
    }
  }

  // 4. LÖSCHEN
  Future<void> removeContract(String id) async {
    try {
      await Supabase.instance.client.from('contracts').delete().eq('id', id);
      await loadContracts();
    } catch (e) {
      print("Fehler beim Löschen: $e");
    }
  }
}

final contractProvider = StateNotifierProvider<ContractNotifier, List<Contract>>((ref) {
  return ContractNotifier();
});