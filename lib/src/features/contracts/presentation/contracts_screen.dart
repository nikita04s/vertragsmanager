import 'package:flutter/cupertino.dart'; // Für iOS Icons
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:vertragsmanager/src/features/contracts/domain/contract_provider.dart'; 
import 'package:vertragsmanager/src/features/contracts/presentation/contract_card.dart';
import 'package:vertragsmanager/src/features/contracts/presentation/add_contract_screen.dart';
import 'package:vertragsmanager/src/features/contracts/presentation/contract_edit_screen.dart';

class ContractsScreen extends ConsumerWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(contractProvider);

    return Scaffold(
      // backgroundColor wird jetzt vom Theme (main.dart) übernommen -> Hellgrau
      body: CustomScrollView(
        slivers: [
          // 1. Die Apple-Style Navigationsleiste
          SliverAppBar.large(
            title: const Text("Verträge"),
            centerTitle: false, // Linksbuendig wie bei iOS
            backgroundColor: const Color(0xFFF2F2F7), // Hintergrund passt sich an
            surfaceTintColor: Colors.transparent, // Kein Farb-Overlay beim Scrollen
            actions: [
              // HIER ist der neue Plus-Button (oben rechts)
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddContractScreen()),
                  );
                },
                // Cupertino Icon für den feinen Look
                icon: const Icon(CupertinoIcons.add, color: Color(0xFF007AFF)),
              ),
              const SizedBox(width: 8), // Etwas Abstand zum Rand
            ],
          ),

          // 2. Die Liste
          if (contracts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.doc_text_search, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Noch keine Verträge", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final contract = contracts[index];
                  return Dismissible(
                    key: ValueKey(contract.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(CupertinoIcons.trash, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      ref.read(contractProvider.notifier).removeContract(contract.id);
                    },
                    child: ContractCard(
                      contract: contract,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ContractEditScreen(
                              existingId: contract.id,
                              initialTitle: contract.title,
                              initialPrice: contract.price,
                              initialCategory: contract.category,
                              initialDate: contract.endDate,
                              initialIsMonthly: contract.isMonthly,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: contracts.length,
              ),
            ),
            
            // Extra Platz unten, damit man den letzten Eintrag gut sieht
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}