enum CostType { income, outcome }

class Cost {
  int? id;
  String title;
  String description;
  String date;
  String amount;
  CostType costType;
  String wayId;

  Cost(
      {this.id,
      required this.title,
      required this.description,
      required this.date,
      required this.amount,
      required this.costType,
      required this.wayId});
  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'amount': amount,
      'cost_type': costType.toString(),
      'way_id': wayId
    };
  }

  factory Cost.empty() => Cost(
      id: 0,
      title: "",
      description: "",
      date: "",
      amount: "",
      costType: CostType.income,
      wayId: "");
  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Cost{id: $id, title: $title, to: $description, date: $date, amount: $amount, costType: $costType, wayId: $wayId}';
  }
}
