import 'package:feature_album/feature_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../data/stamp_uploader.dart';
import '../../domain/stamp_draft.dart';
import '../bloc/creator_cubit.dart';
import '../bloc/creator_state.dart';
import '../widgets/wizard_actions.dart';
import '../widgets/wizard_scaffold.dart';
import 'decorate_step.dart';
import 'filter_step.dart';
import 'preview_step.dart';
import 'save_success_screen.dart';

/// The create-a-stamp wizard (SM-006 → SM-011), driven by [CreatorCubit]. It
/// opens on the filter step with a picked photo and walks filter → decorate →
/// preview; the final action saves and shows the success screen. The source pick
/// (SM-005) is a separate screen that constructs this with the chosen path.
class StampWizardScreen extends StatelessWidget {
  const StampWizardScreen({
    required this.imagePath,
    required this.onExit,
    required this.onViewAlbum,
    required this.onCreateAnother,
    this.isPremium = false,
    super.key,
  });

  final String imagePath;
  final bool isPremium;

  /// Called when the user backs out of the first wizard step (to the picker).
  final VoidCallback onExit;
  final VoidCallback onViewAlbum;
  final VoidCallback onCreateAnother;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatorCubit(
        imagePath: imagePath,
        isPremium: isPremium,
        uploader: GetIt.instance<StampUploader>(),
        stamps: GetIt.instance<StampsRepository>(),
      ),
      child: _WizardView(
        onExit: onExit,
        onViewAlbum: onViewAlbum,
        onCreateAnother: onCreateAnother,
      ),
    );
  }
}

class _WizardView extends StatelessWidget {
  const _WizardView({
    required this.onExit,
    required this.onViewAlbum,
    required this.onCreateAnother,
  });

  final VoidCallback onExit;
  final VoidCallback onViewAlbum;
  final VoidCallback onCreateAnother;

  static const Map<CreatorStep, ({String accent, String lead, String subtitle})> _copy = {
    CreatorStep.filter: (
      lead: 'Chọn ',
      accent: 'bộ lọc màu',
      subtitle: 'Thay đổi phong cách ảnh với các bộ lọc đẹp mắt theo chủ đề.',
    ),
    CreatorStep.decorate: (
      lead: 'Trang trí ',
      accent: 'con tem',
      subtitle: 'Thêm sticker, họa tiết và viền tem để con tem thêm sinh động.',
    ),
    CreatorStep.preview: (
      lead: 'Xem trước ',
      accent: 'con tem',
      subtitle: 'Kiểm tra con tem của bạn trước khi lưu vào Album.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreatorCubit, CreatorState>(
      listenWhen: (prev, next) =>
          next.errorMessage != null && prev.errorMessage != next.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      builder: (context, state) {
        if (state.saved) {
          return SaveSuccessScreen(
            onViewAlbum: onViewAlbum,
            onCreateAnother: onCreateAnother,
          );
        }

        final cubit = context.read<CreatorCubit>();
        final copy = _copy[state.step]!;
        final isPreview = state.step == CreatorStep.preview;

        return WizardScaffold(
          titleLead: copy.lead,
          titleAccent: copy.accent,
          subtitle: copy.subtitle,
          showCrown: !state.isPremium && !isPreview,
          body: switch (state.step) {
            CreatorStep.source => const SizedBox.shrink(),
            CreatorStep.filter => const FilterStep(),
            CreatorStep.decorate => const DecorateStep(),
            CreatorStep.preview => const PreviewStep(),
          },
          actions: WizardActions(
            nextLabel: isPreview ? 'Lưu tem' : 'Tiếp theo',
            nextEnabled: !state.saving,
            onBack: () {
              if (!cubit.back()) onExit();
            },
            onNext: () {
              if (isPreview) {
                cubit.save();
              } else {
                cubit.next();
              }
            },
          ),
        );
      },
    );
  }
}
