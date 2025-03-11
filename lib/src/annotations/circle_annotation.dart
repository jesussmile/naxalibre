part of 'annotation.dart';

/// The `CircleAnnotation` class represents a circular annotation
/// that can be added to the map for visualization purposes.
///
/// This class extends the `Annotation` class and uses
/// `CircleAnnotationOptions` to define the properties of the circular annotation,
/// such as its position, color, radius, and other customizable features.
///
class CircleAnnotation extends Annotation<CircleAnnotationOptions> {
  /// Type of the annotation
  ///
  @override
  String get type => "Circle";

  /// Constructs a `CircleAnnotation` instance.
  ///
  /// [options] is required and contains the properties that define
  /// the circle's visual appearance and behavior, such as its center point and style options.
  CircleAnnotation({required super.options});

  /// Converts the `CircleAnnotation` object into a map representation.
  ///
  /// This method formats the annotation data into a structure suitable
  /// for passing to the native platform through the `args` parameter.
  ///
  /// Returns:
  /// - A json map containing the annotation options.
  /// and annotation type
  @override
  Map<String, dynamic> toArgs() {
    return <String, dynamic>{"type": type, "options": options.toArgs()};
  }
}

/// CircleAnnotationOptions class
/// It contains all the properties for the circle annotation
/// e.g.
/// final circleAnnotationOptions = CircleAnnotationOptions(
///               point: LatLng(27.34, 85.43),
///               circleColor: 'green',
///               circleRadius: 10.0,
///               circleStrokeWidth: 2.0,
///               circleStrokeColor: "#fff",
///  );
class CircleAnnotationOptions extends AnnotationOptions {
  /// Set the Point of the circleAnnotation, which represents the location
  /// of the circleAnnotation on the map
  /// Accepted data type:
  /// - LatLng
  final LatLng point;

  /// The fill color of the circle.
  /// Accepted data type:
  /// - String,
  /// - Int and
  /// - Expression
  /// default value is '#0000'
  final dynamic circleColor;

  /// StyleTransition for circleColor
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? circleColorTransition;

  /// Circle radius.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  /// default value is 5.0
  final dynamic circleRadius;

  /// StyleTransition for circleRadius
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? circleRadiusTransition;

  /// Amount to blur the circle. 1 blurs the circle such that only the
  /// center point is full opacity.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  /// default value is 0.0
  final dynamic circleBlur;

  /// StyleTransition for circleBlur
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? circleBlurTransition;

  /// The opacity at which the circle will be drawn.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  /// default value is 1.0
  final dynamic circleOpacity;

  /// StyleTransition for circleOpacity
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? circleOpacityTransition;

  /// The stroke color of the circle.
  /// Accepted data type:
  /// - String
  /// - Int and
  /// - Expression
  /// default value is '#000'
  final dynamic circleStrokeColor;

  /// StyleTransition for circleStrokeColor
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? circleStrokeColorTransition;

  /// The width of the circle's stroke. Strokes are placed outside
  /// of the circle-radius.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  /// default value is 0.0
  final dynamic circleStrokeWidth;

  /// StyleTransition for circleStrokeWidth
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? circleStrokeWidthTransition;

  /// The opacity of the circle's stroke
  /// Accepted data type:
  /// - Double and
  /// - Expression
  /// default value is 1.0
  final dynamic circleStrokeOpacity;

  /// StyleTransition for circleStrokeOpacity
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? circleStrokeOpacityTransition;

  /// Sorts features in ascending order based on this value.
  /// Features with a higher sort key will appear above features
  /// with a lower sort key.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  final dynamic circleSortKey;

  /// Set whether this circleAnnotation should be draggable, meaning it can be
  /// dragged across the screen when touched and moved.
  /// Accepted data type - bool
  /// default value is false
  final bool draggable;

  /// Set the arbitrary json data of the annotation.
  /// Accepted data type - map of string, dynamic
  /// default value is null
  final Map<String, dynamic>? data;

  /// Constructor
  CircleAnnotationOptions({
    required this.point,
    this.circleColor,
    this.circleColorTransition,
    this.circleRadius,
    this.circleRadiusTransition,
    this.circleBlur,
    this.circleBlurTransition,
    this.circleOpacity,
    this.circleOpacityTransition,
    this.circleStrokeColor,
    this.circleStrokeColorTransition,
    this.circleStrokeWidth,
    this.circleStrokeWidthTransition,
    this.circleStrokeOpacity,
    this.circleStrokeOpacityTransition,
    this.circleSortKey,
    this.draggable = false,
    this.data,
  });

  /// Method to proceeds the circle annotation options
  ///
  @override
  Map<String, dynamic>? toArgs() {
    final args = <String, dynamic>{};

    // Adding point
    args['point'] = point.toArgs();

    // Adding draggable
    args['draggable'] = draggable;

    // Adding data
    if (data != null) {
      args['data'] = data;
    }

    // Layout properties
    final layoutArgs = _circleLayoutArgs();
    args['layout'] = layoutArgs;

    // Paint properties
    final paintArgs = _circlePaintArgs();
    args['paint'] = paintArgs;

    // Transition properties
    final transitionsArgs = _circleTransitionsArgs();
    args['transition'] = transitionsArgs;

    return args.isNotEmpty ? args : null;
  }

  /// Method to create layout properties
  ///
  Map<String, dynamic> _circleLayoutArgs() {
    final layoutArgs = <String, dynamic>{};

    void insert(String key, dynamic value) {
      if (value != null) {
        layoutArgs[key] = value is List ? jsonEncode(value) : value;
      }
    }

    insert('circle-sort-key', circleSortKey);

    return layoutArgs;
  }

  /// Method to create paint properties
  ///
  Map<String, dynamic> _circlePaintArgs() {
    final paintArgs = <String, dynamic>{};

    void insert(String key, dynamic value) {
      if (value != null) {
        paintArgs[key] = value is List ? jsonEncode(value) : value;
      }
    }

    insert('circle-color', circleColor);
    insert('circle-radius', circleRadius);
    insert('circle-blur', circleBlur);
    insert('circle-opacity', circleOpacity);
    insert('circle-stroke-color', circleStrokeColor);
    insert('circle-stroke-width', circleStrokeWidth);
    insert('circle-stroke-opacity', circleStrokeOpacity);

    return paintArgs;
  }

  /// Method to create transitions properties
  ///
  Map<String, dynamic> _circleTransitionsArgs() {
    final transitionsArgs = <String, dynamic>{};

    void insert(String key, dynamic transition) {
      if (transition != null) {
        transitionsArgs[key] = transition.toArgs();
      }
    }

    insert('circle-color-transition', circleColorTransition);
    insert('circle-radius-transition', circleRadiusTransition);
    insert('circle-blur-transition', circleBlurTransition);
    insert('circle-opacity-transition', circleOpacityTransition);
    insert('circle-stroke-color-transition', circleStrokeColorTransition);
    insert('circle-stroke-width-transition', circleStrokeWidthTransition);
    insert('circle-stroke-opacity-transition', circleStrokeOpacityTransition);

    return transitionsArgs;
  }
}
