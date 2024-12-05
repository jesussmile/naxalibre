import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naxalibre/naxalibre.dart';
import 'package:naxalibre/naxalibre_platform_interface.dart';
import 'package:naxalibre/naxalibre_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNaxaLibrePlatform
    with MockPlatformInterfaceMixin
    implements NaxaLibrePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Widget buildMapView({
    required Map<String, dynamic> creationParams,
    void Function(int id)? onPlatformViewCreated,
    bool hyperComposition = false,
  }) {
    // TODO: implement buildMapView
    throw UnimplementedError();
  }
}

void main() {
  final NaxaLibrePlatform initialPlatform = NaxaLibrePlatform.instance;

  test('$MethodChannelNaxaLibre is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNaxaLibre>());
  });

  test('getPlatformVersion', () async {
    NaxaLibre naxalibrePlugin = NaxaLibre();
    MockNaxaLibrePlatform fakePlatform = MockNaxaLibrePlatform();
    NaxaLibrePlatform.instance = fakePlatform;

    expect(await naxalibrePlugin.getPlatformVersion(), '42');
  });
}
