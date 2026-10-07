part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _NormalAppBarBody extends StatelessWidget {
  final MessagesParameter params;
  const _NormalAppBarBody({required this.params});

  /// "Last seen ..." with the same relative format used elsewhere; falls back to
  /// "Offline" when the last-seen is unknown.
  String _lastSeenLabel(String? iso) {
    final rel = RelativeTime.fromIso(iso);
    if (rel == null) return StringManager.offline.tr();
    return StringManager.lastSeenAt.tr(namedArgs: {'time': rel});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 18.5.h,
            color: ColorManager.onBrandGradient,
          ),
        ),
        // Avatar opens the quick-view sheet (same UX as the chat list rows),
        // not the full profile directly — matches the unified profile policy.
        // Uses UserImage so users without a picture see their initials avatar
        // (NOT the black app logo) — same image they show everywhere else.
        GestureDetector(
          onTap: () => showContactQuickView(
            context,
            name: params.name,
            image: params.image,
            userId: params.userId,
            hasColorName: params.hasColorName,
            onMessage: () {/* already on this chat */},
          ),
          child: ClipOval(
            child: UserImage(
              image: params.image,
              displayName: params.name,
              imageSize: 40,
            ),
          ),
        ),
        10.wBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientName(child: TextWidget(
                params.name,
                // Fixed white — this sits on the brand-gradient app bar now.
                style: context.bodyMedium.w600
                    .colorExt(ColorManager.onBrandGradient),
              )),
              5.hBox,
              BlocBuilder<UserOnlineBloc, UserOnlineState>(
                bloc: di<UserOnlineBloc>(),
                // Rebuild on both flags: `online` flips the label, `lastSeen`
                // advances as the polled presence refreshes.
                buildWhen: (prev, curr) =>
                prev.online != curr.online ||
                    prev.lastSeen != curr.lastSeen,
                builder: (context, state) {
                  // The shared 30s ticker re-renders the relative "آخر ظهور منذ
                  // N دقيقة" label even when the bloc state is unchanged, so the
                  // header stays current while the chat is open.
                  return ListenableBuilder(
                    listenable: RelativeTimeTicker.instance,
                    builder: (context, _) {
                      return Row(
                        children: [
                          // Container(
                          //   height: 10,
                          //   width: 10,
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     color: state.online == 0
                          //         ? Colors.grey
                          //         : Colors.green.shade800,
                          //   ),
                          // ),
                          // 5.wBox,
                          TextWidget(
                            state.online != 0
                                ? StringManager.online.tr()
                                : _lastSeenLabel(state.lastSeen),
                            isTranslate: false,
                            // Sits on the brand-gradient app bar now: offline uses a
                            // translucent white, online uses a light, high-contrast
                            // green (the old dark green was unreadable on the
                            // gradient).
                            style: context.bodySmall.colorExt(
                              state.online == 0
                                  ? ColorManager.onBrandGradient
                                  .withValues(alpha: 0.75)
                                  : Colors.greenAccent.shade100,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}