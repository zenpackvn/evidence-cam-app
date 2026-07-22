import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/letter_content.dart';
import '../widgets/letter_paper.dart';

/// Read-only view of a letter the user composed, opened from the Home "Thư gần
/// đây" cards or the sent box (SM-021). The content comes from the local cache
/// stashed at create time ([loadContent]); when the letter was not composed on
/// this device there is nothing to show, so a friendly note explains why.
class SentLetterViewScreen extends StatefulWidget {
  const SentLetterViewScreen({
    required this.loadContent,
    this.title = 'Nội dung thư',
    super.key,
  });

  /// Loads the letter's content (typically `repo.cachedContent(letterId)`).
  final Future<LetterContent?> Function() loadContent;

  final String title;

  static const _ground = Color(0xFFFBF4EC);

  @override
  State<SentLetterViewScreen> createState() => _SentLetterViewScreenState();
}

class _SentLetterViewScreenState extends State<SentLetterViewScreen> {
  bool _loading = true;
  LetterContent? _content;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final content = await widget.loadContent();
    if (!mounted) return;
    setState(() {
      _content = content;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SentLetterViewScreen._ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  Material(
                    color: context.brand.surfaceElevated,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.chevron_left, size: 22),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: context.textTheme.displayMedium?.copyWith(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _content == null
                  ? const _MissingContent()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        0,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                      ),
                      child: ReadOnlyLetterPaper(content: _content!),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the letter was not composed on this device (no cached body).
class _MissingContent extends StatelessWidget {
  const _MissingContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 56,
            color: context.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Không xem lại được nội dung',
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Thư này được gửi từ thiết bị khác nên không còn bản nội dung '
            'trên máy này.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
