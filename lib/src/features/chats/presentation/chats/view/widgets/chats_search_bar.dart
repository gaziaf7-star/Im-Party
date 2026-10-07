import 'dart:ui';

import 'package:general/src/core/index.dart';

/// WhatsApp-style INLINE search bar for the chats screen. An editable field
/// (typing filters the list in place) with a leading magnifier and a trailing
/// clear button while a query is present. Cleaner, slimmer look the owner
/// preferred — the contacts shortcut now lives in a dedicated FAB.
///
/// Finished as a proper frosted-glass pill (real background blur, a touch of
/// depth via a soft shadow, a solid pill icon badge) now that it always sits
/// on the Chats page's Home-style gradient band, instead of the earlier
/// flat translucent tint.
class ChatsSearchBar extends StatelessWidget {
  const ChatsSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    // True (default) = the original look for the main Chats page, where this
    // bar sits on the Home-style purple gradient band and needs white text.
    // False = for screens with a plain white body (e.g. the New Chat picker)
    // where white-on-white made the text/hint invisible — this switches
    // every color below to a fixed dark tone instead.
    this.light = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final fg = light
        ? ColorManager.homeHeaderTextColor
        : ColorManager.momentPostTextColor;
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: 24.radius,
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: 24.radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: context.paddingSymmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.20),
              borderRadius: 24.radius,
              border: Border.all(
                color: fg.withValues(alpha: 0.35),
                width: 0.7,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 30.h,
                  width: 30.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search, size: 18.sp, color: fg),
                ),
                10.wBox,
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    // Fixed white — matches the fixed white text/icons on
                    // this bar; the panel-driven primary could be almost
                    // invisible against the frosted glass fill.
                    cursorColor: fg,
                    style: context.bodyLarge.size(15).colorExt(fg),
                    decoration: InputDecoration(
                      filled: false,
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: StringManager.search.tr(),
                      hintStyle: context.bodyLarge
                          .size(15)
                          .w400
                          .colorExt(fg.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, __) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : InkWell(
                    borderRadius: 20.radius,
                    onTap: () {
                      controller.clear();
                      onChanged('');
                    },
                    child: Padding(
                      padding: context.paddingAll(4),
                      child: Icon(Icons.close,
                          size: 18.sp, color: fg.withValues(alpha: 0.8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}