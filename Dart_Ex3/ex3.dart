class Person {
  String name;
  int age;

  Person(this.name, this.age);
}

void main() {
  List<Person> people = [
    Person("Alice", 25),
    Person("Bob", 30),
    Person("Charlie", 35),
    Person("Anna", 22),
    Person("Brian", 28),
    Person("David", 40),
    Person("Amy", 19),
    Person("Eve", 33),
  ];

  List<Person> filtered = people
      .where((p) => p.name.startsWith('A') || p.name.startsWith('B'))
      .toList();

  double averageAge = filtered.map((p) => p.age).reduce((a, b) => a + b) / filtered.length;

  print("People starting with 'A' or 'B':");
  filtered.forEach((p) => print("  ${p.name}: ${p.age}"));
  print("\nAverage age: ${averageAge.toStringAsFixed(1)}");
}
