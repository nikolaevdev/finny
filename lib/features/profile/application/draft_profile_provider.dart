import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class DraftProfile {
  const DraftProfile({
    this.playerName = '',
    this.demoMode = false,
    this.petName = 'Финни',
    this.colorIndex = 0,
    this.earsIndex = 0,
    this.patternIndex = 0,
  });

  final String playerName;
  final bool demoMode;
  final String petName;
  final int colorIndex;
  final int earsIndex;
  final int patternIndex;

  DraftProfile copyWith({
    String? playerName,
    bool? demoMode,
    String? petName,
    int? colorIndex,
    int? earsIndex,
    int? patternIndex,
  }) {
    return DraftProfile(
      playerName: playerName ?? this.playerName,
      demoMode: demoMode ?? this.demoMode,
      petName: petName ?? this.petName,
      colorIndex: colorIndex ?? this.colorIndex,
      earsIndex: earsIndex ?? this.earsIndex,
      patternIndex: patternIndex ?? this.patternIndex,
    );
  }
}

class DraftProfileNotifier extends Notifier<DraftProfile> {
  @override
  DraftProfile build() => const DraftProfile();

  void setPlayer({required String name, required bool demoMode}) {
    state = state.copyWith(playerName: name.trim(), demoMode: demoMode);
  }

  void setPet({
    required String name,
    required int colorIndex,
    required int earsIndex,
    required int patternIndex,
  }) {
    state = state.copyWith(
      petName: name.trim(),
      colorIndex: colorIndex,
      earsIndex: earsIndex,
      patternIndex: patternIndex,
    );
  }

  void reset() {
    state = const DraftProfile();
  }
}

final draftProfileProvider =
    NotifierProvider<DraftProfileNotifier, DraftProfile>(
      DraftProfileNotifier.new,
    );
