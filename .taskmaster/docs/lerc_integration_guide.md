# LERC Terrain Integration Guide for Naxalibre

## Overview

This document outlines the process for integrating LERC (Limited Error Raster Compression) terrain visualization from the FlightCanvas Terrain project into the Naxalibre application. LERC is a technology developed by ESRI for efficient compression and storage of raster imagery, particularly suitable for terrain elevation data.

## LERC Library Components

### Native Code Components

The FlightCanvas Terrain project uses the following key components for LERC decoding:

1. **LERC C++ Library**:
   - Located in `/lerc-master/` directory
   - Contains the core LERC compression/decompression algorithms
   - Downloaded from Esri GitHub repository (version 4.0.0)

2. **C Wrapper**:
   - Located in `/src/lerc_wrapper.h` and `/src/lerc_wrapper.cpp`
   - Provides a simplified C API around the C++ LERC library for FFI compatibility
   - Defines key structures like `LercInfo` and provides functions for initialization, decoding, and memory management

3. **Platform-Specific Build Configurations**:
   - CMakeLists.txt for cross-platform configuration
   - Android-specific settings in CMake for different ABIs
   - iOS-specific build scripts and framework configuration

### Dart Integration Components

1. **FFI Bindings**:
   - Generated using `ffigen` package
   - Configuration in `ffigen.yaml`
   - Output file: `lib/src/bindings/lerc_bindings.dart`

2. **Dart Wrapper Classes**:
   - `LercDecoder` class for interfacing with the native library
   - Helper classes for terrain data management
   - Isolate-based decoding for performance

## Integration Process

### Step 1: Set Up Project Structure

Create the following directory structure in the Naxalibre project:

```
naxalibre/
├── terrain/
│   ├── lerc-master/         # LERC library source code
│   ├── src/                 # C wrapper code
│   ├── CMakeLists.txt       # Build configuration
│   ├── build_native.sh      # Build script
│   └── ffigen.yaml          # FFI configuration
└── example/
    ├── assets/              # Terrain data assets
    └── lib/
        └── views/
            └── terrain/     # Terrain visualization UI
```

### Step 2: Copy LERC Library and Build Configuration

1. Copy the LERC library source code:
   ```bash
   mkdir -p /path/to/naxalibre/terrain/lerc-master
   cp -r /path/to/flightcanvas_terrain/lerc-master/* /path/to/naxalibre/terrain/lerc-master/
   ```

2. Copy the C wrapper code:
   ```bash
   mkdir -p /path/to/naxalibre/terrain/src
   cp /path/to/flightcanvas_terrain/src/lerc_wrapper.h /path/to/naxalibre/terrain/src/
   cp /path/to/flightcanvas_terrain/src/lerc_wrapper.cpp /path/to/naxalibre/terrain/src/
   ```

3. Copy the build configuration files:
   ```bash
   cp /path/to/flightcanvas_terrain/CMakeLists.txt /path/to/naxalibre/terrain/
   cp /path/to/flightcanvas_terrain/build_native.sh /path/to/naxalibre/terrain/
   cp /path/to/flightcanvas_terrain/ffigen.yaml /path/to/naxalibre/terrain/
   ```

### Step 3: Set Up FFI Binding Generation

1. Update `ffigen.yaml` to reflect the new project structure:

```yaml
name: LercBindings
description: Bindings for LERC decoder
output: '../lib/src/bindings/lerc_bindings.dart'
headers:
  entry-points:
    - 'src/lerc_wrapper.h'
  include-directives:
    - 'src/lerc_wrapper.h'
compiler-opts:
  - '-I.'
  - '-Ilerc-master/src'
  - '-x'
  - 'c'
  - '-DLERC_STATIC'
preamble: |
  // ignore_for_file: unused_element, unused_field, camel_case_types, non_constant_identifier_names, unused_import
comments:
  style: any
  length: full
structs:
  include:
    - 'LercInfo'
functions:
  include:
    - 'lerc_.*'
```

2. Generate the bindings:

```bash
cd /path/to/naxalibre/terrain
dart pub global run ffigen --config ffigen.yaml
```

### Step 4: Update Build Scripts for Naxalibre

1. Modify `CMakeLists.txt` to ensure the output paths match Naxalibre's structure:

```cmake
# For Android, output to the jniLibs directory
set_target_properties(lerc_wrapper PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../android/src/main/jniLibs/${ANDROID_ABI}"
    OUTPUT_NAME "lerc_wrapper"
    PREFIX "lib"
)
```

2. Update the iOS build configuration:

```cmake
# For iOS, use a proper framework structure
set_target_properties(lerc_wrapper PROPERTIES
    FRAMEWORK TRUE
    MACOSX_FRAMEWORK_IDENTIFIER com.example.lercwrapper
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../ios/Frameworks"
    OUTPUT_NAME "lerc_wrapper"
)
```

3. Update `build_native.sh` to reflect the new paths:

```bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Android paths
ANDROID_OUTPUT_DIR="../android/src/main/jniLibs"

# iOS paths
IOS_OUTPUT_DIR="../ios/Frameworks/lerc_wrapper.framework"
```

### Step 5: Copy and Adapt Dart Code

1. Copy the key Dart classes:

```bash
mkdir -p /path/to/naxalibre/lib/src/terrain
cp /path/to/flightcanvas_terrain/lib/src/lerc_decoder.dart /path/to/naxalibre/lib/src/terrain/
cp /path/to/flightcanvas_terrain/lib/src/lerc_tile_layer.dart /path/to/naxalibre/lib/src/terrain/
cp /path/to/flightcanvas_terrain/lib/src/hillshade_layer.dart /path/to/naxalibre/lib/src/terrain/
cp /path/to/flightcanvas_terrain/lib/src/terrain_cache.dart /path/to/naxalibre/lib/src/terrain/
```

2. Update imports and any platform-specific code in the Dart files

### Step 6: Copy Terrain Assets

1. Copy the LERC terrain data files:

```bash
mkdir -p /path/to/naxalibre/example/assets/terrain
cp /path/to/flightcanvas_terrain/assets/*.lerc2 /path/to/naxalibre/example/assets/terrain/
```

2. Update the `pubspec.yaml` to include the assets:

```yaml
flutter:
  assets:
    - assets/terrain/
```

## Platform-Specific Considerations

### Android

1. The LERC wrapper library is compiled for multiple ABIs (armeabi-v7a, arm64-v8a, x86, x86_64)
2. Output files should be placed in the `android/src/main/jniLibs/${ANDROID_ABI}` directory
3. In Dart code, the library is loaded using the `mbtiles://` protocol for Android

### iOS

1. The LERC wrapper is compiled as a framework
2. Bitcode embedding is required for iOS builds
3. The framework should be placed in the `ios/Frameworks` directory
4. CocoaPods integration requires updating the `.podspec` file

## Performance Considerations

1. Use isolates for decoding LERC data to avoid blocking the UI thread
2. Implement caching to reduce repetitive decoding of the same tiles
3. Configure timer settings appropriately for different device capabilities
4. Implement progressive loading for better user experience

## Troubleshooting

### Common Issues

1. **Library not found errors**: Ensure the native libraries are being compiled to the correct locations and included in the app bundle.
2. **Binding generation failures**: Check the ffigen configuration and ensure the C wrapper header is correctly formatted.
3. **iOS framework integration issues**: Verify that the framework is correctly referenced in the podspec file.

### Debugging Tips

1. Use `flutter doctor -v` to verify your development environment
2. Check that the native libraries are correctly bundled in the app using `unzip -l your_app.apk | grep lerc`
3. Add verbose logging to the build scripts and Dart code to identify issues

## References

1. [LERC GitHub Repository](https://github.com/Esri/lerc)
2. [Dart FFI Documentation](https://dart.dev/guides/libraries/c-interop)
3. [ffigen Package](https://pub.dev/packages/ffigen)
4. [CMake Documentation](https://cmake.org/documentation/)
