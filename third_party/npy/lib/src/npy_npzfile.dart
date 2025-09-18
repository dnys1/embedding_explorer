import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:npy/src/npy_exception.dart';
import 'package:npy/src/npy_ndarray.dart';
import 'package:npy/src/npy_parser.dart';

/// The [NpzFile] class represents a zip file containing one or more `.NPY`
/// files. It provides methods for loading, saving, and manipulating the
/// contents of the `.NPZ` file.
class NpzFile {
  NpzFile([Map<String, NdArray>? files]) : files = files ?? {};

  /// Map of files contained in the [NpzFile]. The key is the name of the file,
  /// and the value represents the [NdArray] object.
  final Map<String, NdArray> files;

  /// Loads an `NPZ` file from the given [path] and returns an [NpzFile] object.
  /// Both compressed and uncompressed archives are supported.
  static Future<NpzFile> load(Uint8List bytes) async {
    final files = <String, NdArray>{};

    for (final file in ZipDecoder().decodeBytes(bytes)) {
      if (!file.isFile) continue;

      final bytes = file.content;
      final parser = NpyParser();

      parser
        ..checkMagicString(bytes)
        ..getVersion(bytes)
        ..getHeaderSize(bytes)
        ..getHeader(bytes)
        ..buildHeaderSection()
        ..getData(bytes);

      if (!parser.isCompleted) {
        throw NpyParseException("Error parsing '${file.name}' as an NPY file.");
      }
      files[file.name] = NdArray(
        headerSection: parser.headerSection!,
        data: parser.data,
      );
    }

    return NpzFile(files);
  }

  /// Saves the [NpzFile] to the given [path] in NPZ format. If [isCompressed]
  /// is set to `true`, the archive will be saved in a compressed format. The
  /// default value is `false`.
  ///
  /// The arrays will be named `arr_0.npy`, `arr_1.npy`, etc. If you want to
  /// assign individual names, you can use [NpzFile.save] to do so.
  Future<Uint8List> save({bool isCompressed = false}) async {
    final archive = Archive();

    for (final name in files.keys) {
      final bytes = files[name]!.asBytes;
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    return ZipEncoder().encodeBytes(
      archive,
      level: isCompressed ? DeflateLevel.defaultCompression : DeflateLevel.none,
    );
  }

  /// Adds a new [NdArray] to the [NpzFile] with the given [name]. If [replace]
  /// is set to `true`, an existing [NdArray] with the same [name] will be
  /// replaced. If set to `false` and an [NdArray] with the same [name] exists,
  /// an [NpyFileExistsException] will be thrown. The default value is `false`.
  void add(NdArray array, {String? name, bool replace = false}) {
    if (name != null) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty || trimmedName == '.' || trimmedName == '..') {
        throw const NpyInvalidNameException(
          "Name cannot be empty, '.' or '..'.",
        );
      } else if (RegExp(r'[<>:"/\\|?*]').hasMatch(trimmedName)) {
        throw NpyInvalidNameException(
          "'$name' has one or more invalid characters. Invalid characters: '<>:\"/\\|?*'.",
        );
      }
    }

    final assignedName = name?.trim() ?? 'arr_${files.length}.npy';

    if (!replace && files.containsKey(assignedName)) {
      throw NpyFileExistsException(
        "'$assignedName' already exists in the NPZ file.",
      );
    }

    files[assignedName] = array;
  }

  /// Returns the [NdArray] with the given [name]. If the [NdArray] does not
  /// exist, an [NpyFileNotExistsException] will be thrown.
  NdArray take(String name) {
    final ndarray = files[name];
    if (ndarray == null) throw NpyFileNotExistsException(name);
    return files[name]!;
  }
}
