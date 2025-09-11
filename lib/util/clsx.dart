extension Clsx on List<String?> {
  String get clsx {
    final buf = StringBuffer();
    for (final c in this) {
      if (c != null && c.isNotEmpty) {
        if (buf.isNotEmpty) buf.write(' ');
        buf.write(c);
      }
    }
    return buf.toString();
  }
}
