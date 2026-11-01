import 'package:flutter_animate/flutter_animate.dart';
import 'package:general/src/core/index.dart';

/// Shared look for the manual-recharge screens: same light cards and accents
/// as the Wallet's Google Pay section.
class MR {
  static const Color bg = Color(0xFFF3F4F7);
  static const Color ink = Color(0xFF1C1C1E);
  static const Color muted = Color(0xFF8E8F96);
  static const Color line = Color(0xFFE3E4E8);
  static const Color field = Color(0xFFF3F4F7);
  static const Color pink = Color(0xFFF8284D);
  static const Color pinkSoft = Color(0xFFFFF4F6);
  static const Color gold = Color(0xFFF5A623);
  static const List<Color> button = [Color(0xFF2EE6CC), Color(0xFF00D0E8)];
  static const List<Color> brand = [Color(0xFFFF5F7E), Color(0xFFF8284D)];

  /// "৳ 500" for BDT, "500 USD" otherwise.
  static String money(num value, String currency) {
    final v = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
    return currency.toUpperCase() == 'BDT' ? '৳ $v' : '$v $currency';
  }

  /// "5 minutes ago · 18 Oct 2026, 8:00 PM".
  static String when(String raw) {
    final t = DateTime.tryParse(raw)?.toLocal();
    if (t == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '${Methods.timeAgo(t)} · ${t.day} ${months[t.month - 1]} ${t.year}, '
        '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  static void copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    Methods.showToast(context, message: '$label copied');
  }
}

/// Soft fade + rise used for every block as it appears, staggered by [index].
extension MREntrance on Widget {
  Widget entrance(int index) => animate(
        delay: Duration(milliseconds: 60 * index),
      )
          .fadeIn(duration: const Duration(milliseconds: 320))
          .slideY(
            begin: 0.08,
            end: 0,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          );
}

class MRCard extends StatelessWidget {
  const MRCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }
}

/// "① Choose a package" style step title.
class MRStepTitle extends StatelessWidget {
  const MRStepTitle({
    super.key,
    required this.step,
    required this.title,
    this.trailing,
  });
  final int step;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: MR.brand),
            ),
            child: Text(
              '$step',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          8.wBox,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: MR.ink,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class MRStatusChip extends StatelessWidget {
  const MRStatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon, String label) = switch (status) {
      'approved' || 'accepted' || 'success' || 'completed' => (
          const Color(0xFF1FAF6B),
          Icons.check_circle_rounded,
          'Approved'
        ),
      'rejected' || 'failed' || 'cancelled' => (
          const Color(0xFFE5484D),
          Icons.cancel_rounded,
          'Rejected'
        ),
      _ => (const Color(0xFFF59E0B), Icons.schedule_rounded, 'Pending'),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          4.wBox,
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grey placeholder block for the loading skeleton (with a soft shimmer).
class MRSkeleton extends StatelessWidget {
  const MRSkeleton({super.key, required this.height, this.width, this.radius});
  final double height;
  final double? width;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFECEDF1),
        borderRadius: BorderRadius.circular(radius ?? 10.r),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: Colors.white.withValues(alpha: .7),
        );
  }
}

/// Centered icon + text + optional button, for empty and error states.
class MRMessage extends StatelessWidget {
  const MRMessage({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: const BoxDecoration(
              color: MR.pinkSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: MR.pink, size: 30.sp),
          ),
          12.hBox,
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MR.ink,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            4.hBox,
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: MR.muted, fontSize: 13.sp, height: 1.4),
            ),
          ],
          if (action != null) ...[
            14.hBox,
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: MR.pink,
                side: const BorderSide(color: MR.pink),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(action!),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }
}
