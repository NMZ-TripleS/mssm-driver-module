class Way {
  int? id;
  String from;
  String to;
  String date;

  Way({
    this.id,
    required this.from,
    required this.to,
    required this.date,
  });
  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {'id': id, 'from': from, 'to': to, 'date': date};
  }

  factory Way.empty() => Way(id: 0, from: "", to: "", date: "");
  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Way{id: $id, from: $from, to: $to,date: $date}';
  }
}
