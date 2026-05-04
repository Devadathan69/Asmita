import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_colors.dart';

class TrackInfo {
  const TrackInfo({
    required this.title,
    required this.asset,
    required this.phase,
  });
  final String title;
  final String asset;
  final CyclePhase phase;
}

class MusicService {
  MusicService() {
    _configure();
  }

  final AudioPlayer _player = AudioPlayer();
  final _tracks = <CyclePhase, List<TrackInfo>>{
    CyclePhase.menstruation: const [
      TrackInfo(
        title: 'Calm 1',
        asset: 'assets/audio/menstruation/calm_1.mp3',
        phase: CyclePhase.menstruation,
      ),
      TrackInfo(
        title: 'Calm 2',
        asset: 'assets/audio/menstruation/calm_2.mp3',
        phase: CyclePhase.menstruation,
      ),
      TrackInfo(
        title: 'Calm 3',
        asset: 'assets/audio/menstruation/calm_3.mp3',
        phase: CyclePhase.menstruation,
      ),
    ],
    CyclePhase.follicular: const [
      TrackInfo(
        title: 'Energetic 1',
        asset: 'assets/audio/follicular/energetic_1.mp3',
        phase: CyclePhase.follicular,
      ),
    ],
    CyclePhase.ovulation: const [
      TrackInfo(
        title: 'Upbeat 1',
        asset: 'assets/audio/ovulation/upbeat_1.mp3',
        phase: CyclePhase.ovulation,
      ),
    ],
    CyclePhase.luteal: const [
      TrackInfo(
        title: 'Gentle 1',
        asset: 'assets/audio/luteal/gentle_1.mp3',
        phase: CyclePhase.luteal,
      ),
    ],
  };
  List<TrackInfo> _current = const [];

  Stream<PlayerState> get playerState => _player.playerStateStream;
  Stream<Duration> get position => _player.positionStream;
  Stream<Duration?> get duration => _player.durationStream;
  TrackInfo? get currentTrack =>
      _current.isEmpty ? null : _current[_player.currentIndex ?? 0];

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

  Future<List<AudioSource>> loadPlaylist(CyclePhase phase) async {
    _current = _tracks[phase] ?? const [];
    final sources =
        _current.map((track) => AudioSource.asset(track.asset)).toList();
    if (sources.isNotEmpty)
      await _player.setAudioSource(ConcatenatingAudioSource(children: sources));
    return sources;
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> next() => _player.seekToNext();
  Future<void> previous() => _player.seekToPrevious();
  Future<void> setLoop(bool loop) =>
      _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0, 1));
  Future<void> seek(Duration position) => _player.seek(position);
  List<TrackInfo> tracksFor(CyclePhase phase) =>
      List.unmodifiable(_tracks[phase] ?? const []);
  Future<void> dispose() => _player.dispose();
}
