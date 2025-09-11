/// Utility function to convert file size in bytes to a human-readable string.
String humanReadableFileSize(num bytes) {
  if (bytes < 0) return '0 B';

  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  const threshold = 1024;

  if (bytes < threshold) {
    return '$bytes B';
  }

  int unitIndex = 0;
  double size = bytes.toDouble();

  while (size >= threshold && unitIndex < units.length - 1) {
    size /= threshold;
    unitIndex++;
  }

  // Format with appropriate decimal places
  String formattedSize;
  if (size >= 100) {
    formattedSize = size.toStringAsFixed(0);
  } else if (size >= 10) {
    formattedSize = size.toStringAsFixed(1);
  } else {
    formattedSize = size.toStringAsFixed(2);
  }

  return '$formattedSize ${units[unitIndex]}';
}
