import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef JumbleFlightShuttleBuilder = Widget Function(
  BuildContext flightContext,
  Animation<double> animation,
  JumbleFlightDirection flightDirection,
  BuildContext fromJumbleContext,
  BuildContext toJumbleContext,
);

typedef JumbleAnimationBuilder = Animation<double> Function(
  Animation<double> animation,
);

typedef _OnFlightEnded = void Function(_JumbleFlight flight);

Animation<double> _sameAnimation(Animation<double> animation) => animation;

enum JumbleFlightDirection {
  toTarget,
  toSource,
}

Rect _globalBoundingBoxFor(BuildContext context) {
  final RenderBox box = context.findRenderObject();
  assert(box != null && box.hasSize);
  return MatrixUtils.transformRect(
      box.getTransformTo(null), Offset.zero & box.size);
}

class Jumble extends StatefulWidget {
  const Jumble({
    Key key,
    @required this.tag,
    this.targetTag,
    this.createRectTween,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    JumbleAnimationBuilder animationBuilder,
    @required this.child,
  })  : assert(tag != null),
        assert(child != null),
        animationBuilder = animationBuilder ?? _sameAnimation,
        super(key: key);
  final Object tag;
  final Object targetTag;
  final CreateRectTween createRectTween;
  final Widget child;
  final JumbleFlightShuttleBuilder flightShuttleBuilder;
  final TransitionBuilder placeholderBuilder;
  final JumbleAnimationBuilder animationBuilder;
  static Map<Object, _JumbleState> _allJumblesFor(BuildContext context) {
    assert(context != null);
    final Map<Object, _JumbleState> result = <Object, _JumbleState>{};
    void visitor(Element element) {
      if (element.widget is Jumble) {
        final StatefulElement jumbleWidget = element;
        final Jumble jumble = element.widget;
        final Object tag = jumble.tag;
        assert(tag != null);
        assert(() {
          if (result.containsKey(tag)) {
            throw FlutterError(
                'There are multiple Jumbles that share the same tag within a subtree.\n'
                'Within each subtree for which Jumbles are to be animated, '
                'each Jumble must have a unique non-null tag.\n'
                'In this case, multiple Jumbles had the following tag: $tag\n'
                'Here is the subtree for one of the offending Jumbles:\n'
                '${element.toStringDeep(prefixLineOne: "# ")}');
          }
          return true;
        }());
        final _JumbleState jumbleState = jumbleWidget.state;
        result[tag] = jumbleState;
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return result;
  }

  @override
  _JumbleState createState() => _JumbleState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('tag', tag));
  }
}

class _JumbleState extends State<Jumble> with TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  Size _placeholderSize;

  void startFlight() {
    assert(mounted);
    final RenderBox box = context.findRenderObject();
    assert(box != null && box.hasSize);
    setState(() {
      _placeholderSize = box.size;
    });
  }

  void endFlight() {
    if (mounted) {
      setState(() {
        _placeholderSize = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_placeholderSize != null) {
      if (widget.placeholderBuilder == null) {
        return SizedBox(
          width: _placeholderSize.width,
          height: _placeholderSize.height,
        );
      } else {
        return widget.placeholderBuilder(context, widget.child);
      }
    }
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

class _JumbleFlightManifest {
  _JumbleFlightManifest({
    @required this.type,
    @required this.overlay,
    @required this.rect,
    @required this.fromJumble,
    @required this.toJumble,
    @required this.createRectTween,
    @required this.shuttleBuilder,
    @required this.animationController,
  }) : assert((type == JumbleFlightDirection.toTarget &&
                fromJumble.widget.targetTag == toJumble.widget.tag) ||
            (type == JumbleFlightDirection.toSource &&
                toJumble.widget.targetTag == fromJumble.widget.tag));

  final JumbleFlightDirection type;
  final OverlayState overlay;
  final Rect rect;
  final _JumbleState fromJumble;
  final _JumbleState toJumble;
  final CreateRectTween createRectTween;
  final JumbleFlightShuttleBuilder shuttleBuilder;
  final Animation<double> animationController;

  Object get tag => fromJumble.widget.tag;

  Object get targetTag => toJumble.widget.tag;

  Animation<double> get animation {
    return fromJumble.widget.animationBuilder(animationController);
  }

  @override
  String toString() {
    return '_JumbleFlightManifest($type from $tag to $targetTag';
  }
}

class _JumbleFlight {
  _JumbleFlight(this.onFlightEnded) {
    _proxyAnimation = ProxyAnimation()
      ..addStatusListener(_handleAnimationUpdate);
  }

  final _OnFlightEnded onFlightEnded;

  Tween<Rect> jumbleRectTween;
  Widget shuttle;

  Animation<double> _jumbleOpacity = kAlwaysCompleteAnimation;
  ProxyAnimation _proxyAnimation;
  _JumbleFlightManifest manifest;
  OverlayEntry overlayEntry;
  bool _aborted = false;

  Tween<Rect> _doCreateRectTween(Rect begin, Rect end) {
    final CreateRectTween createRectTween =
        manifest.toJumble.widget.createRectTween ?? manifest.createRectTween;
    if (createRectTween != null) return createRectTween(begin, end);
    return RectTween(begin: begin, end: end);
  }

  static final Animatable<double> _reverseTween =
      Tween<double>(begin: 1.0, end: 0.0);

  Widget _buildOverlay(BuildContext context) {
    assert(manifest != null);
    shuttle ??= manifest.shuttleBuilder(
      context,
      manifest.animation,
      manifest.type,
      manifest.fromJumble.context,
      manifest.toJumble.context,
    );
    assert(shuttle != null);

    return AnimatedBuilder(
      animation: _proxyAnimation,
      child: shuttle,
      builder: (BuildContext context, Widget child) {
        final RenderBox toJumbleBox =
            manifest.toJumble.context?.findRenderObject();
        if (_aborted || toJumbleBox == null || !toJumbleBox.attached) {
          if (_jumbleOpacity.isCompleted) {
            _jumbleOpacity = _proxyAnimation.drive(
              _reverseTween.chain(CurveTween(
                  curve: Interval(_proxyAnimation.value.clamp(0.0, 1.0), 1.0))),
            );
          }
        } else if (toJumbleBox.hasSize) {
          final Offset toJumbleOrigin = toJumbleBox.localToGlobal(Offset.zero);
          if (toJumbleOrigin != jumbleRectTween.end.topLeft) {
            final Rect jumbleRectEnd =
                toJumbleOrigin & jumbleRectTween.end.size;
            jumbleRectTween =
                _doCreateRectTween(jumbleRectTween.begin, jumbleRectEnd);
          }
        }

        final Rect rect = jumbleRectTween.evaluate(_proxyAnimation);
        final Size size = manifest.rect.size;
        final RelativeRect offsets = RelativeRect.fromSize(rect, size);

        return Positioned(
          left: offsets.left,
          top: offsets.top,
          width: rect.width,
          height: rect.height,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: Opacity(
                opacity: _jumbleOpacity.value,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleAnimationUpdate(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _proxyAnimation.parent = null;

      assert(overlayEntry != null);
      overlayEntry.remove();
      overlayEntry = null;

      manifest.toJumble.endFlight();
      onFlightEnded(this);
    }
  }

  void start(_JumbleFlightManifest initialManifest) {
    assert(!_aborted);
    manifest = initialManifest;

    if (manifest.type == JumbleFlightDirection.toSource)
      _proxyAnimation.parent = ReverseAnimation(manifest.animation);
    else
      _proxyAnimation.parent = manifest.animation;

    manifest.fromJumble.startFlight();
    manifest.toJumble.startFlight();

    jumbleRectTween = _doCreateRectTween(
      _globalBoundingBoxFor(manifest.fromJumble.context),
      _globalBoundingBoxFor(manifest.toJumble.context),
    );

    overlayEntry = OverlayEntry(builder: _buildOverlay);
    manifest.overlay.insert(overlayEntry);
  }

  void divert(_JumbleFlightManifest newManifest) {
    assert(manifest.tag == newManifest.tag);

    if (manifest.type == JumbleFlightDirection.toTarget &&
        newManifest.type == JumbleFlightDirection.toSource) {
      assert(newManifest.animation.status == AnimationStatus.reverse);
      assert(manifest.fromJumble == newManifest.toJumble);
      assert(manifest.toJumble == newManifest.fromJumble);
      _proxyAnimation.parent = ReverseAnimation(newManifest.animation);
      jumbleRectTween = ReverseTween<Rect>(jumbleRectTween);
    } else if (manifest.type == JumbleFlightDirection.toSource &&
        newManifest.type == JumbleFlightDirection.toTarget) {
      assert(newManifest.animation.status == AnimationStatus.forward);
      assert(manifest.toJumble == newManifest.fromJumble);

      _proxyAnimation.parent = newManifest.animation.drive(
        Tween<double>(
          begin: manifest.animation.value,
          end: 1.0,
        ),
      );

      if (manifest.fromJumble != newManifest.toJumble) {
        manifest.fromJumble.endFlight();
        newManifest.toJumble.startFlight();
        jumbleRectTween = _doCreateRectTween(jumbleRectTween.end,
            _globalBoundingBoxFor(newManifest.toJumble.context));
      } else {
        jumbleRectTween =
            _doCreateRectTween(jumbleRectTween.end, jumbleRectTween.begin);
      }
    } else {
      assert(manifest.fromJumble != newManifest.fromJumble);
      assert(manifest.toJumble != newManifest.toJumble);

      jumbleRectTween = _doCreateRectTween(
          jumbleRectTween.evaluate(_proxyAnimation),
          _globalBoundingBoxFor(newManifest.toJumble.context));
      shuttle = null;

      if (newManifest.type == JumbleFlightDirection.toSource)
        _proxyAnimation.parent = ReverseAnimation(newManifest.animation);
      else
        _proxyAnimation.parent = newManifest.animation;

      manifest.fromJumble.endFlight();
      manifest.toJumble.endFlight();
      newManifest.fromJumble.startFlight();
      newManifest.toJumble.startFlight();
      overlayEntry.markNeedsBuild();
    }

    _aborted = false;
    manifest = newManifest;
  }

  void abort() {
    _aborted = true;
  }

  @override
  String toString() {
    final Object tag = manifest.tag;
    final Object targetTag = manifest.targetTag;
    return 'JumbleFlight(from: $tag, to: $targetTag, ${_proxyAnimation.parent})';
  }
}

class JumbleController extends Animation<double> {
  JumbleController({
    this.createRectTween,
    Duration duration = const Duration(milliseconds: 300),
    @required TickerProvider vsync,
  })  : assert(vsync != null),
        assert(duration != null),
        _controller = AnimationController(
          vsync: vsync,
          duration: duration,
        );
  final CreateRectTween createRectTween;

  final AnimationController _controller;

  @override
  void addListener(VoidCallback listener) {
    _controller.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _controller.removeListener(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    _controller.addStatusListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    _controller.removeStatusListener(listener);
  }

  AnimationStatus get status => _controller.status;
  @override
  double get value => _controller.value;

  @mustCallSuper
  void dispose() {
    _controller?.dispose();
  }

  final Map<Object, _JumbleFlight> _flights = <Object, _JumbleFlight>{};
  TickerFuture move(
    BuildContext context,
    JumbleFlightDirection direction, {
    List<Object> tags,
  }) {
    assert(direction != null);
    if (direction == JumbleFlightDirection.toTarget) {
      return moveToTarget(context, tags: tags);
    } else {
      return moveToSource(context, tags: tags);
    }
  }

  TickerFuture moveToTarget(
    BuildContext context, {
    List<Object> tags,
  }) {
    _controller.reset();
    if (status == AnimationStatus.forward ||
        status == AnimationStatus.completed) {
      return TickerFuture.complete();
    }

    WidgetsBinding.instance.addPostFrameCallback((Duration value) {
      _startJumbleTransition(context, JumbleFlightDirection.toTarget, tags);
    });
    return _controller.forward();
  }

  TickerFuture moveToSource(
    BuildContext context, {
    List<Object> tags,
  }) {
    _controller.value = 1.0;
    if (status == AnimationStatus.reverse ||
        status == AnimationStatus.dismissed) {
      return TickerFuture.complete();
    }

    WidgetsBinding.instance.addPostFrameCallback((Duration value) {
      _startJumbleTransition(context, JumbleFlightDirection.toSource, tags);
    });
    return _controller.reverse();
  }

  void _startJumbleTransition(
    BuildContext context,
    JumbleFlightDirection flightType,
    List<Object> tags,
  ) {
    final Rect rect = _globalBoundingBoxFor(context);

    final Map<Object, _JumbleState> jumbles = Jumble._allJumblesFor(context);

    for (Object tag in tags ?? jumbles.keys) {
      final _JumbleState jumble = jumbles[tag];
      if (Jumble != null) {
        Object targetTag = jumble.widget.targetTag;
        if (flightType == JumbleFlightDirection.toSource) {
          final Object tempTag = tag;
          tag = targetTag;
          targetTag = tempTag;
        }

        if (jumbles[tag] != null) {
          final Jumble fromJumble = jumbles[tag].widget;
          final Jumble toJumble = jumbles[targetTag]?.widget;

          if (toJumble != null) {
            final JumbleFlightShuttleBuilder fromShuttleBuilder =
                fromJumble.flightShuttleBuilder;
            final JumbleFlightShuttleBuilder toShuttleBuilder =
                toJumble.flightShuttleBuilder;

            final _JumbleFlightManifest manifest = _JumbleFlightManifest(
              type: flightType,
              overlay: Overlay.of(context),
              rect: rect,
              fromJumble: jumbles[tag],
              toJumble: jumbles[targetTag],
              createRectTween: createRectTween,
              shuttleBuilder: toShuttleBuilder ??
                  fromShuttleBuilder ??
                  _defaultJumbleFlightShuttleBuilder,
              animationController: _controller.view,
            );

            if (_flights[tag] != null) {
              _flights[tag].divert(manifest);
            } else {
              _flights[tag] = _JumbleFlight(_handleFlightEnded)
                ..start(manifest);
            }
          } else if (_flights[tag] != null) {
            _flights[tag].abort();
          }
        }
      }
    }
  }

  void _handleFlightEnded(_JumbleFlight flight) {
    _flights.remove(flight.manifest.tag);
  }

  static final JumbleFlightShuttleBuilder _defaultJumbleFlightShuttleBuilder = (
    BuildContext flightContext,
    Animation<double> animation,
    JumbleFlightDirection flightDirection,
    BuildContext fromJumbleContext,
    BuildContext toJumbleContext,
  ) {
    final Jumble toJumble = toJumbleContext.widget;
    return toJumble.child;
  };
}
