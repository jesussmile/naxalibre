import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'enums/enums.dart';
import 'naxalibre_platform_interface.dart';

/// An implementation of [NaxaLibrePlatform] that uses method channels.
class MethodChannelNaxaLibre extends NaxaLibrePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('naxalibre');

  static const _viewType = "naxalibre/mapview";

  @override
  Widget buildMapView({
    required Map<String, dynamic> creationParams,
    void Function(int id)? onPlatformViewCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    HyperCompositionMode hyperCompositionMode = HyperCompositionMode.disabled,
  }) {
    // If platform is neither Android nor iOS, return a message.
    if (!Platform.isAndroid && !Platform.isIOS) {
      return Center(
        child: const Text('NaxaLibre only support android and iOS.'),
      );
    }

    // If platform is iOS then return UiKitView
    if (Platform.isIOS) {
      return UiKitView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: gestureRecognizers,
      );
    }

    // If platform is android
    // And hyper-composition is disabled
    if (hyperCompositionMode == HyperCompositionMode.disabled) {
      return AndroidView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: gestureRecognizers,
      );
    }

    // If hyper-composition is not disabled
    return PlatformViewLink(
      viewType: _viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers:
              gestureRecognizers ??
              const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return switch (hyperCompositionMode) {
            HyperCompositionMode.surfaceView =>
              PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: params.viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () => params.onFocusChanged(true),
              ),
            HyperCompositionMode.expensiveView =>
              PlatformViewsService.initExpensiveAndroidView(
                id: params.id,
                viewType: params.viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () => params.onFocusChanged(true),
              ),
            _ => PlatformViewsService.initAndroidView(
              id: params.id,
              viewType: params.viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            ),
          }
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}
