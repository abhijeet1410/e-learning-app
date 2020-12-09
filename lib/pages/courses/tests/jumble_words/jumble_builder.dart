import 'package:flutter/widgets.dart';
import 'package:learning_app/pages/courses/tests/jumble_words/jumble_controller.dart';

typedef JumbleTeamWidgetBuilder<T> = Widget Function(
  BuildContext context,
  List<JumbleBuilderDelegate<Object>> sourceBuilderDelegates,
  List<JumbleBuilderDelegate<Object>> targetBuilderDelegates,
);

class _JumbleMission<T> {
  _JumbleMission(
    this.id,
    this.message,
    TickerProvider vsync,
    Duration duration,
  ) : controller = JumbleController(vsync: vsync, duration: duration);

  final String id;
  final dynamic message;
  final JumbleController controller;
  bool inFlightToTheSource = false;
  bool inFlightToTheTarget = false;
  bool get inFlight => inFlightToTheSource || inFlightToTheTarget;

  void startFlight(JumbleFlightDirection direction) =>
      _setInFlight(direction, true);
  void endFlight(JumbleFlightDirection direction) =>
      _setInFlight(direction, false);

  void _setInFlight(JumbleFlightDirection direction, bool inFlight) {
    if (direction == JumbleFlightDirection.toTarget) {
      inFlightToTheTarget = inFlight;
    } else {
      inFlightToTheSource = inFlight;
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
class JumbleBuilder<T> extends StatefulWidget {
  JumbleBuilder({
    Key key,
    @required this.builder,
    this.initialSourceList,
    this.initialTargetList,
    this.animationDuration = const Duration(milliseconds: 300),
  })  : assert(animationDuration != null),
        super(key: key);
  final JumbleTeamWidgetBuilder<Object> builder;

  final List<Object> initialSourceList;
  final List<Object> initialTargetList;
  final Duration animationDuration;
  static JumbleBuilderState<Object> of<T>(BuildContext context) {
    assert(context != null);
    final JumbleBuilderState<Object> result =
        context.findAncestorStateOfType() as JumbleBuilderState;
    return result;
  }

  @override
  JumbleBuilderState<Object> createState() => JumbleBuilderState<Object>();
}
class JumbleBuilderState<T> extends State<JumbleBuilder<T>>
    with TickerProviderStateMixin {
  static const String _sourceListPrefix = 's_';
  static const String _targetListPrefix = 't_';
  static int _nextId = 0;
  int _id;
  bool _allInFlight;
  JumbleController _jumbleController;
  List<_JumbleMission<Object>> _sourceList;
  List<_JumbleMission<Object>> _targetList;
  List<Object> get sourceList => _sourceList.map((item) => item.message).toList();
  List<Object> get targetList => _targetList.map((item) => item.message).toList();

  @override
  void initState() {
    super.initState();
    _id = ++_nextId;
    _allInFlight = false;
    _jumbleController = JumbleController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _initLists();
  }

  void _initLists() {
    _sourceList?.forEach((mission) => mission.dispose());
    _targetList?.forEach((mission) => mission.dispose());
    _sourceList = List<_JumbleMission<Object>>();
    _targetList = List<_JumbleMission<Object>>();
    _initList(_sourceList, widget.initialSourceList, _sourceListPrefix);
    _initList(_targetList, widget.initialTargetList, _targetListPrefix);
  }

  void _initList(
      List<_JumbleMission<Object>> list, List<Object> initialList, String prefix) {
    if (initialList != null) {
      for (var i = 0; i < initialList.length; i++) {
        final String id = '$prefix$i';
        list.add(_JumbleMission(
          id,
          initialList[i],
          this,
          widget.animationDuration,
        ));
      }
    }
  }

  void didUpdateWidget(covariant JumbleBuilder<Object> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initLists();
  }

  Future<void> moveAll(JumbleFlightDirection direction) {
    assert(direction != null);
    if (!_allInFlight) {
      _allInFlight = true;
      final List<_JumbleMission> source = _getSource(direction);
      final List<_JumbleMission> target = _getTarget(direction);

      setState(() {
        source.forEach((mission) => mission.startFlight(direction));
        target.addAll(source);
      });

      return _jumbleController
          .move(
        context,
        direction,
        tags: source.map((mission) => _getTag(mission)).toList(),
      )
          .then((_) {
        setState(() {
          source.forEach((mission) => mission.endFlight(direction));
          source.clear();
        });
        _allInFlight = false;
      });
    } else {
      return Future<void>.value(null);
    }
  }

  Future<void> moveAllToSource() => moveAll(JumbleFlightDirection.toSource);
  Future<void> moveAllToTarget() => moveAll(JumbleFlightDirection.toTarget);
  Future<void> move(dynamic message) {
    final _JumbleMission<Object> sourceMission =
        _getFirstMissionInList(_sourceList, message);
    final _JumbleMission<Object> targetMission =
        _getFirstMissionInList(_targetList, message);

    JumbleFlightDirection direction;
    _JumbleMission<Object> mission;
    if (sourceMission != null) {
      direction = JumbleFlightDirection.toTarget;
      mission = sourceMission;
    } else if (targetMission != null) {
      direction = JumbleFlightDirection.toSource;
      mission = targetMission;
    }
    assert(direction != null);
    assert(mission != null);

    if (!mission.inFlight) {
      mission.startFlight(direction);
      final List<_JumbleMission> source = _getSource(direction);
      final List<_JumbleMission> target = _getTarget(direction);

      setState(() {
        target.add(mission);
      });
      return mission.controller
          .move(context, direction, tags: [_getTag(mission)]).then((_) {
        setState(() {
          mission.endFlight(direction);
          source.remove(mission);
        });
      });
    } else {
      return Future<void>.value(null);
    }
  }

  List<_JumbleMission<Object>> _getSource(JumbleFlightDirection direction) {
    return direction == JumbleFlightDirection.toTarget
        ? _sourceList
        : _targetList;
  }

  List<_JumbleMission<Object>> _getTarget(JumbleFlightDirection direction) {
    return direction == JumbleFlightDirection.toTarget
        ? _targetList
        : _sourceList;
  }

  _JumbleMission<Object> _getFirstMissionInList(
      List<_JumbleMission<Object>> list, dynamic message) {
    return list.firstWhere((mission) => identical(mission.message, message),
        orElse: () => null);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return widget.builder(
            context,
            _sourceList
                .map((mission) => _buildJumbleBuilder(
                      context,
                      mission,
                      true,
                    ))
                .toList(),
            _targetList
                .map((mission) => _buildJumbleBuilder(
                      context,
                      mission,
                      false,
                    ))
                .toList());
      },
    );
  }

  JumbleBuilderDelegate<Object> _buildJumbleBuilder(
      BuildContext context, _JumbleMission<Object> mission, bool isSource) {
    return JumbleBuilderDelegate._internal(
      this,
      mission,
      _getTag(mission, isSource: isSource),
      isSource ? _getTag(mission, isSource: false) : null,
      isSource,
    );
  }

  String _getTag(_JumbleMission<Object> mission, {bool isSource = true}) {
    final String prefix = isSource ? 'source_' : 'target_';
    return '${_id}_$prefix${mission.id}';
  }

  @override
  void dispose() {
    _jumbleController?.dispose();
    _sourceList.forEach((mission) => mission.dispose());
    _targetList.forEach((mission) => mission.dispose());
    super.dispose();
  }
}

class JumbleBuilderDelegate<T> {
  JumbleBuilderDelegate._internal(
    this.state,
    this._mission,
    this._tag,
    this._targetTag,
    this._isSource,
  );

  final JumbleBuilderState<T> state;

  final _JumbleMission<Object> _mission;
  final String _tag;
  final String _targetTag;
  final bool _isSource;

  T get message => _mission.message;

  Widget build(
    BuildContext context,
    Widget child, {
    CreateRectTween createRectTween,
    JumbleFlightShuttleBuilder flightShuttleBuilder,
    TransitionBuilder placeholderBuilder,
    JumbleAnimationBuilder animationBuilder,
  }) {
    return Opacity(
      opacity: _getOpacity(),
      child: Jumble(
        key: ObjectKey(_mission),
        tag: _tag,
        targetTag: _targetTag,
        animationBuilder: animationBuilder,
        createRectTween: createRectTween,
        flightShuttleBuilder: flightShuttleBuilder,
        placeholderBuilder: placeholderBuilder,
        child: child,
      ),
    );
  }

  double _getOpacity() {
    if (_mission.inFlightToTheSource && _isSource ||
        _mission.inFlightToTheTarget && !_isSource) {
      return 0.0;
    } else {
      return 1.0;
    }
  }
}