import 'package:intl/intl.dart';

class ContractParser {
  
  // 1. PREIS FINDEN
  static double parsePrice(String text) {
    // Sucht nach Muster wie: 12,99 | 1.200,00 | 12.99
    final RegExp priceRegex = RegExp(r'(\d+[\.,]\d{2})');
    
    final lines = text.split('\n');
    for (var line in lines) {
      // Wir suchen Zeilen mit Währungssymbolen oder "Betrag"
      if (line.contains('€') || line.toLowerCase().contains('eur') || line.toLowerCase().contains('betrag')) {
        final match = priceRegex.firstMatch(line);
        if (match != null) {
          String priceString = match.group(0)!;
          // Alles bereinigen: 1.000,00 -> 1000.00
          priceString = priceString.replaceAll('.', '').replaceAll(',', '.');
          return double.tryParse(priceString) ?? 0.0;
        }
      }
    }
    return 0.0;
  }

  // 2. DATUM FINDEN (Debug-Version)
  static DateTime? parseDate(String text) {
    print("----- DEBUG DATUM SUCHE -----"); // Das siehst du in der Konsole
    
    // Neuer Regex: Erlaubt Punkte, Kommas, Striche, Slashes und Leerzeichen als Trenner
    // Sucht nach DD.MM.YYYY oder D.M.YY
    final RegExp dateRegex = RegExp(r'(\d{1,2})[\.\,\-\/\s]{1,3}(\d{1,2})[\.\,\-\/\s]{1,3}(\d{2,4})');
    
    final matches = dateRegex.allMatches(text);
    DateTime? bestDate;
    
    for (var match in matches) {
      String rawMatch = match.group(0)!; // Der gefundene Text-Schnipsel
      
      try {
        int day = int.parse(match.group(1)!);
        int month = int.parse(match.group(2)!);
        int year = int.parse(match.group(3)!);
        
        // Fix: Wenn Jahr nur 2-stellig ist (z.B. "25" -> 2025)
        if (year < 100) year += 2000;

        // Plausibilitäts-Check: Monat muss 1-12 sein, Tag 1-31
        if (month < 1 || month > 12 || day < 1 || day > 31) continue;

        final date = DateTime(year, month, day);
        print("Gefundenes Datum: $day.$month.$year (im Text: '$rawMatch')");
        
        // Wir nehmen das Datum, das am weitesten in der Zukunft liegt
        if (date.isAfter(DateTime.now().subtract(const Duration(days: 365)))) {
           if (bestDate == null || date.isAfter(bestDate)) {
            bestDate = date;
          }
        }
      } catch (e) {
        print("Konnte '$rawMatch' nicht parsen: $e");
      }
    }
    
    print("Gewähltes Datum: $bestDate");
    print("-----------------------------");
    return bestDate;
  }

  // 3. TITEL ERKENNEN (Verbessert!)
  static String parseTitle(String text) {
    final lowerText = text.toLowerCase();
    
    // Prioritäts-Liste: Wenn wir das Wort finden, nehmen wir EXAKT das Wort
    // und nicht die ganze Zeile (löst das "div..." Problem).
    if (lowerText.contains('netflix')) return 'Netflix';
    if (lowerText.contains('spotify')) return 'Spotify';
    if (lowerText.contains('amazon')) return 'Amazon Prime';
    if (lowerText.contains('telekom')) return 'Telekom';
    if (lowerText.contains('vodafone')) return 'Vodafone';
    if (lowerText.contains('o2')) return 'O2';
    if (lowerText.contains('allianz')) return 'Allianz';
    if (lowerText.contains('huk')) return 'HUK Coburg';
    if (lowerText.contains('mcfit')) return 'McFit';
    if (lowerText.contains('clever fit')) return 'Clever Fit';
    
    // Fallback: Erste Zeile, die sinnvoll aussieht
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.trim().length > 3 && !line.contains('<')) return line.trim();
    }
    
    return "Unbekannter Vertrag";
  }
  
  // 4. KATEGORIE ZUORDNEN
  static String parseCategory(String title) {
    final t = title.toLowerCase();
    if (t.contains('netflix') || t.contains('spotify') || t.contains('prime') || t.contains('mcfit') || t.contains('fit')) return 'Abo';
    if (t.contains('telekom') || t.contains('vodafone') || t.contains('o2')) return 'Mobilität'; 
    if (t.contains('allianz') || t.contains('huk') || t.contains('versicherung')) return 'Versicherung';
    if (t.contains('miete') || t.contains('strom') || t.contains('gas')) return 'Wohnen';
    return 'Sonstiges';
  }

  // 5. INTERVALL ERKENNEN (Neu)
  static bool parseIsMonthly(String text) {
    final t = text.toLowerCase();
    
    // Wenn "Jahr", "jährlich", "annual" vorkommt -> Wahrscheinlich Jährlich (false)
    if (t.contains('jahr') || t.contains('annual') || t.contains('12 monate')) {
      return false; 
    }
    
    // Standard ist Monatlich (true)
    return true;
  }
}