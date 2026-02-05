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

    // Clean Design: Weißer Hintergrund, kein sichtbarer Border, volle Breite im Container
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Ein Hauch von Schatten für Tiefe (Apple Style ist meistens flach, aber das hier hilft der Abhebung)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        onPressed: onTap,
        // pressedOpacity simuliert den iOS Touch-Effekt
        pressedOpacity: 0.6,
        child: Row(
          children: [
            // ICON BOX (Kleiner und runder)
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _getCategoryColor(contract.category).withOpacity(0.1),
                shape: BoxShape.circle, // Kreise wirken oft moderner als Quadrate
              ),
              child: Icon(
                _getCategoryIcon(contract.category),
                color: _getCategoryColor(contract.category),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            
            // TITEL & KATEGORIE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract.title,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    contract.category,
                    style: TextStyle(
                      color: Colors.grey.shade500, 
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            
            // PREIS & DATUM
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(contract.price),
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, // Preis ist wichtig
                    color: Colors.black,
                    fontFeatures: [FontFeature.tabularFigures()], // Zahlen untereinander bündig
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     if (nextPayment != null)
                      Text(
                        "${DateFormat('dd.MM.').format(nextPayment)} • ",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    Text(
                      contract.isMonthly ? "mtl." : "jährl.",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),
            
            // Optional: Ein kleiner "Chevron" Pfeil wie in Einstellungen
            const SizedBox(width: 8),
            Icon(CupertinoIcons.chevron_right, size: 14, color: Colors.grey.shade300)
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Wohnen': return const Color(0xFFFF9500); // Apple Orange
      case 'Mobilität': return const Color(0xFF34C759); // Apple Green
      case 'Abo': return const Color(0xFF007AFF); // Apple Blue
      case 'Versicherung': return const Color(0xFFAF52DE); // Apple Purple
      default: return const Color(0xFF8E8E93); // Apple Grey
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