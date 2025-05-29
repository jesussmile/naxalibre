import 'dart:io';
import 'dart:math' show Point, min, max;

import 'package:flutter/material.dart';
import 'package:naxalibre/naxalibre.dart';
import 'package:another_flushbar/flushbar.dart';

import '../base_map/base_map_screen.dart';
// Import for _LayerActionButton if we decide to use it, or define a similar button
// For now, let's use a simpler button or define one locally.
// import '../layers_management/widgets/layer_button.dart';

class InteractiveMarkersScreen extends BaseMapScreen {
  const InteractiveMarkersScreen({super.key})
    : super(title: 'Interactive Markers');

  @override
  State<InteractiveMarkersScreen> createState() =>
      _InteractiveMarkersScreenState();
}

class _InteractiveMarkersScreenState
    extends BaseMapScreenState<InteractiveMarkersScreen> {
  final Map<int, Map<String, dynamic>> _annotations = {};
  int? _draggedAnnotationId;
  String _draggedAnnotationInfo = "Tap 'Add Marker' to start.";

  // ID of the annotation that IS the text window itself
  int? _textWindowAnnotationId;
  // ID of the marker FOR WHICH the text window is shown
  int? _markerIdForTextWindow;

  OnAnnotationClick? _onAnnotationClickHandler;
  OnAnnotationDrag? _onAnnotationDragHandler;
  OnMapClick? _onMapClickHandler;

  bool _markerIconReady = false;
  bool _popupBgIconReady = false;

  // Adjusted path based on user providing path to example/assets/
  final String _popupBgAssetPath = 'assets/red_background_pop_up.jpg';

  @override
  void initState() {
    super.initState();
    // No need to call _ensureStyleImagesLoaded here,
    // onMapCreated will call it once controller is available.
  }

  Future<void> _ensureStyleImagesLoaded() async {
    print("[DEBUG] _ensureStyleImagesLoaded called.");
    if (controller == null || !mounted) {
      print(
        "[DEBUG] Controller null or not mounted. Aborting _ensureStyleImagesLoaded.",
      );
      return;
    }

    if (!_markerIconReady) {
      print(
        "[DEBUG] Checking marker_icon. _markerIconReady: $_markerIconReady",
      );
      bool? iconExistsInitially = false;
      try {
        iconExistsInitially = await controller?.isStyleImageExist('test_icon');
        print("[DEBUG] marker_icon exists initially? $iconExistsInitially");
      } catch (e) {
        print(
          "❌❌❌ Exception during controller.isStyleImageExist('test_icon'): $e",
        );
        iconExistsInitially = false;
      }

      if (iconExistsInitially == true) {
        if (mounted) setState(() => _markerIconReady = true);
        print("'test_icon' already exists.");
      } else {
        print("Attempting to load 'test_icon'...");
        try {
          await controller?.addStyleImage(
            image: NetworkStyleImage(
              imageId: 'test_icon',
              url:
                  'https://www.pngplay.com/wp-content/uploads/9/Map-Marker-PNG-Pic-Background.png',
            ),
          );
          bool? iconExistsAfterAdd = await controller?.isStyleImageExist(
            'test_icon',
          );
          print(
            "[DEBUG] marker_icon exists after add attempt? $iconExistsAfterAdd",
          );
          if (iconExistsAfterAdd == true) {
            if (mounted) setState(() => _markerIconReady = true);
            print("'test_icon' loaded successfully and verified.");
          } else {
            if (mounted) setState(() => _markerIconReady = false);
            print("❌❌❌ 'test_icon' load attempt failed verification.");
          }
        } catch (e) {
          print("❌❌❌ Exception while loading 'test_icon': $e");
          if (mounted) setState(() => _markerIconReady = false);
        }
      }
    } else {
      print("[DEBUG] marker_icon already ready.");
    }

    if (!_popupBgIconReady) {
      print(
        "[DEBUG] Checking popup_bg_icon. _popupBgIconReady: $_popupBgIconReady",
      );
      bool? bgExistsInitially = false;
      try {
        print(
          "[DEBUG] Attempting controller.isStyleImageExist('popup_bg_icon')...",
        );
        bgExistsInitially = await controller?.isStyleImageExist(
          'popup_bg_icon',
        );
        print(
          "[DEBUG] popup_bg_icon exists initially? $bgExistsInitially (after await)",
        );
      } catch (e) {
        print(
          "❌❌❌ Exception during controller.isStyleImageExist('popup_bg_icon'): $e",
        );
        bgExistsInitially = false;
      }

      if (bgExistsInitially == true) {
        if (mounted) setState(() => _popupBgIconReady = true);
        print("'popup_bg_icon' already exists.");
      } else {
        print(
          "[DEBUG] 'popup_bg_icon' does not exist initially or error occurred. Attempting to load asset: $_popupBgAssetPath",
        );
        try {
          await controller?.addStyleImage(
            image: LocalStyleImage(
              imageId: 'popup_bg_icon',
              imageName: _popupBgAssetPath,
            ),
          );
          bool? bgExistsAfterAdd = await controller?.isStyleImageExist(
            'popup_bg_icon',
          );
          print(
            "[DEBUG] popup_bg_icon exists after add attempt? $bgExistsAfterAdd",
          );
          if (bgExistsAfterAdd == true) {
            if (mounted) setState(() => _popupBgIconReady = true);
            print(
              "'popup_bg_icon' loaded successfully from asset and verified.",
            );
          } else {
            if (mounted) setState(() => _popupBgIconReady = false);
            print(
              "❌❌❌ 'popup_bg_icon' (asset) load attempt failed verification.",
            );
          }
        } catch (e) {
          print("❌❌❌ Exception while loading 'popup_bg_icon' from asset: $e");
          if (mounted) setState(() => _popupBgIconReady = false);
        }
      }
    } else {
      print("[DEBUG] popup_bg_icon already ready.");
    }
    print(
      "[DEBUG] _ensureStyleImagesLoaded finished. _markerIconReady: $_markerIconReady, _popupBgIconReady: $_popupBgIconReady",
    );
  }

  @override
  void dispose() {
    if (controller != null) {
      if (_onAnnotationClickHandler != null) {
        controller!.removeOnAnnotationClickListener(_onAnnotationClickHandler!);
      }
      if (_onAnnotationDragHandler != null) {
        controller!.removeOnAnnotationDragListener(_onAnnotationDragHandler!);
      }
      if (_onMapClickHandler != null) {
        controller!.removeOnMapClickListener(_onMapClickHandler!);
      }
    }
    super.dispose();
  }

  // Helper to get LatLng from stored annotation data
  LatLng? _getLatLngFromAnnotationData(Map<String, dynamic>? annotationData) {
    if (annotationData == null) return null;
    final geometry = annotationData['geometry'] as Map<String, dynamic>?;
    if (geometry != null && geometry['coordinates'] is List) {
      final coords = geometry['coordinates'] as List;
      if (coords.length >= 2 && coords[0] is double && coords[1] is double) {
        return LatLng(coords[1] as double, coords[0] as double);
      }
    }
    return null;
  }

  Future<void> _removeTextWindowAnnotation() async {
    if (_textWindowAnnotationId != null && controller != null && mounted) {
      await controller!.removeAnnotation<PointAnnotation>(
        _textWindowAnnotationId!,
      );
      if (mounted) {
        setState(() {
          _textWindowAnnotationId = null;
          _markerIdForTextWindow = null;
        });
      }
      print("Text window annotation removed.");
    }
  }

  Future<void> _addTextWindowAnnotation(
    int forMarkerId,
    LatLng position,
  ) async {
    if (!mounted || controller == null) return;

    if (!_popupBgIconReady) {
      print(
        "Popup background icon (asset) not ready. Will attempt to re-load.",
      );
      await _ensureStyleImagesLoaded();
      if (!mounted || !_popupBgIconReady) {
        print(
          "Still unable to load popup background (asset) after re-attempt. Aborting text window.",
        );
        if (mounted) {
          setState(() {
            _draggedAnnotationInfo =
                "Error: Popup image asset missing or invalid.";
          });
        }
        return;
      }
      print(
        "Popup background icon (asset) is NOW ready. Proceeding to add text window.",
      );
    }

    await _removeTextWindowAnnotation();

    final String textContent =
        "Lat: ${position.latitude.toStringAsFixed(4)}\nLng: ${position.longitude.toStringAsFixed(4)}";

    final textWindowOptions = PointAnnotationOptions(
      point: position,
      iconSize: 0.1,
      iconAnchor: "bottom",
      iconOffset: [0.0, -20.0],
      textField: textContent,
      textSize: 10.0,
      textColor: "#FFFFFF", // Changed to white
      textAnchor: "center", // Anchor text in the center of its background image
      draggable: false,
    );

    final PointAnnotation textWindowAnnotation = PointAnnotation(
      image: LocalStyleImage(
        imageId: 'popup_bg_icon',
        imageName: _popupBgAssetPath,
      ),
      options: textWindowOptions,
    );

    try {
      // Before adding annotation, one last check for the image
      bool? bgImageReallyExists = await controller?.isStyleImageExist(
        'popup_bg_icon',
      );
      if (bgImageReallyExists != true) {
        print(
          "Critical Error: 'popup_bg_icon' (asset) does not exist in style just before adding annotation. Aborting.",
        );
        if (mounted) {
          setState(() {
            _draggedAnnotationInfo =
                "Critical Error: Popup image asset missing.";
          });
        }
        return;
      }

      final result = await controller!.addAnnotation<PointAnnotation>(
        annotation: textWindowAnnotation,
      );
      if (result != null && result['id'] is int) {
        if (mounted) {
          setState(() {
            _textWindowAnnotationId = result['id'] as int?;
            _markerIdForTextWindow = forMarkerId;
            _draggedAnnotationInfo = "Showing info for marker $forMarkerId";
          });
          print(
            "Text window added with ID: ${_textWindowAnnotationId} for marker $forMarkerId",
          );
        }
      } else {
        print("Failed to add text window annotation, result: $result");
        if (mounted) {
          setState(() {
            _draggedAnnotationInfo = "Error: Could not display info.";
          });
        }
      }
    } catch (e) {
      print("Error adding text window annotation: $e");
      if (mounted) {
        setState(() {
          _draggedAnnotationInfo = "Error: Could not display info ($e).";
        });
      }
    }
  }

  void _setupAnnotationListeners() {
    if (!mounted || controller == null) {
      print("Controller not ready for annotation listeners.");
      return;
    }

    _onAnnotationClickHandler = (
      Map<String, Object?> annotationDataFromEvent,
    ) async {
      if (!mounted || controller == null) return;
      final dynamic tappedAnnotationId = annotationDataFromEvent['id'];

      if (tappedAnnotationId is! int) return;
      // Prevent clicking on the text window itself from doing anything or trying to re-add itself
      if (tappedAnnotationId == _textWindowAnnotationId) return;

      final annotationData = _annotations[tappedAnnotationId];
      final LatLng? position = _getLatLngFromAnnotationData(annotationData);

      if (position != null) {
        if (_markerIdForTextWindow == tappedAnnotationId &&
            _textWindowAnnotationId != null) {
          // Tapped same marker again, remove its text window
          await _removeTextWindowAnnotation();
          if (mounted)
            setState(
              () =>
                  _draggedAnnotationInfo =
                      "Info hidden for $tappedAnnotationId",
            );
        } else {
          // Tapped a new marker (or a marker whose window was previously closed)
          await _addTextWindowAnnotation(tappedAnnotationId, position);
        }
      } else {
        print("Could not get position for tapped marker $tappedAnnotationId");
        await _removeTextWindowAnnotation(); // Ensure any old window is gone
      }
    };
    controller!.addOnAnnotationClickListener(_onAnnotationClickHandler!);

    _onMapClickHandler = (LatLng latLng) async {
      if (!mounted) return;
      await _removeTextWindowAnnotation();
      if (mounted)
        setState(
          () => _draggedAnnotationInfo = "Map tapped. Info window closed.",
        );
    };
    controller!.addOnMapClickListener(_onMapClickHandler!);

    _onAnnotationDragHandler = (
      int id,
      String type,
      Map<String, Object?> geometry,
      Map<String, Object?> updatedGeometry,
      AnnotationDragEvent event,
    ) {
      if (!mounted || controller == null) return;

      // If the dragged annotation is the one for which a text window is shown, remove the window
      if (id == _markerIdForTextWindow && _textWindowAnnotationId != null) {
        _removeTextWindowAnnotation();
      }

      final newCoordsList = updatedGeometry['coordinates'] as List<dynamic>?;
      if (newCoordsList == null ||
          newCoordsList.length < 2 ||
          !(newCoordsList[0] is double && newCoordsList[1] is double)) {
        return;
      }
      final double newLng = newCoordsList[0] as double;
      final double newLat = newCoordsList[1] as double;
      String currentDragInfo =
          "Drag: ID $id ${event.name} [${newLng.toStringAsFixed(2)}, ${newLat.toStringAsFixed(2)}]";

      if (event == AnnotationDragEvent.start) {
        if (mounted) setState(() => _draggedAnnotationId = id);
        controller?.setAllGesturesEnabled(false);
      } else if (event == AnnotationDragEvent.end) {
        if (mounted) setState(() => _draggedAnnotationId = null);
        controller?.setAllGesturesEnabled(true);
        if (_annotations.containsKey(id)) {
          if (mounted) {
            setState(() {
              _annotations[id]?['geometry'] = updatedGeometry;
            });
          }
        }
        currentDragInfo += " (Done)";
        // Option: Re-show text window if it was for this marker and drag ended?
        // For now, drag clears it and user must tap again.
      }
      if (mounted) setState(() => _draggedAnnotationInfo = currentDragInfo);
    };
    controller!.addOnAnnotationDragListener(_onAnnotationDragHandler!);

    // Remove _onAnnotationLongClickHandler or adapt if needed
    // Remove _onCameraMoveHandler and _updateSpecificPopupPosition

    print("Annotation and map listeners setup successfully.");
  }

  @override
  Future<void> onMapCreated(NaxaLibreController controller) async {
    super.onMapCreated(controller);
    this.controller = controller;
    if (mounted) {
      await _ensureStyleImagesLoaded();
      _setupAnnotationListeners();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _draggedAnnotationInfo =
                _annotations.isEmpty
                    ? "Tap 'Add Marker' to start."
                    : "Markers present. Tap one or add more.";
            if (!_markerIconReady || !_popupBgIconReady) {
              _draggedAnnotationInfo +=
                  "\nWarning: Some map icons might be missing.";
              if (!_markerIconReady) _draggedAnnotationInfo += " (Marker icon)";
              if (!_popupBgIconReady)
                _draggedAnnotationInfo += " (Popup background)";
            }
          });
        }
      });
    }
  }

  Future<void> _toggleMarkerAction() async {
    if (_annotations.isNotEmpty) {
      await _removeTextWindowAnnotation(); // Clear any open text window
      List<int> idsToRemove = List<int>.from(_annotations.keys);
      for (var id in idsToRemove) {
        await controller?.removeAnnotation<PointAnnotation>(id);
      }
      if (mounted) {
        setState(() {
          _annotations.clear();
          _draggedAnnotationInfo =
              "All annotations removed. Tap 'Add Marker' to start.";
        });
      }
    } else {
      await _addDraggableMarker();
    }
  }

  Future<void> _addDraggableMarker() async {
    if (controller == null || !mounted) {
      if (mounted) {
        setState(() {
          _draggedAnnotationInfo = "Map Controller not ready to add marker.";
        });
      }
      return;
    }

    if (!_markerIconReady) {
      print("Marker icon 'test_icon' not ready. Will attempt to re-load.");
      await _ensureStyleImagesLoaded();
      if (!mounted || !_markerIconReady) {
        print(
          "Still unable to load 'test_icon' after re-attempt. Aborting add marker.",
        );
        if (mounted) {
          setState(() {
            _draggedAnnotationInfo = "Error: Marker icon missing.";
          });
        }
        return;
      }
      print("Marker icon 'test_icon' is NOW ready. Proceeding to add marker.");
    }

    final CameraPosition? cameraPos = await controller?.getCameraPosition();
    LatLng targetPosition = cameraPos?.target ?? LatLng(27.7172, 85.3240);

    // Main marker annotation options (no text field here)
    final pointAnnotationOptions = PointAnnotationOptions(
      point: targetPosition,
      draggable: true,
      iconSize: 0.1,
      // iconImage: 'test_icon' // Set via PointAnnotation's image property for clarity
    );

    // Before adding annotation, one last check for the image
    bool? markerImageReallyExists = await controller?.isStyleImageExist(
      'test_icon',
    );
    if (markerImageReallyExists != true) {
      print(
        "Critical Error: 'test_icon' does not exist in style just before adding annotation. Aborting.",
      );
      if (mounted) {
        setState(() {
          _draggedAnnotationInfo = "Critical Error: Marker image missing.";
        });
      }
      return;
    }

    final pointAnnotation = PointAnnotation(
      image: NetworkStyleImage(
        imageId: 'test_icon',
        url: '',
      ), // URL not used if imageId 'test_icon' already on style
      options: pointAnnotationOptions,
    );

    try {
      final Map<String, Object?>? addedAnnotationResponse = await controller
          ?.addAnnotation<PointAnnotation>(annotation: pointAnnotation);

      if (addedAnnotationResponse != null &&
          addedAnnotationResponse.containsKey('id') &&
          addedAnnotationResponse['id'] is int) {
        final int nativeId = addedAnnotationResponse['id'] as int;

        final Map<String, dynamic> geometry = {
          'type': 'Point',
          'coordinates': [targetPosition.longitude, targetPosition.latitude],
        };

        _annotations[nativeId] = {
          'id': nativeId,
          'type': pointAnnotation.type,
          'options': pointAnnotationOptions.toArgs(),
          'geometry': geometry,
        };

        if (!mounted) return;
        setState(() {
          _draggedAnnotationInfo =
              "Added marker: ID $nativeId at [${targetPosition.longitude.toStringAsFixed(3)}, ${targetPosition.latitude.toStringAsFixed(3)}]";
        });
      } else {
        if (!mounted) return;
        setState(() {
          _draggedAnnotationInfo =
              "Failed to add marker. Response: $addedAnnotationResponse";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _draggedAnnotationInfo = "Error adding marker: $e";
      });
      print("Error adding annotation: $e");
    }
  }

  @override
  Widget buildMapWithControls() {
    return Stack(
      children: [
        buildBaseMap(),
        // The _draggedAnnotationInfo display remains for general feedback
        if (_draggedAnnotationInfo.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Material(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _draggedAnnotationInfo,
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

        Positioned(
          bottom: 30,
          right: 20,
          child: FloatingActionButton.extended(
            onPressed: _toggleMarkerAction,
            label: Text(
              _annotations.isNotEmpty ? 'Clear Markers' : 'Add Marker',
            ),
            icon: Icon(
              _annotations.isNotEmpty
                  ? Icons.delete_sweep_outlined
                  : Icons.add_location_outlined,
            ),
            backgroundColor:
                _annotations.isNotEmpty
                    ? Colors.redAccent
                    : Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
