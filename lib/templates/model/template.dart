/// Represents a text template that can be rendered with data.
extension type const Template(String rawTemplate) {
  static final RegExp _comments = RegExp(r'//.*$', multiLine: true);

  String get cleanedTemplate {
    return rawTemplate.replaceAll(_comments, '').trim(); // Remove comments
  }

  bool get isEmpty => cleanedTemplate.isEmpty;
  bool get isNotEmpty => !isEmpty;

  String render(Map<String, Object?>? data) {
    var output = cleanedTemplate;
    if (data == null) {
      return output;
    }
    for (final MapEntry(key: field, :value) in data.entries) {
      final replacement = value?.toString() ?? '';
      output = output.replaceAll('{{$field}}', replacement);
    }
    return output;
  }
}
