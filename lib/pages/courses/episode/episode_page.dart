import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/courses/tests/fill_in_the_blanks/fill_in_the_blanks_page.dart';
import 'package:learning_app/views/gradient_button.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class EpisodePage extends StatefulWidget {
  final String url;
  final PlayerMode mode;
  final String appBarTitle;
  final String episodeDetails;
  final String episodeId;

  EpisodePage(
      {Key key,
      @required this.url,
      @required this.appBarTitle,
      @required this.episodeDetails,
      @required this.episodeId,
      this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EpisodePageState(url, mode);
  }
}

class _EpisodePageState extends State<EpisodePage> {
  String url;
  PlayerMode mode;
  AudioPlayer _audioPlayer;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  bool isLoading = false;
  bool isPaused = false;

  get _isPlaying => _playerState == PlayerState.playing;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  _EpisodePageState(this.url, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        _audioPlayer.startHeadlessService();
        _audioPlayer.setNotification(
            title: 'App Name',
            artist: 'Artist or blank',
            albumTitle: 'Name or blank',
            imageUrl: 'url or blank',
            forwardSkipInterval: const Duration(seconds: 30), // default is 30s
            backwardSkipInterval: const Duration(seconds: 30), // default is 30s
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      showLongToast('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });
  }

  void showLongToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 3,
    );
  }

  Future<int> _play() async {
    if (!isPaused) {
      showLongToast('Please wait, your audio will be played in a while');
    }
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);
    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    setState(() {
      isPaused = true;
    });
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: FloatingActionButton(
            heroTag: "backBtn",
            mini: true,
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.blue,
              size: 22,
            ),
          ),
        ),
        title: Text(
          widget.appBarTitle,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      widget.episodeDetails,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    height: 1,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8),
                    child: Row(
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: "play_pause_button",
                          mini: true,
                          elevation: 2,
                          onPressed: _isPlaying ? _pause : _play,
                          backgroundColor:
                              _isPlaying ? Colors.blue : Colors.red,
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                              _positionText == null ? '' : '$_positionText'),
                        ),
                        Slider(
                          onChanged: (v) {
                            final _position = v * _duration.inMilliseconds;
                            _audioPlayer.seek(
                                Duration(milliseconds: _position.round()));
                          },
                          activeColor: Colors.red,
                          value: (_position != null &&
                                  _duration != null &&
                                  _position.inMilliseconds > 0 &&
                                  _position.inMilliseconds <
                                      _duration.inMilliseconds)
                              ? _position.inMilliseconds /
                                  _duration.inMilliseconds
                              : 0.0,
                        ),
                        Text(_durationText == null ? '' : '$_durationText'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: GradientButton(
                onPressed: () async {
                  print(widget.episodeId);
                  QuerySnapshot allQuestions = await Firestore.instance
                      .collection('tests')
                      .getDocuments();
                  List<DocumentSnapshot> questionsList = [];
                  allQuestions.documents.forEach((element) {
                    if (widget.episodeId == element['episodeId']) {
                      questionsList.add(element);
                    }
                  });
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => FillInTheBlankPage(
                            episodeId: widget.episodeId,
                          )));
                },
                height: 50,
                width: MediaQuery.of(context).size.width,
                text: 'Check Your Learning',
              ),
            )
          ],
        ),
      ),
    );
  }
}
