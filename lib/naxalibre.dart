import 'naxalibre_platform_interface.dart';
import 'package:flutter/material.dart';

class NaxaLibre {
  Future<String?> getPlatformVersion() {
    return NaxaLibrePlatform.instance.getPlatformVersion();
  }
}

class MapLibreView extends StatelessWidget {
  const MapLibreView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = {
      'styleURL':
          'https://tiles.basemaps.cartocdn.com/gl/positron-gl-style/style.json'
    };

    return NaxaLibrePlatform.instance.buildMapView(
      creationParams: creationParams,
    );
  }
}
