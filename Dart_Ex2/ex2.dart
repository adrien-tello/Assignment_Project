void main() {
  List<String> words = ["cat", "elephant", "dog", "butterfly", "ant", "tiger"];

  Map<String, int> wordLengths = {
    for (String word in words) word: word.length
  };

  wordLengths.entries
      .where((entry) => entry.value > 4)
      .forEach((entry) => print("${entry.key}: ${entry.value}"));
}
