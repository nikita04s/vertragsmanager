import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vertragsmanager/src/features/contracts/domain/contract.dart';

class ContractCard extends StatelessWidget {
  final Contract contract;
  final VoidCallback? onTap;

  const ContractCard({super.key, required this.contract, this.onTap});

  DateTime? getNextPaymentDate() {
    if (contract.endDate == null) return null;
    final now = DateTime.now();
    final billingDay = contract.endDate!.day; 
    
    if (!contract.isMonthly) {
      var date = contract.endDate!;
      while (date.isBefore(now)) {
        date = DateTime(date.year + 1, date.month, date.day);
      }
      return date;
    } else {
      var candidate = DateTime(now.year, now.month, billingDay);
      if (candidate.isBefore(now.subtract(const Duration(days: 1)))) { 
        candidate = DateTime(now.year, now.month + 1, billingDay);
      }
      return candidate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final nextPayment = getNextPaymentDate();

    // Container statt Card für volle Kontrolle
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // Reinweiß
        borderRadius: BorderRadius.circular(12), // Apple Radius
        // Ganz subtiler Rahmen statt Schatten
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: CupertinoButton( // Nutzt den iOS "Fade" Effekt beim Klicken
        padding: const EdgeInsets.all(16.0),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LINKS
            Row(
              children: [
                // Optional: Ein Icon-Container wie in den iOS Einstellungen
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(contract.category).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(contract.category),
                    color: _getCategoryColor(contract.category),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.title,
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'Inter'
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contract.category,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            
            // RECHTS
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(contract.price),
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                    color: Colors.black
                  ),
                ),
                Text(
                  contract.isMonthly ? "mtl." : "jährl.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                if (nextPayment != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 4.0),
                     child: Text(
                        "Am ${DateFormat('dd.MM.').format(nextPayment)}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF007AFF), // Apple Blau
                          fontWeight: FontWeight.w500,
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

  // Kleine Helfer für Farben und Icons (Apple Style)
  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Wohnen': return Colors.orange;
      case 'Mobilität': return Colors.green;
      case 'Abo': return const Color(0xFF007AFF);
      case 'Versicherung': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Wohnen': return CupertinoIcons.house_fill;
      case 'Mobilität': return CupertinoIcons.car_detailed;
      case 'Abo': return CupertinoIcons.play_circle_fill;
      case 'Versicherung': return CupertinoIcons.shield_fill;
      default: return CupertinoIcons.doc_text_fill;
    }
  }
}