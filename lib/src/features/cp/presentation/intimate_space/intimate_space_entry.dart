import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/cp/presentation/intimate_space/intimate_space_data.dart';
import 'package:general/src/features/cp/presentation/intimate_space/intimate_space_page.dart';

/// Profile card that opens the Intimate Space page; each chip opens its tab.
class IntimateSpaceEntry extends StatelessWidget {
  final UserEntity user;
  final bool isMine;

  const IntimateSpaceEntry({
    super.key,
    required this.user,
    required this.isMine,
  });

  void _open(BuildContext context, RelationKind kind) {
    IntimateSpacePage.open(
      context,
      IntimateSpaceArgs(
        userId: user.id?.toString() ?? '',
        name: user.name ?? '',
        image: user.profile?.image ?? '',
        uuid: user.uuid ?? user.id?.toString() ?? '',
        isMine: isMine,
        initial: kind,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context, RelationKind.cp),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 10.w, 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6FD0FF), Color(0xFF2C8BF0), Color(0xFF1659C9)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1659C9).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 16.sp),
                6.wBox,
                Text(
                  'Intimate Space',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ],
            ),
            10.hBox,
            Row(
              children: [
                for (final kind in RelationKind.values) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _open(context, kind),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(kind.icon, color: Colors.white, size: 20.sp),
                            2.hBox,
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                kind.label,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (kind != RelationKind.values.last) 8.wBox,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
