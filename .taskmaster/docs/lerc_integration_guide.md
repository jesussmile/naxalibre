# LERC Terrain Integration Guide for Naxalibre

## Overview

This document outlines the process for integrating LERC (Limited Error Raster Compression) terrain visualization from the FlightCanvas Terrain project into the Naxalibre application. LERC is a technology developed by ESRI for efficient compression and storage of raster imagery, particularly suitable for terrain elevation data.

> **IMPORTANT**: The FlightCanvas Terrain code and implementation should be treated as reference only. All implementations for Naxalibre should be created as new code within the Naxalibre project structure without modifying the original FlightCanvas Terrain files.

## 1. Analysis of FlightCanvas Terrain LERC Implementation

### 1.1 Native Code Components

The FlightCanvas Terrain project uses the following key components for LERC decoding:

1. **LERC C++ Library**:
   - Located in `/lerc-master/` directory in FlightCanvas Terrain
   - Contains the core LERC compression/decompression algorithms
   - Downloaded from Esri GitHub repository (version 4.0.0)
   - Key files:
     - `LercLib/Lerc.cpp` and `Lerc.h`: Main interfaces
     - `LercLib/Lerc2.cpp`: Version 2 implementation
     - `LercLib/Lerc_c_api_impl.cpp`: C API implementation
     - Various utility classes for bit manipulation and compression

2. **C Wrapper**:
   - Located in `/src/lerc_wrapper.h` and `/src/lerc_wrapper.cpp`
   - Provides a simplified C API around the C++ LERC library for FFI compatibility
   - Defines key structures and functions:
     - `LercInfo` struct for metadata
     - Functions for initialization, decoding, and memory management:
       - `lerc_wrapper_initialize()`
       - `lerc_wrapper_get_info()`
       - `lerc_wrapper_decode()`
       - `lerc_wrapper_free_info()`
       - `lerc_wrapper_free_data()`

3. **Platform-Specific Build Configurations**:
   - CMakeLists.txt for cross-platform configuration
   - Android-specific settings in CMake for different ABIs (armeabi-v7a, arm64-v8a, x86, x86_64)
   - iOS-specific build scripts (setup_lerc_ios.sh, compile_lerc_ios.sh) and framework configuration

### 1.2 Dart Integration Components

1. **FFI Bindings**:
   - Generated using the `ffigen` package
   - Configuration in `ffigen.yaml` specifies:
     - Output file: `lib/src/bindings/lerc_bindings.dart`
     - Header entry point: `src/lerc_wrapper.h`
     - Compiler options for platform-specific includes
     - Preamble for generated file
     - Filters to include only relevant structs and functions

2. **Dart Wrapper Classes**:
   - `LercDecoder` class in `lib/src/lerc_decoder.dart` provides a high-level interface
   - `DecodedLercData` class represents decoded terrain data with methods for:
     - Accessing elevation values
     - Getting subregions
     - Height/width information
     - Min/max elevation values
   - Uses isolate-based decoding for non-blocking UI performance

### 1.3 Rendering Pipeline

1. **Data Flow**:
   - LERC binary data is read from assets or downloaded
   - Native C++ code decodes the binary data into elevation values
   - Dart code processes the elevation data into a format usable for visualization
   - Terrain is rendered using custom layers

2. **Platform-Specific Integration**:
   - **Android**: 
     - Native libraries loaded from app/src/main/jniLibs/${ANDROID_ABI}
     - DynamicLibrary.open() locates the appropriate library
     - Build process managed through CMake and Gradle

   - **iOS**:
     - Framework-based approach
     - Libraries bundled in ios/Frameworks
     - Platform-specific settings like bitcode embedding
     - CocoaPods for integration

## 2. MapLibre's Terrain and Hillshade Capabilities

MapLibre supports terrain visualization through:

1. **Terrain-RGB and DEM (Digital Elevation Model)**:
   - Can load and visualize DEM data in various formats
   - Supports standard Mapbox Terrain-RGB format
   - Has built-in hillshade functionality

2. **Hillshade Implementation**:
   - Renders hillshade based on light direction and terrain data
   - Configurable parameters for light angle, intensity, and shadow effects
   - Can be applied as a layer over base maps

3. **Differences from FlightCanvas Approach**:
   - MapLibre primarily uses web-standard formats vs. FlightCanvas's LERC-based approach
   - MapLibre integrates terrain as a layer in its existing rendering pipeline
   - FlightCanvas uses a custom decoder and rendering pipeline specific to LERC

## 3. Integration Options Comparison

### Option 1: Using MapLibre's Built-in Terrain/Hillshade Features

**Pros:**
- Already integrated with MapLibre ecosystem
- Optimized for web and mobile rendering
- Lower implementation effort
- Well-documented standard approach

**Cons:**
- Less control over the rendering pipeline
- May not support offline LERC formats directly
- Visual quality may differ from FlightCanvas

### Option 2: Porting FlightCanvas's LERC Implementation

**Pros:**
- Potentially higher visual quality for aviation use cases
- Direct control over terrain visualization algorithms
- Better offline support with LERC's efficient compression
- Consistent with existing FlightCanvas visuals

**Cons:**
- Higher implementation complexity
- Need to maintain custom native code across platforms
- Potential performance challenges on lower-end devices
- Integration effort with MapLibre's rendering pipeline

### Performance Considerations

- LERC typically offers better compression for efficient offline storage
- MapLibre's implementation may have better optimization for online streaming
- Custom LERC implementation allows fine-tuning for specific aviation use cases
- Different formats may vary in load time vs. rendering performance tradeoffs

### Visual Quality Comparison

- LERC can retain more detail at equivalent file size
- MapLibre's approach may be more optimized for general cartographic appearance
- Aviation-specific visualization needs (e.g., precise altitude rendering) may be better served by custom implementation

## 4. Technical Feasibility and Compatibility Analysis

### 4.1 Integration Challenges

1. **Architectural Differences**:
   - FlightCanvas uses a dedicated rendering pipeline for terrain
   - Naxalibre uses MapLibre as its mapping foundation
   - These different architectures require careful adaptation

2. **Platform-Specific Challenges**:
   - **Android**: 
     - NDK and Gradle integration differences
     - ABI compatibility across device types
     - Native library loading and memory management

   - **iOS**:
     - Differences in framework structure and embedding
     - Bitcode and architecture support variations
     - CocoaPods integration approach

3. **Required Modifications**:
   - New bridge between LERC decoder and MapLibre rendering system
   - Custom layer implementations in MapLibre
   - Memory management optimizations for mobile devices
   - Platform-specific build system adaptations

### 4.2 Compatibility Assessment

1. **Code Compatibility**:
   - LERC C++ code is largely portable between projects
   - C wrapper needs minimal adaptation
   - Dart FFI approach is compatible with both projects
   - Build systems require significant reconfiguration

2. **Runtime Compatibility**:
   - Potential conflicts in memory usage patterns
   - Threading model differences
   - Resource management across different application lifecycles

3. **Feasibility Rating**:
   - **Technical Feasibility**: High (7/10)
   - **Integration Effort**: Medium-High (6/10)
   - **Maintenance Complexity**: Medium (5/10)

## 5. LERC Bindings Generation Process

### 5.1 Understanding the LERC Library

1. **Core Components**:
   - The LERC library is a C++ library developed by Esri
   - Version 4.0.0 is used in the FlightCanvas implementation
   - The library provides encoding and decoding of raster data with limited error

2. **C++ Wrapper**:
   - In FlightCanvas, a C wrapper is created around the C++ library
   - This wrapper exposes key functions in a C API for FFI compatibility
   - The wrapper simplifies memory management and error handling

### 5.2 FFI Binding Generation

1. **Configure ffigen.yaml**:

```yaml
name: LercBindings
description: Bindings for LERC decoder
output: 'lib/src/bindings/lerc_bindings.dart'
headers:
  entry-points:
    - 'terrain/src/lerc_wrapper.h'
  include-directives:
    - 'terrain/src/lerc_wrapper.h'
compiler-opts:
  - '-I.'
  - '-Iterrain/lerc-master/src'
  # Platform-specific includes
  - '-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include'
  - '-I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include'
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

2. **Generate Bindings**:

```bash
# For macOS development
dart run ffigen --config ffigen.yaml

# For platform-specific generation
dart run ffigen --config ffigen.yaml --compiler-opts "-I/path/to/android/ndk/include"
```

3. **Key Generated Components**:
   - Dart class that wraps the native library: `LercBindings`
   - Function bindings for each C function
   - Structure definitions matching C structures
   - Type and memory management utilities

### 5.3 Platform-Specific Build Processes

#### Android Build Process

1. **CMake Configuration**:
   - Create a CMakeLists.txt file in the terrain directory
   - Define both static LERC library and shared wrapper library
   - Configure output paths for Android ABIs

2. **Build Script**:
   - Process different Android ABIs (armeabi-v7a, arm64-v8a, x86, x86_64)
   - Output libraries to android/app/src/main/jniLibs/${ANDROID_ABI}
   - Ensure proper naming convention (libname.so)

3. **Integration with Gradle**:
   - Add CMake configuration to build.gradle
   - Ensure externalNativeBuild section references the CMake file
   - Add NDK version requirements

#### iOS Build Process

1. **Framework Creation**:
   - Build static library for arm64 architecture
   - Create framework directory structure
   - Copy headers and binary into framework
   - Generate modulemap and Info.plist

2. **Build Scripts**:
   - setup_lerc_ios.sh: Downloads and sets up LERC source if needed
   - compile_lerc_ios.sh: Compiles the library for iOS architectures
   - Handles bitcode embedding and architecture-specific flags

3. **CocoaPods Integration**:
   - Create podspec file
   - Specify framework location and dependencies
   - Configure pod installation in Podfile

## 6. Step-by-Step Implementation Guide for Naxalibre

### 6.1 Set Up Project Structure

Create the following directory structure in the Naxalibre project:

```
naxalibre/
├── terrain/
│   ├── lerc-master/         # LERC library source code
│   ├── src/                 # C wrapper code
│   │   ├── lerc_wrapper.h
│   │   └── lerc_wrapper.cpp
│   ├── CMakeLists.txt       # Build configuration
│   ├── build_native.sh      # Main build script
│   ├── ffigen.yaml          # FFI configuration
│   ├── android/             # Android-specific files
│   │   └── build.gradle     # Android build config
│   └── ios/                 # iOS-specific files
│       ├── setup_lerc_ios.sh
│       ├── compile_lerc_ios.sh
│       └── LercWrapper.podspec
```

### 6.2 Set Up LERC Library

1. **Download LERC Library**:

```bash
mkdir -p terrain/lerc-master
cd terrain
curl -L https://github.com/Esri/lerc/archive/refs/tags/v4.0.0.zip -o lerc.zip
unzip lerc.zip
cp -r lerc-4.0.0/src/* lerc-master/
rm -rf lerc-4.0.0 lerc.zip
```

2. **Create C Wrapper**:

Create `terrain/src/lerc_wrapper.h`:

```c
#ifndef LERC_WRAPPER_H
#define LERC_WRAPPER_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint32_t width;
    uint32_t height;
    uint32_t numBands;
    uint32_t numValidPixels;
    double minValue;
    double maxValue;
    double noDataValue;
} LercInfo;

bool lerc_wrapper_initialize(void);
LercInfo* lerc_wrapper_get_info(const uint8_t* buffer, size_t size);
double* lerc_wrapper_decode(const uint8_t* buffer, size_t size, LercInfo* info);
void lerc_wrapper_free_info(LercInfo* info);
void lerc_wrapper_free_data(double* data);

#ifdef __cplusplus
}
#endif

#endif // LERC_WRAPPER_H
```

Create `terrain/src/lerc_wrapper.cpp`:

```cpp
#include "lerc_wrapper.h"
#include "Lerc_c_api.h"
#include <cstdio>

bool lerc_wrapper_initialize() {
    return true;
}

LercInfo* lerc_wrapper_get_info(const uint8_t* buffer, size_t size) {
    try {
        unsigned int infoArray[10];
        double dataRangeArray[3];
        
        lerc_status status = lerc_getBlobInfo(
            buffer,
            static_cast<unsigned int>(size),
            infoArray,
            dataRangeArray,
            10,
            3
        );
        
        if (status != 0) return nullptr;

        auto* info = new LercInfo{
            infoArray[3],
            infoArray[4],
            infoArray[5],
            infoArray[6],
            dataRangeArray[0],
            dataRangeArray[1],
            -9999.0
        };
        
        return info;
    } catch (...) {
        return nullptr;
    }
}

double* lerc_wrapper_decode(const uint8_t* buffer, size_t size, LercInfo* info) {
    try {
        if (!info) return nullptr;

        size_t numPixels = info->width * info->height;
        auto* floatData = new float[numPixels];
        auto* doubleData = new double[numPixels];

        lerc_status status = lerc_decode(
            buffer,
            static_cast<unsigned int>(size),
            0,
            nullptr,
            1,
            info->width,
            info->height,
            1,
            6,
            floatData
        );

        if (status != 0) {
            status = lerc_decode(
                buffer,
                static_cast<unsigned int>(size),
                0,
                nullptr,
                1,
                info->width,
                info->height,
                1,
                7,
                doubleData
            );

            if (status != 0) {
                delete[] floatData;
                delete[] doubleData;
                return nullptr;
            }

            delete[] floatData;
            return doubleData;
        }

        for (size_t i = 0; i < numPixels; i++) {
            doubleData[i] = static_cast<double>(floatData[i]);
        }

        delete[] floatData;
        return doubleData;
    } catch (...) {
        return nullptr;
    }
}

void lerc_wrapper_free_info(LercInfo* info) {
    delete info;
}

void lerc_wrapper_free_data(double* data) {
    delete[] data;
}
```

### 6.3 Configure Build System

1. **Create CMakeLists.txt**:

```cmake
cmake_minimum_required(VERSION 3.10)
project(lerc_decoder)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add LERC source files
set(LERC_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/Lerc.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/Lerc2.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/Lerc_c_api_impl.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/BitMask.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/BitStuffer2.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/Huffman.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/RLE.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/fpl_Compression.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/fpl_EsriHuffman.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/fpl_Lerc2Ext.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/fpl_Predictor.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/fpl_UnitTypes.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/Lerc1Decode/BitStuffer.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/Lerc1Decode/CntZImage.cpp"
)

# Create LERC library
add_library(lerc STATIC ${LERC_SOURCES})
target_include_directories(lerc PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/Lerc1Decode"
)

# Create FFI wrapper library
add_library(lerc_wrapper SHARED
    "src/lerc_wrapper.cpp"
)

target_link_libraries(lerc_wrapper PRIVATE lerc)
target_include_directories(lerc_wrapper PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/lerc-master/LercLib/Lerc1Decode"
)

# Platform-specific configurations
if(ANDROID)
    set_target_properties(lerc_wrapper PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../android/app/src/main/jniLibs/${ANDROID_ABI}"
        OUTPUT_NAME "lerc_wrapper"
        PREFIX "lib"
    )
elseif(IOS)
    set_target_properties(lerc_wrapper PROPERTIES
        FRAMEWORK TRUE
        MACOSX_FRAMEWORK_IDENTIFIER com.naxalibre.lercwrapper
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../ios/Frameworks"
        OUTPUT_NAME "lerc_wrapper"
    )
    
    # Set iOS-specific compile flags
    target_compile_options(lerc_wrapper PRIVATE -fembed-bitcode)
    
    # Make it a universal binary
    set_target_properties(lerc_wrapper PROPERTIES
        XCODE_ATTRIBUTE_ARCHS "arm64"
        XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO
        XCODE_ATTRIBUTE_VALID_ARCHS "arm64"
    )
else()
    # For desktop development
    set_target_properties(lerc_wrapper PROPERTIES OUTPUT_NAME "lerc_wrapper")
endif()
```

2. **Create build_native.sh**:

```bash
#!/bin/bash
# Script to build the native LERC wrapper for Android and iOS

# Exit on error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Ensure build directories exist
mkdir -p build-android
mkdir -p build-ios
mkdir -p ../ios/Frameworks/lerc_wrapper.framework

echo "==== Building LERC wrapper for Android ===="

# Android ABIs to target
ANDROID_ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

for ABI in "${ANDROID_ABIS[@]}"; do
  echo "Building for Android ABI: $ABI"
  
  mkdir -p "build-android/$ABI"
  pushd "build-android/$ABI"
  
  cmake -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM=android-21 \
        -DCMAKE_BUILD_TYPE=Release \
        "../.."
  
  cmake --build . --config Release
  popd
done

echo "==== Building LERC wrapper for iOS ===="

# Build for iOS arm64 architecture
mkdir -p build-ios
pushd build-ios

cmake .. \
  -G Xcode \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
  -DIOS=1 \
  -DCMAKE_INSTALL_PREFIX=install

# Build the Xcode project
xcodebuild -project lerc_decoder.xcodeproj \
  -scheme lerc_wrapper \
  -sdk iphoneos \
  -configuration Release \
  -arch arm64 \
  ONLY_ACTIVE_ARCH=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  clean build

# Complete iOS framework setup
# ... (iOS-specific framework setup)
```

### 6.4 Setup Dart Integration

1. **Create Dart FFI Bindings**:

First, add ffigen to `pubspec.yaml`:

```yaml
dependencies:
  ffi: ^2.0.1
  
dev_dependencies:
  ffigen: ^7.2.4
```

2. **Create Dart Wrapper Class**:

```dart
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'bindings/lerc_bindings.dart';

class DecodedLercData {
  final Float64List data;
  final int width;
  final int height;
  final double minValue;
  final double maxValue;

  DecodedLercData(
    this.data,
    this.width,
    this.height,
    this.minValue,
    this.maxValue,
  );

  bool isValid() {
    return data.isNotEmpty && width > 0 && height > 0;
  }

  // Get elevation at specific coordinates
  double getElevation(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return double.nan;
    return data[y * width + x];
  }
}

class LercDecoder {
  static final LercDecoder _instance = LercDecoder._internal();
  factory LercDecoder() => _instance;
  
  late final DynamicLibrary _nativeLib;
  late final LercBindings _bindings;
  bool _initialized = false;

  LercDecoder._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    
    _nativeLib = _loadLibrary();
    _bindings = LercBindings(_nativeLib);
    _initialized = _bindings.lerc_wrapper_initialize();
    
    if (!_initialized) {
      throw Exception('Failed to initialize LERC decoder');
    }
  }

  DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('liblerc_wrapper.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    } else {
      throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
    }
  }

  Future<DecodedLercData> decodeAsync(Uint8List data) async {
    // Use isolate for decoding to avoid blocking the UI thread
    final port = ReceivePort();
    await Isolate.spawn(_decodeIsolate, [port.sendPort, data]);
    final result = await port.first;
    
    if (result is! DecodedLercData) {
      throw Exception('Failed to decode LERC data');
    }
    
    return result;
  }
  
  static void _decodeIsolate(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final Uint8List data = args[1];
    
    try {
      final decoder = LercDecoder();
      decoder.initialize();
      final result = decoder.decode(data);
      sendPort.send(result);
    } catch (e) {
      sendPort.send(null);
    }
  }
  
  DecodedLercData decode(Uint8List data) {
    if (!_initialized) {
      throw StateError('LERC decoder not initialized');
    }
    
    final dataPtr = malloc<Uint8>(data.length);
    for (var i = 0; i < data.length; i++) {
      dataPtr[i] = data[i];
    }
    
    final infoPtr = _bindings.lerc_wrapper_get_info(dataPtr, data.length);
    if (infoPtr == nullptr) {
      malloc.free(dataPtr);
      throw Exception('Failed to get LERC info');
    }
    
    final width = infoPtr.ref.width;
    final height = infoPtr.ref.height;
    final minValue = infoPtr.ref.minValue;
    final maxValue = infoPtr.ref.maxValue;
    
    final decodedPtr = _bindings.lerc_wrapper_decode(dataPtr, data.length, infoPtr);
    malloc.free(dataPtr);
    
    if (decodedPtr == nullptr) {
      _bindings.lerc_wrapper_free_info(infoPtr);
      throw Exception('Failed to decode LERC data');
    }
    
    final size = width * height;
    final elevations = Float64List(size);
    
    for (var i = 0; i < size; i++) {
      elevations[i] = decodedPtr.elementAt(i).value;
    }
    
    _bindings.lerc_wrapper_free_data(decodedPtr);
    _bindings.lerc_wrapper_free_info(infoPtr);
    
    return DecodedLercData(
      elevations,
      width,
      height,
      minValue,
      maxValue,
    );
  }
}
```

### 6.5 Adapt for Naxalibre Project Structure

1. **Update Android Configuration**:

Add to `android/build.gradle`:

```gradle
android {
    // ... existing config
    
    externalNativeBuild {
        cmake {
            path "terrain/CMakeLists.txt"
        }
    }
    
    defaultConfig {
        // ... existing config
        
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
        }
    }
}
```

2. **Update iOS Configuration**:

Add to `ios/naxalibre.podspec`:

```ruby
  # ... existing config
  
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Include LERC framework
  s.vendored_frameworks = 'Frameworks/lerc_wrapper.framework'
  
  # ... existing config
```

## 7. Best Practices and Potential Pitfalls

### 7.1 Memory Management

1. **Common Issues**:
   - Memory leaks in native code
   - Failure to free native memory in Dart
   - Large terrain datasets exceeding mobile memory constraints

2. **Best Practices**:
   - Always pair allocations with deallocations
   - Use Dart finalizers for native resources
   - Consider streaming or tiling for large terrain data

### 7.2 Cross-Platform Compatibility

1. **Potential Issues**:
   - Differences in C++ ABI between platforms
   - Platform-specific bugs in LERC implementation
   - Build configuration differences

2. **Best Practices**:
   - Test on multiple device types and OS versions
   - Use conditional compilation for platform-specific code
   - Maintain separate build configurations for each platform

### 7.3 Performance Optimization

1. **Recommendations**:
   - Use background isolates for decoding
   - Implement caching for decoded terrain
   - Consider level-of-detail approaches for large terrains
   - Optimize memory usage with shared buffers where possible

### 7.4 Documentation and Maintenance

1. **Key Documentation**:
   - Keep build instructions up to date
   - Document API changes and platform-specific behaviors
   - Include examples for common usage patterns

2. **Maintenance Best Practices**:
   - Regular testing on new OS versions
   - Update dependencies (especially NDK and Xcode tooling)
   - Track upstream LERC library changes

## 8. Conclusion and Recommendations

Based on the analysis of both FlightCanvas Terrain's LERC implementation and MapLibre's capabilities, we recommend implementing a hybrid approach:

1. Use the LERC decoder from FlightCanvas as a reference to create a new, dedicated LERC decoder for Naxalibre
2. Integrate the decoded terrain data with MapLibre's rendering system using custom layers
3. Implement caching strategies similar to FlightCanvas but optimized for the Naxalibre use case

This approach balances the advantages of both systems while maintaining independence from the original FlightCanvas Terrain codebase.

## References

1. [Esri LERC GitHub Repository](https://github.com/Esri/lerc)
2. [Dart FFI Documentation](https://dart.dev/guides/libraries/c-interop)
3. [FFIgen Package](https://pub.dev/packages/ffigen)
4. [MapLibre Native Documentation](https://maplibre.org/maplibre-native/)
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
