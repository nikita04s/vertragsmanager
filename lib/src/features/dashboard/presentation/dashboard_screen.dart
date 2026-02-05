import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vertragsmanager/src/features/contracts/domain/contract_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final contracts = ref.watch(contractProvider);

    // BERECHNUNGEN
    double totalMonthlySum = 0;
    double sumWohnen = 0;
    double sumAbo = 0;
    double sumMobil = 0;
    double sumVersicherung = 0;
    double sumSonstiges = 0;

    for (var contract in contracts) {
      double monthlyPrice = contract.isMonthly ? contract.price : contract.price / 12;
      totalMonthlySum += monthlyPrice;

      switch (contract.category) {
        case 'Wohnen': sumWohnen += monthlyPrice; break;
        case 'Abo': sumAbo += monthlyPrice; break;
        case 'Mobilität': sumMobil += monthlyPrice; break;
        case 'Versicherung': sumVersicherung += monthlyPrice; break;
        default: sumSonstiges += monthlyPrice;
      }
    }

    // ALERT LOGIK
    final now = DateTime.now();
    final sortedContracts = List.of(contracts);
    sortedContracts.sort((a, b) {
      if (a.endDate == null) return 1;
      if (b.endDate == null) return -1;
      return a.endDate!.compareTo(b.endDate!);
    });
    
    String alertName = "";
    int alertDays = 0;
    bool hasCritical = false;

    for (var c in sortedContracts) {
      if (c.endDate != null) {
        final diff = c.endDate!.difference(now).inDays;
        if (diff >= 0 && diff < 30) {
          alertName = c.title;
          alertDays = diff;
          hasCritical = true;
          break; 
        }
      }
    }

    // UI START
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text("Übersicht"),
            backgroundColor: Color(0xFFF2F2F7),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // WARNUNG KARTE (Als dezenter Hinweis)
                  if (hasCritical)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withOpacity(0.1)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.bell_fill, color: Colors.red, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Kündigungsfrist: $alertName", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                Text("Noch $alertDays Tage verbleibend.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_right, color: Colors.grey, size: 16)
                        ],
                      ),
                    ),
                  
                  // MONATLICHE KOSTEN (Große Zahl)
                  Text("Gesamtkosten", style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(totalMonthlySum),
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  const Text("pro Monat Ø", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  
                  const SizedBox(height: 32),

                  // CHART KARTE
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                if (sumWohnen > 0) _chartSection(sumWohnen, const Color(0xFFFF9500)),
                                if (sumMobil > 0) _chartSection(sumMobil, const Color(0xFF34C759)),
                                if (sumAbo > 0) _chartSection(sumAbo, const Color(0xFF007AFF)),
                                if (sumVersicherung > 0) _chartSection(sumVersicherung, const Color(0xFFAF52DE)),
                                if (sumSonstiges > 0) _chartSection(sumSonstiges, const Color(0xFF8E8E93)),
                              ],
                              sectionsSpace: 0, // Apple Charts haben oft keine Lücken
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Legend
                        Wrap(
                          spacing: 16, runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            if (sumWohnen > 0) _LegendItem(color: const Color(0xFFFF9500), text: "Wohnen"),
                            if (sumMobil > 0) _LegendItem(color: const Color(0xFF34C759), text: "Mobilität"),
                            if (sumAbo > 0) _LegendItem(color: const Color(0xFF007AFF), text: "Abo"),
                            if (sumVersicherung > 0) _LegendItem(color: const Color(0xFFAF52DE), text: "Versich."),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _chartSection(double value, Color color) {
    return PieChartSectionData(value: value, color: color, radius: 25, showTitle: false);
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }
}