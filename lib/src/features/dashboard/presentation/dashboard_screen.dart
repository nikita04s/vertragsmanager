import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Wichtig für Provider
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// WICHTIG: Prüfe hier, ob dein Import legacy braucht oder nicht. 
// Wenn contract_provider.dart legacy nutzt, ist das hier okay.
import 'package:vertragsmanager/src/features/contracts/domain/contract_provider.dart'; 

class DashboardScreen extends ConsumerWidget { // ÄNDERUNG: ConsumerWidget
  const DashboardScreen({super.key});

  @override
  // ÄNDERUNG: WidgetRef ref hinzufügen
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    
    // 1. DATEN LADEN (Das echte Gehirn!)
    final contracts = ref.watch(contractProvider);

    // 2. BERECHNUNG: Gesamtsumme
    double totalSum = 0;
    for (var contract in contracts) {
      totalSum += contract.price;
    }

    // 3. BERECHNUNG: Summen pro Kategorie (für das Diagramm)
    double sumWohnen = 0;
    double sumAbo = 0;
    double sumMobil = 0;
    double sumSonstiges = 0;

    for (var c in contracts) {
      if (c.category == 'Wohnen') sumWohnen += c.price;
      else if (c.category == 'Abo') sumAbo += c.price;
      else if (c.category == 'Mobilität') sumMobil += c.price;
      else sumSonstiges += c.price;
    }

    // 4. BERECHNUNG: Nächste kritische Frist (Alert)
    // Wir suchen den Vertrag, dessen Frist am nächsten ist und weniger als 30 Tage weg ist
    final now = DateTime.now();
    contracts.sort((a, b) {
      if (a.endDate == null) return 1;
      if (b.endDate == null) return -1;
      return a.endDate!.compareTo(b.endDate!);
    });
    
    // Suchen, ob es einen kritischen Vertrag gibt
    String alertName = "Keine Warnungen";
    int alertDays = 0;
    bool hasCritical = false;

    for (var c in contracts) {
      if (c.endDate != null) {
        final diff = c.endDate!.difference(now).inDays;
        if (diff >= 0 && diff < 30) {
          alertName = c.title;
          alertDays = diff;
          hasCritical = true;
          break; // Den ersten (dringendsten) nehmen
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Finanzielle Vitals"),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DER ALERT (Nur anzeigen, wenn kritisch)
            if (hasCritical)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nächste Frist: $alertName",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "In $alertDays Tagen kündigen!",
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.green[50],
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.green.shade200),
                 ),
                 child: Row(
                   children: [
                     const Icon(Icons.check_circle, color: Colors.green),
                     const SizedBox(width: 12),
                     const Text("Alles im grünen Bereich!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                   ],
                 ),
              ),

            const SizedBox(height: 32),

            // 2. DAS DIAGRAMM (Jetzt mit echten Daten)
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sections: [
                        if (sumWohnen > 0) PieChartSectionData(value: sumWohnen, color: Colors.blueAccent, title: 'Wohnen', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        if (sumMobil > 0) PieChartSectionData(value: sumMobil, color: Colors.orangeAccent, title: 'Auto', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        if (sumAbo > 0) PieChartSectionData(value: sumAbo, color: Colors.purpleAccent, title: 'Abo', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        if (sumSonstiges > 0) PieChartSectionData(value: sumSonstiges, color: Colors.grey, title: 'Sonst', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Gesamt", style: TextStyle(color: Colors.grey[600])),
                        Text(
                          currencyFormatter.format(totalSum),
                          style: GoogleFonts.oswald(
                            fontSize: 24, // Etwas kleiner, damit es passt
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}