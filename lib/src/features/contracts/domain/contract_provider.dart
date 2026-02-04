import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'contract.dart'; // <- Wir nutzen einfach den Dateinamen, da sie im selben Ordner liegt

// 1. Der "StateNotifier": Er verwaltet die Liste und ändert sie.
class ContractNotifier extends StateNotifier<List<Contract>> {
  ContractNotifier() : super([
    // Start-Daten (damit wir was sehen)
    Contract(id: '1', title: 'Netflix Premium', price: 17.99, category: 'Abo', endDate: DateTime.now().add(const Duration(days: 30))),
    Contract(id: '2', title: 'Telekom Mobilfunk', price: 49.99, category: 'Vertrag', endDate: DateTime.now().add(const Duration(days: 14))),
    Contract(id: '3', title: 'Miete', price: 750.00, category: 'Wohnen', endDate: null),
  ]);

  // Funktion: Neuen Vertrag hinzufügen
  void addContract(Contract contract) {
    // Wir erstellen eine neue Liste mit allen alten Items + dem neuen
    state = [...state, contract];
  }

  // Funktion: Vertrag löschen
  void removeContract(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}

// 2. Der "Provider": Das ist die Variable, die wir in der UI benutzen.
final contractProvider = StateNotifierProvider<ContractNotifier, List<Contract>>((ref) {
  return ContractNotifier();
});