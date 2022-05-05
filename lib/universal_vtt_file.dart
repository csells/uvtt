// from: quicktype.io
// To parse this JSON data, do
//
//     final universalVttFile = UniversalVttFile.fromRawJson(jsonString);

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

class UniversalVttFile {
  UniversalVttFile({
    required this.filename,
    required this.parsedImage,
    required this.format,
    required this.resolution,
    required this.lineOfSight,
    required this.portals,
    required this.lights,
    required this.environment,
    required this.image,
    required this.software,
    required this.creator,
  });

  final String filename;
  final double format;
  final Resolution resolution;
  final List<List<MapOrigin>> lineOfSight;
  final List<Portal> portals;
  final List<Light> lights;
  final Environment environment;
  final String image;
  final String software;
  final String creator;
  final ui.Image? parsedImage;

  static Future<UniversalVttFile> fromRawJsonFile({
    required String filename,
    required String rawJson,
  }) async {
    final map = json.decode(rawJson);
    final base64image = map['image'] as String? ?? '';
    final parsedImageBytes =
        base64image.isNotEmpty ? base64Decode(base64image) : null;
    final parsedImage = parsedImageBytes == null
        ? null
        : await _imageFromBytes(parsedImageBytes);

    return UniversalVttFile.fromJson(
      map,
      filename: filename,
      parsedImage: parsedImage,
    );
  }

  String toRawJson() => json.encode(toJson());

  factory UniversalVttFile.fromJson(
    Map<String, dynamic> json, {
    String filename = '',
    ui.Image? parsedImage,
  }) =>
      UniversalVttFile(
        filename: filename,
        parsedImage: parsedImage,
        format: json['format'].toDouble(),
        resolution: Resolution.fromJson(json['resolution']),
        lineOfSight: List<List<MapOrigin>>.from(json['line_of_sight'].map(
            (x) => List<MapOrigin>.from(x.map((x) => MapOrigin.fromJson(x))))),
        portals:
            List<Portal>.from(json['portals'].map((x) => Portal.fromJson(x))),
        lights: List<Light>.from(json['lights'].map((x) => Light.fromJson(x))),
        environment: Environment.fromJson(json['environment']),
        image: json['image'],
        software: json['software'] ?? "",
        creator: json['creator'] ?? "",
      );

  Map<String, dynamic> toJson() => {
        'format': format,
        'software': software,
        'creator': creator,
        'resolution': resolution.toJson(),
        'line_of_sight': List<dynamic>.from(lineOfSight
            .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        'portals': List<dynamic>.from(portals.map((x) => x.toJson())),
        'lights': List<dynamic>.from(lights.map((x) => x.toJson())),
        'environment': environment.toJson(),
        'image': image,
      };

  static Future<ui.Image> _imageFromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

class Environment {
  Environment({
    required this.bakedLighting,
    required this.ambientLight,
  });

  final bool bakedLighting;
  final String ambientLight;

  factory Environment.fromRawJson(String str) =>
      Environment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Environment.fromJson(Map<String, dynamic> json) => Environment(
        bakedLighting: json['baked_lighting'],
        ambientLight: json['ambient_light'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'baked_lighting': bakedLighting,
        'ambient_light': ambientLight,
      };
}

class Light {
  Light({
    required this.position,
    required this.range,
    required this.intensity,
    required this.color,
    required this.shadows,
  });

  final MapOrigin position;
  final double range;
  final double intensity;
  final String color;
  final bool shadows;

  factory Light.fromRawJson(String str) => Light.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Light.fromJson(Map<String, dynamic> json) => Light(
        position: MapOrigin.fromJson(json['position']),
        range: json['range'].toDouble(),
        intensity: json['intensity'].toDouble(),
        color: json['color'] ?? '000000ff',
        shadows: json['shadows'],
      );

  Map<String, dynamic> toJson() => {
        'position': position.toJson(),
        'range': range,
        'intensity': intensity,
        'color': color,
        'shadows': shadows,
      };
}

class MapOrigin {
  MapOrigin({
    required this.x,
    required this.y,
  });

  final double x;
  final double y;

  factory MapOrigin.fromRawJson(String str) =>
      MapOrigin.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MapOrigin.fromJson(Map<String, dynamic> json) => MapOrigin(
        x: json['x'].toDouble(),
        y: json['y'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
}

class Portal {
  Portal({
    required this.position,
    required this.bounds,
    required this.rotation,
    required this.closed,
    required this.freestanding,
  });

  final MapOrigin position;
  final List<MapOrigin> bounds;
  final double rotation;
  final bool closed;
  final bool freestanding;

  factory Portal.fromRawJson(String str) => Portal.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Portal.fromJson(Map<String, dynamic> json) => Portal(
        position: MapOrigin.fromJson(json['position']),
        bounds: List<MapOrigin>.from(
            json['bounds'].map((x) => MapOrigin.fromJson(x))),
        rotation: json['rotation'],
        closed: json['closed'],
        freestanding: json['freestanding'],
      );

  Map<String, dynamic> toJson() => {
        'position': position.toJson(),
        'bounds': List<dynamic>.from(bounds.map((x) => x.toJson())),
        'rotation': rotation,
        'closed': closed,
        'freestanding': freestanding,
      };
}

class Resolution {
  Resolution({
    required this.mapOrigin,
    required this.mapSize,
    required this.pixelsPerGrid,
  });

  final MapOrigin mapOrigin;
  final MapOrigin mapSize;
  final int pixelsPerGrid;

  factory Resolution.fromRawJson(String str) =>
      Resolution.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Resolution.fromJson(Map<String, dynamic> json) => Resolution(
        mapOrigin: MapOrigin.fromJson(json['map_origin']),
        mapSize: MapOrigin.fromJson(json['map_size']),
        pixelsPerGrid: json['pixels_per_grid'],
      );

  Map<String, dynamic> toJson() => {
        'map_origin': mapOrigin.toJson(),
        'map_size': mapSize.toJson(),
        'pixels_per_grid': pixelsPerGrid,
      };
}
