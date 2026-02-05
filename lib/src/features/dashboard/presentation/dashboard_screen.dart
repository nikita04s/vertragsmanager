import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vertragsmanager/src/features/contracts/domain/contract_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final contracts = ref.watch(contractProvider);

    // BERECHNUNGEN (unverändert)
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

    // ALERT LOGIK (unverändert)
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
          // 1. Große iOS Überschrift
          const SliverAppBar.large(
            title: Text("Dashboard"),
            centerTitle: false,
            backgroundColor: Color(0xFFF2F2F7),
            surfaceTintColor: Colors.transparent,
          ),

          // 2. Inhalt
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // WARNUNG KARTE
                  if (hasCritical)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5), // Soft Red
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.exclamationmark_circle_fill, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Frist endet: $alertName", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                Text("Noch $alertDays Tage Zeit zum Kündigen.", style: TextStyle(color: Colors.red[900], fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (hasCritical) const SizedBox(height: 24),

                  // CHART KARTE (Weißer Container)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Kostenverteilung", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 250,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: [
                                    if (sumWohnen > 0) PieChartSectionData(value: sumWohnen, color: Colors.orange, radius: 50, showTitle: false),
                                    if (sumMobil > 0) PieChartSectionData(value: sumMobil, color: Colors.green, radius: 50, showTitle: false),
                                    if (sumAbo > 0) PieChartSectionData(value: sumAbo, color: const Color(0xFF007AFF), radius: 50, showTitle: false),
                                    if (sumVersicherung > 0) PieChartSectionData(value: sumVersicherung, color: Colors.purple, radius: 50, showTitle: false),
                                    if (sumSonstiges > 0) PieChartSectionData(value: sumSonstiges, color: Colors.grey, radius: 50, showTitle: false),
                                  ],
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 70,
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Ø Monat", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                    Text(
                                      currencyFormatter.format(totalMonthlySum),
                                      style: GoogleFonts.inter( // Inter Font
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Legend
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            if (sumWohnen > 0) _LegendItem(color: Colors.orange, text: "Wohnen"),
                            if (sumMobil > 0) _LegendItem(color: Colors.green, text: "Mobilität"),
                            if (sumAbo > 0) _LegendItem(color: const Color(0xFF007AFF), text: "Abo"),
                            if (sumVersicherung > 0) _LegendItem(color: Colors.purple, text: "Versicherung"),
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
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}