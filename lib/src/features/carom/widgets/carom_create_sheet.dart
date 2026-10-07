import 'package:general/src/core/index.dart';

import '../carom_room_controller.dart';

const _kTop = Color(0xFF7A3516);
const _kBottom = Color(0xFF2B1209);
const _kGold = Color(0xFFF5B83D);

/// Bottom sheet shown from the room's "More options" menu: pick 1 vs 1 /
/// 2 vs 2 and the entry fee, then Create.
Future<void> showCaromCreateSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CaromCreateSheet(),
  );
}

class _CaromCreateSheet extends StatefulWidget {
  const _CaromCreateSheet();

  @override
  State<_CaromCreateSheet> createState() => _CaromCreateSheetState();
}

class _CaromCreateSheetState extends State<_CaromCreateSheet> {
  CaromMode _mode = CaromMode.duo;
  int _fee = 0;
  bool _creating = false;
  List<int> _fees = CaromRoomController.instance.config.allowedFees;

  @override
  void initState() {
    super.initState();
    CaromRoomController.instance.loadConfig().then((cfg) {
      if (!mounted) return;
      setState(() {
        _fees = cfg.allowedFees;
        if (!_fees.contains(_fee)) _fee = _fees.isEmpty ? 0 : _fees.first;
      });
    });
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    final error = await CaromRoomController.instance.create(
      lobbyMode: _mode,
      fee: _fee,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _creating = false);
      Methods.showToast(context, message: error, isError: true);
    }
  }

  void _showRules() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF3A1A0B),
        title: const Text('How to play', style: TextStyle(color: Colors.white)),
        content: const Text(
          '• Slide the striker along your line, pull back from it and let go to shoot.\n'
          '• Pocket your own coins (white or black) to keep the turn.\n'
          '• The Queen must be covered by pocketing one of your coins right after.\n'
          '• Pocketing the striker is a foul and the turn passes.\n'
          '• Clear all your coins after covering the Queen to win.\n'
          '• 2 vs 2: partners sit opposite each other and share one score.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: _kGold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kTop, _kBottom],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _roundIcon(Icons.question_mark_rounded, _showRules),
                  const Spacer(),
                  Text(
                    'CARROM',
                    style: TextStyle(
                      color: _kGold,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  _roundIcon(Icons.close_rounded, () => Navigator.pop(context)),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: _ModeCard(
                      title: '1 vs 1',
                      icon: Icons.people_alt_rounded,
                      selected: _mode == CaromMode.duo,
                      onTap: () => setState(() => _mode = CaromMode.duo),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ModeCard(
                      title: '2 vs 2',
                      icon: Icons.groups_rounded,
                      selected: _mode == CaromMode.doubles,
                      onTap: () => setState(() => _mode = CaromMode.doubles),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Entry fee (coins)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final f in _fees)
                    _Pill(
                      label: f == 0 ? 'Free' : '$f',
                      selected: _fee == f,
                      onTap: () => setState(() => _fee = f),
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'This game is compliance by law and prohibited to use it for '
                'monetary transactions. Please use it legally.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11.sp,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: const Color(0xFF3A1C00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    elevation: 4,
                  ),
                  child: _creating
                      ? SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF3A1C00),
                          ),
                        )
                      : Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    customBorder: const CircleBorder(),
    child: Container(
      width: 32.r,
      height: 32.r,
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18.r),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 110.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? const [Color(0xFFE08A2B), Color(0xFF9A4A0F)]
                : const [Color(0xFF5A2C14), Color(0xFF3A1A0B)],
          ),
          border: Border.all(
            color: selected ? _kGold : Colors.white24,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kGold.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40.r),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? _kGold : Colors.white12,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? _kGold : Colors.white30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF3A1C00) : Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
