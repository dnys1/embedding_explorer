import 'package:aws_common/aws_common.dart';

extension Recase on String {
  String get screamingCase {
    return groupIntoWords().map((word) => word.toUpperCase()).join('_');
  }
}
