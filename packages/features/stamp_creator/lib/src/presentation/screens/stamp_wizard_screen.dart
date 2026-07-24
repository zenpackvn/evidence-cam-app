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
import 'quota_reached_sheet.dart';
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
    this.frameStyle = StampFrameStyle.none,
    this.isPremium = false,
    super.key,
  });

  final String imagePath;

  /// The tem edge chosen in the camera, carried into the whole wizard.
  final StampFrameStyle frameStyle;
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
        frameStyle: frameStyle,
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

  static const Map<CreatorStep, ({String accent, String lead, String subtitle})>
  _copy = {
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
      lead: 'Xem trước và hoàn thiện',
      accent: '',
      subtitle: 'Kiểm tra lần cuối trước khi lưu vào bộ sưu tập của bạn.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreatorCubit, CreatorState>(
      listenWhen: (prev, next) =>
          (!prev.quotaReached && next.quotaReached) ||
          (next.errorMessage != null && prev.errorMessage != next.errorMessage),
      listener: (context, state) {
        if (state.quotaReached) {
          // Show the F02-S13 quota modal once, then clear the flag so a later
          // save can trigger it again.
          context.read<CreatorCubit>().resetQuota();
          showQuotaReachedSheet(context, draft: state.draft);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreatorCubit>();

        // System back mirrors the "Quay lại" button: step back through the
        // wizard, and only leave to the picker from the first step. Without this
        // the OS back would pop the whole wizard at once, skipping the steps.
        void handleBack() {
          if (state.saved) {
            onViewAlbum();
            return;
          }
          if (!cubit.back()) onExit();
        }

        final Widget child;
        if (state.saved) {
          final name = state.name.trim();
          child = SaveSuccessScreen(
            onViewAlbum: onViewAlbum,
            onCreateAnother: onCreateAnother,
            draft: state.draft,
            stampName: name.isEmpty ? 'Con tem mới' : name,
          );
        } else {
          final copy = _copy[state.step]!;
          final isPreview = state.step == CreatorStep.preview;
          child = WizardScaffold(
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
              nextLabel: isPreview ? 'Lưu tem ✨' : 'Tiếp theo',
              nextEnabled: !state.saving,
              onBack: handleBack,
              onNext: () {
                if (isPreview) {
                  cubit.save();
                } else {
                  cubit.next();
                }
              },
            ),
          );
        }

        // Let the route pop itself (back to the picker) from the first step;
        // only intercept when there is an earlier step or success screen to
        // fall back to — otherwise `onExit`'s maybePop would be swallowed by
        // this PopScope and back would do nothing.
        final canPop = !state.saved && state.step == CreatorStep.filter;
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            handleBack();
          },
          child: child,
        );
      },
    );
  }
}
