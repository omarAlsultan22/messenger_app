import '../../presentation/enums/processing_state.dart';


class AudioPlayerState {
  final bool playing;
  final ProcessingState processingState;

  AudioPlayerState(this.playing, this.processingState);
}