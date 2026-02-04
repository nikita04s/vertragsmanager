class Contract {
  final String id;
  final String title;      // z.B. Netflix
  final double price;      // z.B. 17.99
  final DateTime? endDate; // Wann läuft er ab?
  final String category;   // z.B. Abo, Wohnen

  Contract({
    required this.id,
    required this.title,
    required this.price,
    this.endDate,
    required this.category,
  });
}