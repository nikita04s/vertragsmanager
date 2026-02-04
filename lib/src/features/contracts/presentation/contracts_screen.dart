import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // WICHTIG
import 'package:vertragsmanager/src/features/contracts/domain/contract_provider.dart'; // Unser Provider
import 'package:vertragsmanager/src/features/contracts/presentation/contract_card.dart';
import 'package:vertragsmanager/src/features/contracts/presentation/add_contract_screen.dart';

// ÄNDERUNG: "ConsumerWidget" statt "StatelessWidget"
class ContractsScreen extends ConsumerWidget {
  const ContractsScreen({super.key});

  @override
  // ÄNDERUNG: Wir brauchen "WidgetRef ref", um auf den Provider zuzugreifen
  Widget build(BuildContext context, WidgetRef ref) {
    
    // HIER PASSIERT DIE MAGIE:
    // "ref.watch" sagt: "Gib mir die Liste und bau dich neu, wenn sie sich ändert."
    final contracts = ref.watch(contractProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meine Verträge"),
        actions: [
          // Kleiner Test: Button zum Löschen aller Verträge (optional)
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.filter_list)
          ),
        ],
      ),
      // Wenn die Liste leer ist, zeigen wir einen Text
      body: contracts.isEmpty 
        ? const Center(child: Text("Keine Verträge vorhanden."))
        : ListView.builder(
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              // Wir wrappen die Card in ein "Dismissible", damit man löschen kann (Wischen)
              return Dismissible(
                key: ValueKey(contract.id),
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (direction) {
                  // LÖSCHEN via Provider
                  ref.read(contractProvider.notifier).removeContract(contract.id);
                },
                child: ContractCard(contract: contract),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddContractScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}