# NaxaLibre

[![Pub](https://img.shields.io/pub/v/naxalibre)](https://pub.dev/packages/naxalibre)
[![License](https://img.shields.io/github/license/itheamc/naxalibre)](https://github.com/itheamc/naxalibre/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/itheamc/naxalibre.svg?style=social)](https://github.com/itheamc/naxalibre)

## Introduction

This is **_Naxalibre_**, a custom MapLibre plugin proudly developed
by [@itheamc](https://github.com/itheamc/), to enhance mapping capabilities and streamline
geospatial workflows. It allows you to embed MapLibre Map to your flutter app. This plugin uses the
latest
version of the MapLibre Map SDK (Android ```v11.8.2``` and iOS ```6.11.0```) so that you can
experience all the latest feature introduced.

### How to show users current location on Map (location puck)?

If you want to show the current location indicator (location puck) on map then you have to
set ```locationEnabled: true``` on ```LocationSettings()``` in ```NaxaLibreMap()```.

And add these permissions to the ```AndroidManifest.xml``` for Android

```
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

And add these permissions to the ```Info.plist``` for iOS

```
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to show it on the map.</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>We need your location to show it on the map.</string>
```

### How to add NaxaLibreMap?

You have to use ```NaxaLibreMap()``` widget to add map in your page.

```
    NaxaLibreMap(
      style: "your-style-url or json style string",
      locationSettings: LocationSettings(
        locationEnabled: true,
        shouldRequestAuthorizationOrPermission: true,
        locationComponentOptions: LocationComponentOptions(
          pulseColor: "red",
          backgroundTintColor: "yellow",
          foregroundTintColor: "green",
        ),
        locationEngineRequestOptions: LocationEngineRequestOptions(
          displacement: 10,
          priority: LocationEngineRequestPriority.highAccuracy,
          provider: LocationProvider.gps,
        ),
      ),
      hyperComposition: true,
      onMapCreated: onMapCreated,
      onStyleLoaded: () {
        
      },
      onMapLoaded: () {
        
      },
      onMapClick: (latLng) {
        
      },
      onMapLongClick: (latLng) {
        
      },
    )
```

### How to add style source?

This api supports all the style sources that is supported by the latest MapLibre Map SDK. You can
add
the style source like this.

```
    await _controller.addSource<GeoJsonSource>(
          source: GeoJsonSource(
            sourceId: "geojson-source-id",
            url: "https://d2ad6b4ur7yvpq.cloudfront.net/naturalearth-3.3.0/ne_10m_land_ocean_label_points.geojson",
            // geoJson: GeoJson.fromFeature(
            //   Feature.fromGeometry(
            //      Geometry.point(coordinates: [85.331033, 27.741712]),
            //      id: "1",
            //      properties: {"name": "Amit"},
            //   ),
            // ),
            sourceProperties: GeoJsonSourceProperties(
              cluster: true,
              clusterRadius: 50,
              clusterMaxZoom: 14,
              maxZoom: 20,
            ),
          ),
        )
```

### How to add style layer?

Like sources, this api also supports all the style layers that is supported by the latest MapLibre
Map
SDK. You can add the style layer like this.

```
    // Circle Layer
    await _controller.addLayer<CircleLayer>(
          layer: CircleLayer(
            layerId: "my-layer-id",
            sourceId: "geojson-source-id",
            layerProperties: CircleLayerProperties(
              circleColor: [
                'case',
                [
                  'boolean',
                  ['has', 'point_count'],
                  true
                ],
                'red',
                'blue'
              ],
              circleColorTransition: StyleTransition.build(
                delay: 500,
                duration: const Duration(milliseconds: 1000),
              ),
              circleRadius: [
                'case',
                [
                  'boolean',
                  ['has', 'point_count'],
                  true
                ],
                15,
                10
              ],
              circleStrokeWidth: [
                'case',
                [
                  'boolean',
                  ['has', 'point_count'],
                  true
                ],
                3,
                2
              ],
              circleStrokeColor: "#fff",
              circleTranslateTransition: StyleTransition.build(
                delay: 0,
                duration: const Duration(milliseconds: 1000),
              ),
            ),
          ),
        );
        
    // Symbol Layer
    await _controller.addLayer<SymbolLayer>(
      layer: SymbolLayer(
        layerId: "symbol-layer-example",
        sourceId: "geojson-source-id",
        layerProperties: SymbolLayerProperties(
          textField: ['get', 'point_count_abbreviated'],
          textSize: 12,
          textColor: '#fff',
          iconSize: 1,
          iconAllowOverlap: true,
        ),
      ),
    );
```

### How to add style image?

You can add style image from your assets or from the url. Svg image is not supported yet.

```
    // Add image stored on assets
    await _controller.addStyleImage<LocalStyleImage>(
          image: LocalStyleImage(
            imageId: "icon",
            imageName: "assets/images/your-image.png",
          ),
        );
    
    
    // Add image from url
    await _controller.addStyleImage<NetworkStyleImage>(
      image: NetworkStyleImage(
        imageId: "icon",
        url: "https://example.com/icon.png",
      ),
    );
```

### Supported MapLibre Api

| Feature              | Android            | iOS                | 
|----------------------|--------------------|--------------------| 
| Style                | :white_check_mark: | :white_check_mark: | 
| Camera               | :white_check_mark: | :white_check_mark: | 
| Current Location     | :white_check_mark: | :white_check_mark: |
| Circle Layer         | :white_check_mark: | :white_check_mark: | 
| Line Layer           | :white_check_mark: | :white_check_mark: | 
| Fill Layer           | :white_check_mark: | :white_check_mark: | 
| Symbol Layer         | :white_check_mark: | :white_check_mark: | 
| Raster Layer         | :white_check_mark: | :white_check_mark: | 
| Hillshade Layer      | :white_check_mark: | :white_check_mark: | 
| Heatmap Layer        | :white_check_mark: | :white_check_mark: | 
| Fill Extrusion Layer | :white_check_mark: | :white_check_mark: |
| Background Layer     | :white_check_mark: | :white_check_mark: |
| Vector Source        | :white_check_mark: | :white_check_mark: | 
| Raster Source        | :white_check_mark: | :white_check_mark: | 
| RasterDem Source     | :white_check_mark: | :white_check_mark: | 
| GeoJson Source       | :white_check_mark: | :white_check_mark: | 
| Image Source         | :white_check_mark: | :white_check_mark: |
| Expressions          | :white_check_mark: | :white_check_mark: |
| Transitions          | :white_check_mark: | :white_check_mark: |
| Annotations          | :x:                | :x:                |
| Offline Manager      | :x:                | :x:                |



