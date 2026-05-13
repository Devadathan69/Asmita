import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_colors.dart';

class TrackInfo {
  const TrackInfo({
    required this.title,
    required this.asset,
    required this.phase,
    required this.description,
  });
  final String title;
  final String asset;
  final CyclePhase phase;
  final String description;
}

class MusicService {
  MusicService() {
    _configure();
  }

  final AudioPlayer _player = AudioPlayer();
  final _tracks = <CyclePhase, List<TrackInfo>>{
    CyclePhase.menstruation: const [
      TrackInfo(
        title: 'Gentle Relief',
        asset: 'assets/audio/menstruation/music3.mpeg',
        phase: CyclePhase.menstruation,
        description: 'Soft rest for period days',
      ),
      TrackInfo(
        title: 'Soft Rest',
        asset: 'assets/audio/menstruation/music4.mpeg',
        phase: CyclePhase.menstruation,
        description: 'Calm and soothing',
      ),
    ],
    CyclePhase.follicular: const [
      TrackInfo(
        title: 'Fresh Start',
        asset: 'assets/audio/follicular/music1.mpeg',
        phase: CyclePhase.follicular,
        description: 'Light energy for fresh days',
      ),
      TrackInfo(
        title: 'Light Energy',
        asset: 'assets/audio/follicular/music2.mpeg',
        phase: CyclePhase.follicular,
        description: 'Gentle lift',
      ),
    ],
    CyclePhase.ovulation: const [
      TrackInfo(
        title: 'Light Bloom',
        asset: 'assets/audio/follicular/music2.mpeg',
        phase: CyclePhase.ovulation,
        description: 'Feel-good phase music',
      ),
    ],
    CyclePhase.luteal: const [
      TrackInfo(
        title: 'Calm Grounding',
        asset: 'assets/audio/menstruation/music4.mpeg',
        phase: CyclePhase.luteal,
        description: 'Gentle grounding for slower days',
      ),
    ],
  };
  List<TrackInfo> _current = const [];

  Stream<PlayerState> get playerState => _player.playerStateStream;
  Stream<Duration> get position => _player.positionStream;
  Stream<Duration?> get duration => _player.durationStream;
  Stream<int?> get currentIndex => _player.currentIndexStream;
  Stream<double> get volume => _player.volumeStream;
  bool get isPlaying => _player.playing;
  double get currentVolume => _player.volume;
  bool get hasActiveTrack =>
      currentTrack != null && _player.processingState != ProcessingState.idle;
  TrackInfo? get currentTrack {
    if (_current.isEmpty) return null;
    final index = (_player.currentIndex ?? 0).clamp(0, _current.length - 1);
    return _current[index];
  }

  Future<void> _configure() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
      ),
    );
  }

  Future<List<AudioSource>> loadPlaylist(
    CyclePhase phase, {
    int initialIndex = 0,
    bool autoplay = false,
  }) async {
    _current = _tracks[phase] ?? const [];
    final sources =
        _current.map((track) => AudioSource.asset(track.asset)).toList();
    if (sources.isNotEmpty) {
      await _player.setAudioSource(
        ConcatenatingAudioSource(children: sources),
        initialIndex: initialIndex.clamp(0, sources.length - 1),
      );
      await _player.setVolume(_player.volume == 0 ? .7 : _player.volume);
      if (autoplay) await _player.play();
    }
    return sources;
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> togglePlayPause() => _player.playing ? pause() : play();
  Future<void> next() async {
    if (_current.isEmpty) return;
    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      await _player.seek(Duration.zero, index: 0);
    }
    await _player.play();
  }

  Future<void> previous() async {
    if (_current.isEmpty) return;
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero, index: _current.length - 1);
    }
    await _player.play();
  }

  Future<void> stop() => _player.stop();
  Future<void> setLoop(bool loop) =>
      _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0, 1));
  Future<void> seek(Duration position) => _player.seek(position);
  List<TrackInfo> tracksFor(CyclePhase phase) =>
      List.unmodifiable(_tracks[phase] ?? const []);
  Future<void> dispose() => _player.dispose();
}
