import 'package:flutter/foundation.dart';

import '../../domain/stamp_draft.dart';

/// The wizard's UI state: the current step, the draft being composed, whether
/// the user is Premium (gates locked filters/borders), and a transient saving
/// flag for the final step (SM-011).
@immutable
class CreatorState {
  const CreatorState({
    required this.step,
    required this.draft,
    this.isPremium = false,
    this.saving = false,
    this.saved = false,
    this.errorMessage,
  });

  /// Initial state when the wizard opens with a freshly picked photo.
  CreatorState.initial(String imagePath)
    : step = CreatorStep.filter,
      draft = StampDraft(imagePath: imagePath),
      isPremium = false,
      saving = false,
      saved = false,
      errorMessage = null;

  final CreatorStep step;
  final StampDraft draft;
  final bool isPremium;
  final bool saving;
  final bool saved;

  /// Set when a save fails (quota reached, upload/network error).
  final String? errorMessage;

  bool get isFirstStep => step == CreatorStep.values.first;
  bool get isLastStep => step == CreatorStep.preview;

  CreatorState copyWith({
    CreatorStep? step,
    StampDraft? draft,
    bool? isPremium,
    bool? saving,
    bool? saved,
    String? errorMessage,
  }) => CreatorState(
    step: step ?? this.step,
    draft: draft ?? this.draft,
    isPremium: isPremium ?? this.isPremium,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    errorMessage: errorMessage,
  );
}
