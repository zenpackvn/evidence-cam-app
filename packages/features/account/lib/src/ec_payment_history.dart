/// Màn "Lịch sử thanh toán" — mọi lần trả tiền của tài khoản, mới nhất trước.
///
/// Backend đã gộp ba đường thu (PayOS / chuyển khoản cũ / App Store) thành một
/// danh sách, nên ở đây không ghép và không sắp xếp lại — chỉ vẽ.
library;

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Một dòng trong lịch sử. Cố ý KHÔNG dùng thẳng `PaymentDto` của `ec_data`:
/// package giao diện không được phụ thuộc tầng dữ liệu, và màn hình này chỉ cần
/// những gì nó vẽ.
class EcPaymentEntry {
  const EcPaymentEntry({
    required this.id,
    required this.title,
    required this.status,
    required this.dateLabel,
    required this.sourceLabel,
    this.amountLabel,
    this.sandbox = false,
  });

  /// Mã đối soát — hiện nhỏ ở cuối dòng để người dùng đọc cho CSKH.
  final String id;

  /// Gói + thời hạn, ví dụ `Cơ bản · 6 tháng`.
  final String title;
  final EcPaymentStatus status;
  final String dateLabel;

  /// `Thanh toán web` / `Chuyển khoản` / `Mua trong ứng dụng`.
  final String sourceLabel;

  /// Số tiền đã định dạng. **Null khi hệ thống không biết giá** (mua trong ứng
  /// dụng — App Store giữ điểm giá theo SKU). Null hiện dấu gạch, không hiện 0:
  /// một con số 0 trên chứng từ thu tiền là sai, không phải "chưa biết".
  final String? amountLabel;

  /// Giao dịch thử của App Store sandbox.
  final bool sandbox;
}

enum EcPaymentStatus { paid, pending, cancelled, expired, refunded }

/// Danh sách lịch sử thanh toán.
///
/// Bốn trạng thái màn hình đều phải có mặt: đang tải, lỗi (có nút thử lại),
/// rỗng, và có dữ liệu. Thiếu nhánh lỗi thì mạng hỏng trông y hệt "bạn chưa
/// từng trả tiền" — với một màn hình tiền bạc thì đó là hiểu nhầm tệ nhất.
class EcPaymentHistoryScreen extends StatelessWidget {
  const EcPaymentHistoryScreen({
    this.entries = const [],
    this.loading = false,
    this.errorMessage,
    this.onBack,
    this.onRetry,
    super.key,
  });

  final List<EcPaymentEntry> entries;
  final bool loading;
  final String? errorMessage;
  final VoidCallback? onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
            child: Row(
              children: [
                PenBackButton(onTap: onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: PenText(
                    l10n.quotaPaymentHistory,
                    size: 23,
                    color: PenColors.ink,
                    weight: FontWeight.w800,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body(context, l10n)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    if (loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    final error = errorMessage;
    if (error != null) {
      return _Message(
        icon: LucideIcons.cloudOff,
        title: error,
        actionLabel: l10n.commonRetry,
        onAction: onRetry,
      );
    }
    if (entries.isEmpty) {
      return _Message(
        icon: LucideIcons.receiptText,
        title: l10n.paymentHistoryEmptyTitle,
        body: l10n.paymentHistoryEmptyBody,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _PaymentRow(entry: entries[index]),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.entry});

  final EcPaymentEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenCard(
      axis: PenAxis.column,
      gap: 6,
      padding: const EdgeInsets.all(14),
      cross: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PenText(
                entry.title,
                size: 15,
                color: PenColors.ink,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            PenText(
              // Không biết giá thì để gạch — xem [EcPaymentEntry.amountLabel].
              entry.amountLabel ?? '—',
              size: 15,
              color: PenColors.ink,
              weight: FontWeight.w700,
              softWrap: false,
            ),
          ],
        ),
        Row(
          children: [
            _StatusPill(status: entry.status),
            const SizedBox(width: 8),
            Expanded(
              child: PenText(
                entry.dateLabel,
                size: 12,
                color: PenColors.mut,
                softWrap: false,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: PenText(
                entry.sourceLabel,
                size: 12,
                color: PenColors.mut,
              ),
            ),
            PenText(
              entry.id,
              size: 11,
              color: PenColors.mut,
              softWrap: false,
            ),
          ],
        ),
        // Giao dịch sandbox nằm lẫn trong lịch sử trông y hệt tiền thật nếu
        // không nói ra.
        if (entry.sandbox)
          PenText(
            l10n.paymentSandboxNote,
            size: 11,
            color: PenColors.mut,
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final EcPaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color) = switch (status) {
      EcPaymentStatus.paid => (l10n.paymentStatusPaid, PenColors.success),
      EcPaymentStatus.pending => (l10n.paymentStatusPending, PenColors.warning),
      EcPaymentStatus.cancelled => (l10n.paymentStatusCancelled, PenColors.mut),
      EcPaymentStatus.expired => (l10n.paymentStatusExpired, PenColors.mut),
      EcPaymentStatus.refunded => (
        l10n.paymentStatusRefunded,
        PenColors.warning,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: PenText(
        label,
        size: 11,
        color: color,
        weight: FontWeight.w700,
        softWrap: false,
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: PenColors.mut),
            const SizedBox(height: 14),
            PenText(
              title,
              size: 16,
              color: PenColors.ink,
              weight: FontWeight.w700,
              align: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: 6),
              PenText(
                body!,
                size: 13,
                color: PenColors.mut,
                align: TextAlign.center,
              ),
            ],
            if (label != null) ...[
              const SizedBox(height: 18),
              PenOutlineButton(label: label, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
