import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für Preis-Formatierung
import 'package:vertragsmanager/src/features/contracts/domain/contract.dart';

class ContractCard extends StatelessWidget {
  final Contract contract;

  const ContractCard({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    // Helfer für Datum und Währung
    final currencyFormatter = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final isCritical = contract.endDate != null &&
        contract.endDate!.difference(DateTime.now()).inDays < 30;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LINKS: Name und Kategorie
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contract.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  contract.category,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            // RECHTS: Preis und Frist
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(contract.price),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (contract.endDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCritical ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCritical
                          ? "Endet in ${contract.endDate!.difference(DateTime.now()).inDays} Tagen"
                          : "Läuft noch",
                      style: TextStyle(
                        fontSize: 12,
                        color: isCritical ? Colors.red[800] : Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}