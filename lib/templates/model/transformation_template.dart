extension type const TransformationTemplate(String rawTemplate)
    implements String {
  static final RegExp _comments = RegExp(r'//.*$', multiLine: true);

  String get cleanedTemplate {
    return rawTemplate.replaceAll(_comments, '').trim(); // Remove comments
  }

  bool validate() {
    // TODO: Improve validation logic
    return cleanedTemplate.isNotEmpty;
  }

  String render(Map<String, Object?>? data) {
    var output = cleanedTemplate;
    if (data == null) {
      return output;
    }
    for (final MapEntry(key: field, :value) in data.entries) {
      final replacement = value?.toString() ?? '[empty]';
      output = output.replaceAll('{{$field}}', replacement);
    }
    return output;
  }
}
