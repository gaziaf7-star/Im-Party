import 'package:general/src/core/index.dart';

import '../ludo_room_controller.dart';
import 'ludo_logo_widget.dart';

const _kPurpleTop = Color(0xFF7B2FF7);
const _kPurpleBottom = Color(0xFF3A0CA3);
const _kYellow = Color(0xFFFFC928);

/// Bottom sheet shown from the room's "More options" menu: pick 1 vs 1 /
/// Multi-player, Classic / Simple, Magic, then Create.
Future<void> showLudoCreateSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LudoCreateSheet(),
  );
}

class _LudoCreateSheet extends StatefulWidget {
  const _LudoCreateSheet();

  @override
  State<_LudoCreateSheet> createState() => _LudoCreateSheetState();
}

class _LudoCreateSheetState extends State<_LudoCreateSheet> {
  LudoLobbyMode _mode = LudoLobbyMode.multi;
  LudoRuleSet _rule = LudoRuleSet.classic;
  bool _magic = true;
  int _fee = 0;
  bool _creating = false;
  List<int> _fees = LudoRoomController.instance.config.allowedFees;

  @override
  void initState() {
    super.initState();
    LudoRoomController.instance.loadConfig().then((cfg) {
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
    final error = await LudoRoomController.instance.create(
      lobbyMode: _mode,
      ruleSet: _rule,
      magicOn: _magic,
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
        backgroundColor: const Color(0xFF2A0B6B),
        title: const Text('How to play', style: TextStyle(color: Colors.white)),
        content: const Text(
          '• Roll a 6 to bring a token out.\n'
          '• Move your tokens around the board and bring them home.\n'
          '• Landing on an opponent captures it (not on star squares).\n'
          '• A 6 gives another roll. With Magic on, a capture or reaching '
          'home also gives another roll.\n'
          '• Classic: bring all 4 tokens home. Simple: bring 2 tokens home.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: _kYellow)),
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
          colors: [_kPurpleTop, _kPurpleBottom],
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
                  const LudoLogoWidget(scale: 0.55, showSubtitle: false),
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
                      selected: _mode == LudoLobbyMode.duo,
                      onTap: () => setState(() => _mode = LudoLobbyMode.duo),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ModeCard(
                      title: 'Multi-player',
                      icon: Icons.groups_rounded,
                      selected: _mode == LudoLobbyMode.multi,
                      onTap: () => setState(() => _mode = LudoLobbyMode.multi),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Game mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _Pill(
                    label: 'Classic',
                    selected: _rule == LudoRuleSet.classic,
                    onTap: () => setState(() => _rule = LudoRuleSet.classic),
                  ),
                  SizedBox(width: 10.w),
                  _Pill(
                    label: 'Simple',
                    selected: _rule == LudoRuleSet.simple,
                    onTap: () => setState(() => _rule = LudoRuleSet.simple),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              InkWell(
                onTap: () => setState(() => _magic = !_magic),
                borderRadius: BorderRadius.circular(10.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(
                        _magic
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: _magic ? _kYellow : Colors.white70,
                        size: 24.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Magic',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(Icons.casino_rounded, color: _kYellow, size: 20.r),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
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
                    backgroundColor: _kYellow,
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
                ? const [Color(0xFFFF5CA8), Color(0xFFB4177E)]
                : const [Color(0xFF5B2BC2), Color(0xFF3B1A8C)],
          ),
          border: Border.all(
            color: selected ? _kYellow : Colors.white24,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kYellow.withValues(alpha: 0.35),
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
          color: selected ? _kYellow : Colors.white12,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? _kYellow : Colors.white30),
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
