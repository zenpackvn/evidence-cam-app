import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart';

/// Một gói bày bán trên paywall — thuần dữ liệu hiển thị, không dính SDK thanh
/// toán. Nhờ vậy màn hình test được mà không cần cửa hàng thật.
class EcPaywallOffer {
  const EcPaywallOffer({
    required this.planCode,
    required this.termKey,
    required this.priceLabel,
    required this.priceAmount,
  });

  final String planCode;
  final String termKey;

  /// Chuỗi giá do cửa hàng định dạng. Hiển thị nguyên văn.
  final String priceLabel;
  final double priceAmount;
}

/// Nền xanh rất nhạt cho chip và khối lưu ý. `PenColors` không có tông này vì
/// design file chưa từng cần tới; giữ ở đây thay vì nhét vào design system cho
/// tới khi có màn thứ hai dùng nó.
const _tint = Color(0xFFE9F2EC);

/// Ba thời hạn bán, kèm mức giảm so với mua từng tháng.
const _terms = <({String key, String label, int months, String? save})>[
  (key: '1m', label: '1 tháng', months: 1, save: null),
  (key: '6m', label: '6 tháng', months: 6, save: 'Tiết kiệm 8%'),
  (key: '12m', label: '12 tháng', months: 12, save: 'Tiết kiệm 12%'),
];

/// Ba mức dung lượng. Thứ tự này là thứ tự hiển thị.
const _plans = <({String code, String name, String storage, String note})>[
  (code: 'basic', name: 'Cơ bản', storage: '60 GB', note: 'Gói tiêu chuẩn'),
  (code: 'saver', name: 'Tiết kiệm', storage: '120 GB', note: ''),
  (
    code: 'premium',
    name: 'Cao cấp',
    storage: '200 GB',
    note: 'Dung lượng cao nhất',
  ),
];

/// Quyền lợi giống hệt nhau ở mọi gói — nêu một lần dưới các thẻ thay vì lặp
/// ba lần. Chính chỗ này là điểm khác biệt so với đối thủ, đừng giấu nó đi.
const _benefits = <String>[
  'Không giới hạn người dùng',
  'Không giới hạn camera',
  'Không giới hạn thời lượng video',
  'Lưu bằng chứng trong 30 ngày',
];

/// Màn chọn gói. Ma trận 3 mức dung lượng × 3 thời hạn, trình bày thành một
/// dải chọn thời hạn ở trên và ba thẻ gói ở dưới — không đổ phẳng 9 dòng.
///
/// Sản phẩm là **mua đứt**: mọi chỗ nhắc tới gia hạn hay khôi phục mua hàng đều
/// ở dạng phủ định. Nói sai chỗ này vừa lừa người dùng vừa là cớ để App Review
/// từ chối.
class EcPaywallScreen extends StatefulWidget {
  const EcPaywallScreen({
    required this.offers,
    this.onBack,
    this.onBuy,
    this.busy = false,
    this.initialTermKey = '6m',
    super.key,
  });

  final List<EcPaywallOffer> offers;
  final VoidCallback? onBack;
  final void Function(EcPaywallOffer offer)? onBuy;

  /// Đang chờ cửa hàng hoặc chờ backend áp giao dịch — khoá nút để không mua
  /// hai lần.
  final bool busy;

  /// Mặc định 6 tháng: đủ cam kết để có giảm giá mà không gây sốc như 12 tháng.
  final String initialTermKey;

  @override
  State<EcPaywallScreen> createState() => _EcPaywallScreenState();
}

class _EcPaywallScreenState extends State<EcPaywallScreen> {
  late String _term = widget.initialTermKey;
  String _plan = 'saver';

  List<EcPaywallOffer> get _visible =>
      widget.offers.where((o) => o.termKey == _term).toList();

  EcPaywallOffer? get _selected {
    for (final offer in _visible) {
      if (offer.planCode == _plan) return offer;
    }
    return null;
  }

  /// Giá quy đổi mỗi tháng, chỉ hiện với thời hạn dài. Người mua so sánh theo
  /// tháng chứ không theo tổng, nên thiếu dòng này thì gói 12 tháng nhìn đắt.
  String? _perMonth(EcPaywallOffer offer) {
    final months = _terms.firstWhere((t) => t.key == offer.termKey).months;
    if (months == 1) return null;
    final each = (offer.priceAmount / months).round();
    final digits = each.toString();
    final grouped = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write('.');
      grouped.write(digits[i]);
    }
    return '≈ ${grouped}đ/tháng';
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return PenScreen(
      bottomBar: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        child: PenPrimaryButton(
          label: widget.busy ? 'Đang xử lý…' : 'Tiếp tục',
          onPressed: widget.busy || selected == null
              ? null
              : () => widget.onBuy?.call(selected),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PaywallHeader(),
            const SizedBox(height: 18),
            _TermPicker(
              value: _term,
              onChanged: (key) => setState(() => _term = key),
            ),
            const SizedBox(height: 14),
            if (_visible.isEmpty)
              const _OffersUnavailable()
            else
              for (final plan in _plans)
                for (final offer in _visible.where(
                  (o) => o.planCode == plan.code,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PlanCard(
                      name: plan.name,
                      storage: plan.storage,
                      note: plan.note,
                      priceLabel: offer.priceLabel,
                      perMonth: _perMonth(offer),
                      recommended: plan.code == 'saver',
                      selected: plan.code == _plan,
                      onTap: () => setState(() => _plan = plan.code),
                    ),
                  ),
            const SizedBox(height: 4),
            const _BenefitList(),
            const SizedBox(height: 10),
            const _OneTimeNotice(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Logo, tiêu đề và hình kiện hàng. Nền trắng chứ không phải dải xanh: màn này
/// bán hàng, và chữ xanh trên nền sáng đọc dễ hơn chữ trắng trên nền đậm.
class _PaywallHeader extends StatelessWidget {
  const _PaywallHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.packageCheck,
                    size: 24,
                    color: PenColors.primary,
                  ),
                  SizedBox(width: 8),
                  PenText(
                    'Zenpack',
                    size: 20,
                    color: PenColors.primary,
                    weight: FontWeight.w700,
                  ),
                ],
              ),
              SizedBox(height: 14),
              PenText(
                'Chọn gói sử dụng',
                size: 28,
                color: PenColors.primary,
                weight: FontWeight.w800,
              ),
              SizedBox(height: 6),
              PenText(
                'Mua một lần • Không tự động gia hạn',
                size: 14,
                color: PenColors.mut,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Hình minh hoạ của design system, cùng bộ với các màn khác.
        //
        // FittedBox chứ KHÔNG phải Transform.scale: Transform chỉ thu nhỏ nét
        // vẽ mà vẫn chiếm nguyên 102×132, để lại một mảng trống dưới header và
        // đẩy khối lưu ý xuống dưới nút.
        const SizedBox(
          width: 78,
          height: 100,
          child: FittedBox(child: PenParcelSprite()),
        ),
      ],
    );
  }
}

class _TermPicker extends StatelessWidget {
  const _TermPicker({required this.value, required this.onChanged});

  final String value;
  final void Function(String key) onChanged;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      fill: PenColors.card,
      radius: 14,
      stroke: PenColors.line,
      padding: const EdgeInsets.all(5),
      axis: PenAxis.row,
      gap: 5,
      children: [
        for (final term in _terms)
          Expanded(
            child: EcTap(
              onTap: () => onChanged(term.key),
              child: PenBox(
                height: 62,
                // Ô đang chọn tô xanh đặc: trạng thái chọn phải đọc được từ xa
                // trong kho, nơi màn hình thường nghiêng và có nắng.
                fill: term.key == value ? PenColors.primary : PenColors.card,
                radius: 11,
                axis: PenAxis.column,
                gap: 4,
                main: MainAxisAlignment.center,
                cross: CrossAxisAlignment.center,
                children: [
                  PenText(
                    term.label,
                    size: 15,
                    color: term.key == value
                        ? const Color(0xFFFFFFFF)
                        : PenColors.ink,
                    weight: FontWeight.w700,
                  ),
                  if (term.save != null)
                    PenBox(
                      fill: term.key == value ? const Color(0x33FFFFFF) : _tint,
                      radius: 6,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      children: [
                        PenText(
                          term.save!,
                          size: 11,
                          color: term.key == value
                              ? const Color(0xFFFFFFFF)
                              : PenColors.primary,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.storage,
    required this.note,
    required this.priceLabel,
    required this.perMonth,
    required this.recommended,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String storage;
  final String note;
  final String priceLabel;
  final String? perMonth;
  final bool recommended;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        fill: PenColors.card,
        radius: 14,
        stroke: selected ? PenColors.primary : PenColors.line,
        strokeWidth: selected ? 1.5 : 1,
        shadows: selected ? const [penCardShadow] : const [],
        padding: const EdgeInsets.all(14),
        axis: PenAxis.row,
        gap: 12,
        cross: CrossAxisAlignment.center,
        children: [
          const PenParcelGlyph(size: 44),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PenText(
                  name,
                  size: 18,
                  color: PenColors.primary,
                  weight: FontWeight.w700,
                ),
                const SizedBox(height: 2),
                PenText(
                  storage,
                  size: 20,
                  color: PenColors.ink,
                  weight: FontWeight.w800,
                ),
                const SizedBox(height: 4),
                if (recommended)
                  PenBox(
                    fill: _tint,
                    radius: 6,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    axis: PenAxis.row,
                    gap: 4,
                    cross: CrossAxisAlignment.center,
                    hugMain: true,
                    children: const [
                      Icon(
                        LucideIcons.star,
                        size: 12,
                        color: PenColors.primary,
                      ),
                      PenText(
                        'Phổ biến nhất',
                        size: 12,
                        color: PenColors.primary,
                        weight: FontWeight.w600,
                      ),
                    ],
                  )
                else
                  PenText(note, size: 13, color: PenColors.mut),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PenBox(
                fill: _tint,
                radius: 6,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                children: const [
                  PenText(
                    'Thanh toán 1 lần',
                    size: 11,
                    color: PenColors.primary,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PenText(
                priceLabel,
                size: 20,
                color: PenColors.primary,
                weight: FontWeight.w800,
              ),
              if (perMonth != null) ...[
                const SizedBox(height: 2),
                PenText(perMonth!, size: 12, color: PenColors.mut),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitList extends StatelessWidget {
  const _BenefitList();

  @override
  Widget build(BuildContext context) {
    return PenCard(
      axis: PenAxis.column,
      gap: 11,
      lifted: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        for (final benefit in _benefits)
          Row(
            children: [
              const Icon(
                LucideIcons.circleCheck,
                size: 18,
                color: PenColors.success,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PenText(
                  benefit,
                  size: 14,
                  color: PenColors.ink,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Điều khoản mua đứt, nói thẳng ở màn thanh toán chứ không giấu trong Điều
/// khoản sử dụng. Dòng cuối là bắt buộc: sản phẩm tiêu hao không khôi phục
/// được, người dùng phải biết TRƯỚC khi trả tiền.
class _OneTimeNotice extends StatelessWidget {
  const _OneTimeNotice();

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      fill: _tint,
      radius: 14,
      padding: const EdgeInsets.all(14),
      axis: PenAxis.row,
      gap: 12,
      cross: CrossAxisAlignment.start,
      children: const [
        Icon(LucideIcons.shieldCheck, size: 22, color: PenColors.primary),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PenText(
                'Đây là gói mua một lần, không tự động gia hạn. Khi gói hết '
                'hạn, bạn sẽ không thể quay video mới. Bằng chứng đã lưu vẫn '
                'được giữ lại. Bạn có thể mua thêm gói bất cứ lúc nào để tiếp '
                'tục sử dụng.',
                size: 13,
                color: PenColors.ink,
                lineHeight: 1.45,
              ),
              SizedBox(height: 8),
              PenText(
                'Gói tiêu hao không hỗ trợ khôi phục mua hàng.',
                size: 13,
                color: PenColors.mut,
                lineHeight: 1.45,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cửa hàng chưa trả về gói nào (mất mạng, sản phẩm chưa duyệt, sai cấu hình).
/// Phải nói ra thay vì hiện màn trắng — người dùng đang muốn trả tiền.
class _OffersUnavailable extends StatelessWidget {
  const _OffersUnavailable();

  @override
  Widget build(BuildContext context) {
    return PenCard(
      axis: PenAxis.column,
      gap: 6,
      lifted: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: const [
        PenText(
          'Chưa tải được bảng giá',
          size: 15,
          color: PenColors.ink,
          weight: FontWeight.w700,
        ),
        PenText(
          'Kiểm tra kết nối mạng rồi thử lại.',
          size: 13,
          color: PenColors.mut,
          lineHeight: 1.4,
        ),
      ],
    );
  }
}
