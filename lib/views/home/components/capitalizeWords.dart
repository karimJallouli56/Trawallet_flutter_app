String capitalizeWords(String? value) {
  if (value == null || value.trim().isEmpty) return '';

  return value
      .trim()
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}
