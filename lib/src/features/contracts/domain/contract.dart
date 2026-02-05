class Contract {
  final String id;
  final String title;
  final double price;
  final DateTime? endDate;
  final String category;
  final bool isMonthly; // NEU: true = Monatlich, false = Jährlich

  Contract({
    required this.id,
    required this.title,
    required this.price,
    this.endDate,
    required this.category,
    this.isMonthly = true, // Standard ist monatlich
  });
}