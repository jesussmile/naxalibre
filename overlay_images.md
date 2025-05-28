# Implementing Image Overlays in NaxaLibre Flutter Plugin

This document details the process of adding image overlays to a map using the NaxaLibre Flutter plugin, covering both network-fetched images and local asset images, along with interactive controls and camera animations.

## 1. Project Setup

To begin, we need to prepare the Flutter example project to include local assets.

### 1.1. Create Assets Folder

First, create an `assets` directory within the `example/` project to store local image files.

```bash
mkdir -p example/assets
```

Place your image file (e.g., `overlay_image.jpeg`) inside this `example/assets/` directory.

### 1.2. Update `pubspec.yaml`

Declare the `assets/` folder in `example/pubspec.yaml` so Flutter knows to bundle these resources with the application. Also, add the `path_provider` dependency, which is crucial for handling local asset files on native platforms.

```yaml
# example/pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/

dependencies:
  # ... existing dependencies ...
  path_provider: ^2.1.3 # For saving assets to temporary files
```

After modifying `pubspec.yaml`, run `flutter pub get` in the `example/` directory to fetch the new dependency.

```bash
cd example && flutter pub get
```

## 2. Core Image Overlay Implementation (`ImageOverlayScreen`)

A new screen, `ImageOverlayScreen`, was created to demonstrate the image overlay functionality. This screen utilizes `NaxaLibreMap`, `ImageSource`, and `RasterLayer`.

### 2.1. Create `ImageOverlayScreen`

Create the file `example/lib/views/features/image_overlay/image_overlay_screen.dart`:

```bash
mkdir -p example/lib/views/features/image_overlay && touch example/lib/views/features/image_overlay/image_overlay_screen.dart
```

### 2.2. Initial Screen Structure

The `ImageOverlayScreen` contains a `NaxaLibreMap` widget. The map style is set to a public CartoDB style to avoid API key issues, and the initial camera position is set to center on Nepal.

```dart
// example/lib/views/features/image_overlay/image_overlay_screen.dart
import 'package:flutter/material.dart';
import 'package:naxalibre/naxalibre.dart';
import 'package:naxalibre/src/sources/source.dart';
import 'package:naxalibre/src/layers/layer.dart';
import 'package:naxalibre/src/models/latlng.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:naxalibre/src/models/latlng_quad.dart';
import 'package:naxalibre/src/models/naxalibre_map_options.dart';
import 'package:naxalibre/src/models/camera_position.dart';
import 'package:naxalibre/src/models/camera_update.dart'; // Added for CameraUpdateFactory

class ImageOverlayScreen extends StatefulWidget {
  const ImageOverlayScreen({super.key});

  @override
  State<ImageOverlayScreen> createState() => _ImageOverlayScreenState();
}

class _ImageOverlayScreenState extends State<ImageOverlayScreen> {
  NaxaLibreController? _controller;
  String _currentImageUrl = "https://docs.mapbox.com/mapbox-gl-js/assets/radar.gif";
  bool _isNetworkImage = true;

  final String _networkImageUrl = "https://docs.mapbox.com/mapbox-gl-js/assets/radar.gif";
  final String _assetImageUrl = "assets/overlay_image.jpeg"; // Path to your local asset

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Overlay')),
      body: Stack(
        children: [
          NaxaLibreMap(
            style: "https://tiles.basemaps.cartocdn.com/gl/positron-gl-style/style.json",
            mapOptions: NaxaLibreMapOptions(
              position: CameraPosition(
                target: LatLng(27.7172, 85.3240), // Center of Nepal (Kathmandu)
                zoom: 6.0,
              ),
            ),
            onMapCreated: (controller) {
              debugPrint("[ImageOverlayScreen] Map created, controller set.");
              _controller = controller;
            },
            onStyleLoaded: () async {
              debugPrint("[ImageOverlayScreen] Style loaded. Attempting to add image source and layer.");
              _addImageOverlay();
            },
          ),
          // ... Buttons will be added here ...
        ],
      ),
    );
  }

  // ... _addImageOverlay and _loadAssetImageAsFileUrl methods will be here ...
}
```

## 3. Handling Image Types (Network vs. Asset)

The `ImageSource` in NaxaLibre expects a URL. While network URLs work directly, local Flutter asset paths (`assets/image.jpeg`) are not directly resolvable by the native MapLibre SDK. To overcome this, local assets are read as bytes, saved to a temporary file, and then a `file://` URL to this temporary file is provided to `ImageSource`.

### 3.1. `_addImageOverlay` Function

This function is responsible for adding the `ImageSource` and `RasterLayer` to the map. It first removes any existing image layers/sources to ensure only one is active at a time.

```dart
// Inside _ImageOverlayScreenState class
Future<void> _addImageOverlay() async {
  // Define the coordinates for the four corners of your image (Nepal bounds)
  final LatLngQuad imageCoordinates = LatLngQuad(
    LatLng(30.5, 80.0), // Top-left (northwest)
    LatLng(30.5, 88.0), // Top-right (northeast)
    LatLng(26.0, 88.0), // Bottom-right (southeast)
    LatLng(26.0, 80.0), // Bottom-left (southwest)
  );

  // Remove existing source and layer if they exist
  await _controller?.removeLayer("my-overlay-image-layer");
  await _controller?.removeSource("my-overlay-image-source");

  String imageUrlToUse = _currentImageUrl;
  if (!_isNetworkImage) {
    imageUrlToUse = await _loadAssetImageAsFileUrl(_assetImageUrl);
    debugPrint("[ImageOverlayScreen] Asset image URL: $imageUrlToUse");
  }

  // Add the ImageSource
  await _controller?.addSource<ImageSource>(
    source: ImageSource(
      sourceId: "my-overlay-image-source",
      url: imageUrlToUse,
      coordinates: imageCoordinates,
      sourceProperties: ImageSourceProperties(prefetchZoomDelta: 4),
    ),
  );

  // Add a RasterLayer to display the image
  await _controller?.addLayer<RasterLayer>(
    layer: RasterLayer(
      layerId: "my-overlay-image-layer",
      sourceId: "my-overlay-image-source",
      layerProperties: RasterLayerProperties(
        rasterOpacity: 1.0, // Ensure the image is fully opaque
      ),
    ),
  );
  debugPrint("[ImageOverlayScreen] Image overlay added: $imageUrlToUse");

  // Animate camera to the center of Nepal
  await _controller?.animateCamera(
    CameraUpdateFactory.newLatLng(
      LatLng(28.25, 84.0), // Approximate center of Nepal
      6.0, // Adjust zoom level as needed to fit the image
    ),
    duration: const Duration(milliseconds: 500),
  );
}
```

### 3.2. `_loadAssetImageAsFileUrl` Function

This helper function reads a Flutter asset as `ByteData`, writes it to a temporary file on the device's file system, and returns a `file://` URL to that temporary file.

```dart
// Inside _ImageOverlayScreenState class
Future<String> _loadAssetImageAsFileUrl(String assetPath) async {
  try {
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(bytes);
    return 'file://${file.path}';
  } catch (e) {
    debugPrint("[ImageOverlayScreen] Error loading asset image: $e");
    return ""; // Return empty string or handle error appropriately
  }
}
```

## 4. User Interface (Buttons)

Two `ElevatedButton` widgets are added to the bottom of the screen, allowing the user to switch between displaying the network image and the local asset image.

```dart
// Inside _ImageOverlayScreenState's build method, within the Stack
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentImageUrl = _networkImageUrl;
                      _isNetworkImage = true;
                    });
                    _updateImageOverlay();
                  },
                  child: const Text('Show Network Image'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentImageUrl = _assetImageUrl;
                      _isNetworkImage = false;
                    });
                    _updateImageOverlay();
                  },
                  child: const Text('Show Asset Image'),
                ),
              ],
            ),
          ),
```

### 4.1. `_updateImageOverlay` Function

This function is called when the buttons are pressed. It triggers `_addImageOverlay` to update the map with the selected image.

```dart
// Inside _ImageOverlayScreenState class
Future<void> _updateImageOverlay() async {
  if (_controller != null) {
    await _addImageOverlay();
  } else {
    debugPrint("[ImageOverlayScreen] Controller not ready for update.");
  }
}
```

## 5. Integrating into `HomeScreen`

Finally, a new feature card is added to `example/lib/views/features/home/home_screen.dart` to navigate to the `ImageOverlayScreen`.

```dart
// example/lib/views/features/home/home_screen.dart
import 'package:naxalibre_example/views/features/image_overlay/image_overlay_screen.dart'; // Add this import

// ... inside the ListView children ...
          _ModernFeatureCard(
            title: 'Image Overlay',
            description: 'Add and manage image overlays on the map',
            icon: Icons.image_outlined,
            iconColor: Colors.pinkAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImageOverlayScreen()),
                ),
          ),
```

## 6. Troubleshooting & Key Learnings

During the implementation, several challenges were encountered and resolved:

*   **White Map**: Initially, the map appeared white due to a placeholder MapTiler API key. This was resolved by switching to a publicly accessible CartoDB map style (`https://tiles.basemaps.cartocdn.com/gl/positron-gl-style/style.json`).
*   **`initialCameraPosition` Parameter**: The `NaxaLibreMap` widget does not directly accept `initialCameraPosition`. Instead, the camera position is set via the `mapOptions` parameter using `NaxaLibreMapOptions(position: CameraPosition(...))`.
*   **`CameraUpdateFactory.newLatLngZoom` Error**: The `CameraUpdateFactory` does not have a `newLatLngZoom` method. The correct method to use for setting both latitude/longitude and zoom is `CameraUpdateFactory.newLatLng(LatLng, zoom)`.
*   **Asset Image Loading on Native Platforms**: The primary challenge was loading local Flutter assets (`assets/overlay_image.jpeg`) as `ImageSource` URLs. The native MapLibre SDK expects standard URLs (HTTP/HTTPS or `file://`). Directly using `assets/` paths does not work. The solution involved:
    1.  Adding `path_provider` to save assets to temporary files.
    2.  Reading asset bytes using `rootBundle.load()`.
    3.  Writing bytes to a temporary file using `dart:io.File`.
    4.  Providing the `file://` URL of the temporary file to `ImageSource`.
*   **CocoaPods Issue**: A build error related to CocoaPods (for iOS) was encountered. This was resolved by ensuring CocoaPods was correctly installed and that `flutter clean` and `flutter pub get` were run to refresh native dependencies.

## 7. How to Run and Test

1.  **Ensure your image file (`overlay_image.jpeg`) is in `example/assets/`.**
2.  Navigate to the `example/` directory in your terminal.
3.  Run `flutter clean` to clear any old build artifacts.
4.  Run `flutter pub get` to ensure all dependencies are correctly resolved, including `path_provider`.
5.  Run the application: `flutter run`.
6.  Once the app launches, navigate to the "Image Overlay" feature from the home screen.
7.  Test both "Show Network Image" and "Show Asset Image" buttons to verify the functionality and camera animation.
