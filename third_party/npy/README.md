[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/minhqdao/npy/blob/main/LICENSE)
[![CI](https://github.com/minhqdao/npy/actions/workflows/ci.yml/badge.svg)](https://github.com/minhqdao/npy/actions/workflows/ci.yml)

Read and write NumPy binary files (`.npy` and `.npz`) in Dart.

## Usage

Load an `ndarray` from an `.npy` file:

```dart
final ndarray = await NdArray.load('example.npy');
```

Create an `ndarray` and save it as an `.npy` file:

```dart
final ndarray = NdArray.fromList([1.0, 2.0, 3.0]);
await ndarray.save('example_save.npy');
```

Conveniently save an n-dimensional `List` to an `.npy` file:

```dart
await save('example_save.npy', [[1, 2, 3], [4, 5, 6]]);
```

Read (compressed) `.npz` files:

```dart
final npzFile = await NpzFile.load('example.npz');
final arr_0 = npzFile.take('arr_0.npy');
final arr_1 = npzFile.take('arr_1.npy');
```

Write (compressed) `.npz` files:

```dart
final array1 = NdArray.fromList([1.0, 2.0, 3.0]);
final array2 = NdArray.fromList([[true, false, true]]);

final npzFile = NpzFile();

npzFile.add(array1);
npzFile.add(array2);

await npzFile.save('example_save.npz');
```

## Features

Load and save n-dimensional arrays from and to the following file formats:

✅ `.npy` \
✅ `.npz` (compressed and uncompressed)

Supported data types:

✅ float64, float32\
✅ int64, int32, int16, int8\
✅ uint64, uint32, uint16, uint8\
✅ bool

Supported memory representations:

✅ Little and big endian\
✅ C and Fortran order

## Tests

`dart test` will run integration tests, too, so make sure to have `python` and `numpy` installed and `python` available in your system's `PATH`.

## Contribute

- Feel free to [create an issue](https://github.com/minhqdao/npy/issues) in case you found a bug, have any questions or want to propose new features.
- Please [check open issues](https://github.com/minhqdao/npy/issues) before creating a new one.
- Make sure to satisfy formatter, analyzer and tests when [opening a pull request](https://github.com/minhqdao/npy/pulls).

## Further Reading

More information on the `.npy` format can be found [here](https://numpy.org/doc/stable/reference/generated/numpy.lib.format.html).

## License

You can use, redistribute and/or modify the code under the terms of the [MIT License](https://github.com/minhqdao/npy/blob/main/LICENSE).
