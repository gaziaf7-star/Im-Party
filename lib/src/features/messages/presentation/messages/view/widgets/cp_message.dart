part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class CpMessage extends StatelessWidget {
  final String messageId;
  final String message;
  final String userId;
  final String createdAt;
  final ReplayEntity? replay;
  final String messageStatus;
  final String image;
  final bool isLastMessage;

  const CpMessage({
    super.key,
    required this.messageId,
    required this.isLastMessage,
    required this.userId,
    required this.message,
    required this.createdAt,
    required this.image,
    this.replay,
    required this.messageStatus,
  });

  static Map<String, dynamic> _decodePayload(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : const {};
    } catch (_) {
      return const {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = Methods.isMe(userId);

    // Decode the CP payload ONCE per build (not inside the BlocBuilder builder,
    // which re-ran jsonDecode on every CP-bloc emission) and tolerate a bad
    // payload instead of throwing in build.
    final Map<String, dynamic> decoded = _decodePayload(message);
    final originalStatus = decoded["status"].toString();

    return BlocBuilder<GetCpRelationsBloc, CpRelationsStates>(
      bloc: di<GetCpRelationsBloc>(),
      buildWhen: (prev, curr) =>
      prev.updatedMessageStatuses != curr.updatedMessageStatuses ||
          prev.loadingMessageId != curr.loadingMessageId ||
          prev.loadingStatus != curr.loadingStatus,
      builder: (context, state) {
        final updatedStatus = state.updatedMessageStatuses[messageId];
        final currentStatus = updatedStatus ?? originalStatus;
        final isLoading = state.loadingMessageId == messageId;
        final isAcceptLoading = isLoading && state.loadingStatus == '1';
        final isRejectLoading = isLoading && state.loadingStatus == '2';
        return Card(
          color: ColorManager.transparent,
          elevation: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // No per-message avatar in 1:1 chats (groups-only affordance).
              10.wBox,
              Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    width: ScreenUtil().screenWidth * 0.8,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3B1E6B), Color(0xFF1E1040)],
                      ),
                      border: Border.all(
                        color: const Color(0xE6FF8AC2),
                        width: 1.8,
                      ),
                      boxShadow: const [
                        BoxShadow(color: CpPalette.glowPink, blurRadius: 14),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Oversized, faint heart watermark — the "love" motif
                        // behind the content instead of a photo thumbnail.
                        Positioned(
                          right: -18,
                          bottom: -18,
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 110,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        Padding(
                          padding: context.paddingAll(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFFFF8AC2),
                                size: 30,
                              ),
                              8.hBox,
                              Text(
                                overflow: TextOverflow.ellipsis,
                                // Backend currently sends `title: null` on
                                // a fresh CP request payload — confirmed
                                // from a live capture — so fall back to a
                                // fixed label instead of leaving the card
                                // blank.
                                (decoded["title"] as String?)?.isNotEmpty ==
                                        true
                                    ? decoded["title"]
                                    : StringManager.cpRequestTitle.tr(),
                                textAlign: TextAlign.center,
                                style: context.bodyMedium.w800
                                    .colorExt(ColorManager.white),
                              ),

                              // Status: Accepted / Refused
                              if (currentStatus != "0") ...[
                                8.hBox,
                                Container(
                                  padding: context.paddingSymmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: 20.radius,
                                    color: currentStatus == "1"
                                        ? const Color(0x33FF8AC2)
                                        : const Color(0x33FFFFFF),
                                  ),
                                  child: Text(
                                    currentStatus == "1"
                                        ? StringManager.requestAccepted.tr()
                                        : StringManager.requestDenied.tr(),
                                    style: context.bodyMedium.w700
                                        .colorExt(
                                          currentStatus == "1"
                                              ? const Color(0xFFFF8AC2)
                                              : ColorManager.white
                                                  .withValues(alpha: 0.6),
                                        )
                                        .size(12),
                                  ),
                                ),
                              ],

                              // Buttons if not me & status is pending (0)
                              if (!isMe && currentStatus == "0") ...[
                                14.hBox,
                                Row(
                                  children: [
                                    Expanded(
                                      child: MultiTapCard(
                                        onTap: () {
                                          di<GetCpRelationsBloc>().add(
                                            CpRelationRespondEvents(
                                              cpId: decoded["id"].toString(),
                                              status: '1',
                                              messageId: messageId,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 34.h,
                                          decoration: BoxDecoration(
                                            borderRadius: 20.radius,
                                            gradient: const LinearGradient(
                                              colors: CpPalette.accent,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: CpPalette.glowPink,
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: isAcceptLoading
                                                ? const LoadingWidget()
                                                : Text(
                                                    StringManager.accept.tr(),
                                                    style: context.bodyMedium
                                                        .w700
                                                        .colorExt(
                                                            ColorManager
                                                                .white)
                                                        .size(13),
                                                    textAlign:
                                                        TextAlign.center,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    8.wBox,
                                    Expanded(
                                      child: MultiTapCard(
                                        onTap: () {
                                          di<GetCpRelationsBloc>().add(
                                            CpRelationRespondEvents(
                                              cpId: decoded["id"].toString(),
                                              status: '2',
                                              messageId: messageId,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 34.h,
                                          decoration: BoxDecoration(
                                            borderRadius: 20.radius,
                                            color: Colors.white
                                                .withValues(alpha: 0.06),
                                            border: Border.all(
                                              color: CpPalette.surfaceBorder,
                                            ),
                                          ),
                                          child: Center(
                                            child: isRejectLoading
                                                ? const LoadingWidget()
                                                : Text(
                                                    StringManager.refuse.tr(),
                                                    style: context.bodyMedium
                                                        .w700
                                                        .colorExt(ColorManager
                                                            .white
                                                            .withValues(
                                                                alpha: 0.85))
                                                        .size(13),
                                                    textAlign:
                                                        TextAlign.center,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  5.hBox,
                ],
              ),
              // No per-message avatar in 1:1 chats (groups-only affordance).
              10.wBox,
            ],
          ),
        );
      },
    );
  }
}