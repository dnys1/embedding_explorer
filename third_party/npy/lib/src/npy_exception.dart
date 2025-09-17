abstract class NpyException implements Exception {
  const NpyException();

  String get message;

  @override
  String toString() => message;
}

class NpyFileNotExistsException extends NpyException {
  const NpyFileNotExistsException(this.path);

  final String path;

  @override
  String get message => "File '$path' does not exist.";
}

class NpyParseException extends NpyException {
  const NpyParseException(this.message);

  @override
  final String message;
}

class NpyInvalidVersionException extends NpyParseException {
  const NpyInvalidVersionException(super.message);
}

class NpyInvalidHeaderException extends NpyParseException {
  const NpyInvalidHeaderException(super.message);
}

class NpyInvalidDTypeException extends NpyInvalidHeaderException {
  const NpyInvalidDTypeException(super.message);
}

class NpyInvalidEndianException extends NpyInvalidDTypeException {
  const NpyInvalidEndianException(super.message);
}

class NpyInvalidNpyTypeException extends NpyInvalidDTypeException {
  const NpyInvalidNpyTypeException(super.message);
}

class NpyParseOrderException extends NpyParseException {
  const NpyParseOrderException(super.message);
}

class NpyWriteException extends NpyException {
  const NpyWriteException(this.message);

  @override
  final String message;
}

class NpyFileExistsException extends NpyException {
  const NpyFileExistsException(this.message);

  @override
  final String message;
}

class NpyInvalidNameException extends NpyException {
  const NpyInvalidNameException(this.message);

  @override
  final String message;
}
