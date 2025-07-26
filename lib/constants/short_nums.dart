

String shortNum({required num number}) {
  // Define the suffixes and corresponding thresholds
  const suffixes = [
    'k',
    'M',
    'B',
    'T'
  ]; // Thousands, Millions, Billions, Trillions
  int index = -1;

  // Keep dividing by 1000 and increasing index until number is below 1000
  while (number >= 1000 && index < suffixes.length - 1) {
    number /= 1000;
    index++;
  }

  // Format the shortened number with the appropriate suffix
  if (index == -1) {
    // No suffix needed, return the number as a string
    return number.toStringAsFixed(0);
  } else {
    // Display number with one decimal if it has decimals, otherwise as an integer
    final formattedNumber =
        number.toStringAsFixed(number.truncateToDouble() == number ? 0 : 1);
    return "$formattedNumber${suffixes[index]}";
  }
}



double customRound(double rate) {
  double remainder = rate % 1;

  if (remainder < 0.25) {
    return rate - remainder; // Round down to the nearest whole number
  } else if (remainder < 0.75) {
    return rate - remainder + 0.5; // Round to the nearest 0.5
  } else {
    return rate - remainder + 1.0; // Round up to the next whole number
  }
}


