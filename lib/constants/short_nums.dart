String shortNum({required num number}) {
  const suffixes = [
    'k',
    'M',
    'B',
    'T'
  ]; // Thousands, Millions, Billions, Trillions
  int index = -1;

  while (number >= 1000 && index < suffixes.length - 1) {
    number /= 1000;
    index++;
  }

  return index == -1
      ? number.toStringAsFixed(0) // No suffix needed
      : "${number.toStringAsFixed(number.truncateToDouble() == number ? 0 : 1)}${suffixes[index]}";
}

double customRound(double rate) {
  final remainder = rate % 1;

  if (remainder < 0.25) {
    return rate - remainder; // Round down to the nearest whole number
  } else if (remainder < 0.75) {
    return rate - remainder + 0.5; // Round to the nearest 0.5
  } else {
    return rate - remainder + 1.0; // Round up to the next whole number
  }
}
