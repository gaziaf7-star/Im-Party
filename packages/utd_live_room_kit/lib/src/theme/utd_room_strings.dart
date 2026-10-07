/// User-facing strings for the package's built-in default UI.
///
/// All labels are defaulted via the [UTDRoomStrings.en] / [UTDRoomStrings.ar]
/// factories, so a consumer never has to supply strings to get a working room.
/// Pass a custom instance (or one of the factories) to `UTDLiveRoomConfig.strings`
/// to translate/relabel without replacing whole widgets.
///
/// [roleChangedTo] is a template that takes an argument.
class UTDRoomStrings {
  // Host moderation of guests (member list / tile actions)
  final String muteUser;
  final String unmuteUser;
  final String kickFromSeat;
  final String inviteToSpeak;

  // Audience / speaker requests
  final String applyToSpeak;
  final String cancelRequest;

  // Live (video) room
  final String goLive;
  final String switchCamera;
  final String guestSlotsFull;
  final String turnCameraOff;
  final String turnCameraOn;

  // Host panels
  final String memberList;
  final String requestQueue;
  final String approve;
  final String reject;
  final String promote;
  final String demote;
  final String ban;
  final String unban;
  final String banManagement;

  // Generic
  final String cancel;
  final String confirm;
  final String retry;
  final String exit;
  final String close;

  // Guest invitations (requests sheet). Optional with English defaults so
  // existing call sites keep compiling; ar() overrides them.
  final String invitePickerTitle;
  final String inviteSomeoneCta;
  final String invitationSent;

  // Feedback / states
  final String actionFailed;
  final String noPendingRequests;
  final String noOtherMembers;
  final String noBans;
  final String emptyChatHint;
  final String connectionFailed;
  final String connectionLost;

  // End of broadcast. Optional with English defaults so existing call sites
  // keep compiling; the host app passes its own localized copy.
  final String liveEndedTitle;
  final String liveEndedMessage;
  final String ok;

  // Templates
  final String Function(String role) roleChangedTo;

  const UTDRoomStrings({
    this.liveEndedTitle = 'The live has ended',
    this.liveEndedMessage = 'The host has ended the live.',
    this.ok = 'OK',
    required this.muteUser,
    required this.unmuteUser,
    required this.kickFromSeat,
    required this.inviteToSpeak,
    required this.applyToSpeak,
    required this.cancelRequest,
    required this.goLive,
    required this.switchCamera,
    required this.guestSlotsFull,
    required this.turnCameraOff,
    required this.turnCameraOn,
    required this.memberList,
    required this.requestQueue,
    required this.approve,
    required this.reject,
    required this.promote,
    required this.demote,
    required this.ban,
    required this.unban,
    required this.banManagement,
    required this.cancel,
    required this.confirm,
    required this.retry,
    required this.exit,
    required this.close,
    required this.actionFailed,
    required this.noPendingRequests,
    required this.noOtherMembers,
    required this.noBans,
    required this.emptyChatHint,
    required this.connectionFailed,
    required this.connectionLost,
    required this.roleChangedTo,
    this.invitePickerTitle = 'Invite to the stage',
    this.inviteSomeoneCta = 'Invite someone to join',
    this.invitationSent = 'Invitation sent',
    this.leaveStage = 'Leave the stage',
    this.kickFromBroadcast = 'Kick out of the broadcast',
    this.serviceNotAvailable = 'Live streaming is not available for this app',
  });

  /// Guest self-action: step down from the stage.
  final String leaveStage;

  /// Host/admin action: remove the user from the broadcast entirely.
  final String kickFromBroadcast;

  /// Shown on the connect-error view when the engine refuses because live
  /// streaming is not activated for the project (a non-ban 403 / forbidden),
  /// as opposed to a transient network failure.
  final String serviceNotAvailable;

  /// English defaults.
  factory UTDRoomStrings.en() => UTDRoomStrings(
        muteUser: 'Mute',
        unmuteUser: 'Unmute',
        kickFromSeat: 'Remove from stage',
        inviteToSpeak: 'Invite to go live',
        applyToSpeak: 'Request to go live',
        cancelRequest: 'Cancel request',
        goLive: 'Go Live',
        switchCamera: 'Flip camera',
        guestSlotsFull: 'All guest tiles are full',
        turnCameraOff: 'Turn off camera',
        turnCameraOn: 'Turn on camera',
        memberList: 'Members',
        requestQueue: 'Requests',
        approve: 'Approve',
        reject: 'Reject',
        promote: 'Make admin',
        demote: 'Remove admin',
        ban: 'Ban',
        unban: 'Unban',
        banManagement: 'Banned users',
        cancel: 'Cancel',
        confirm: 'Confirm',
        retry: 'Retry',
        exit: 'Exit',
        close: 'Close',
        actionFailed: 'Action failed. Please try again.',
        noPendingRequests: 'No pending requests',
        noOtherMembers: 'No other members yet',
        noBans: 'No banned users',
        emptyChatHint: 'Say hello 👋',
        connectionFailed: 'Could not join the room',
        connectionLost: 'Connection lost',
        roleChangedTo: (role) => 'Your role changed to $role',
      );

  /// Arabic defaults.
  factory UTDRoomStrings.ar() => UTDRoomStrings(
        liveEndedTitle: 'انتهى البث المباشر',
        liveEndedMessage: 'قام المضيف بإنهاء البث المباشر.',
        ok: 'حسناً',
        muteUser: 'كتم',
        unmuteUser: 'إلغاء الكتم',
        kickFromSeat: 'إزالة من البث',
        inviteToSpeak: 'دعوة للبث',
        applyToSpeak: 'طلب الانضمام للبث',
        cancelRequest: 'إلغاء الطلب',
        goLive: 'بدء البث',
        switchCamera: 'تبديل الكاميرا',
        guestSlotsFull: 'جميع مقاعد الضيوف ممتلئة',
        turnCameraOff: 'إيقاف الكاميرا',
        turnCameraOn: 'تشغيل الكاميرا',
        memberList: 'الأعضاء',
        requestQueue: 'الطلبات',
        approve: 'قبول',
        reject: 'رفض',
        promote: 'تعيين مشرف',
        demote: 'إزالة الإشراف',
        ban: 'حظر',
        unban: 'إلغاء الحظر',
        banManagement: 'المحظورون',
        cancel: 'إلغاء',
        confirm: 'تأكيد',
        retry: 'إعادة المحاولة',
        exit: 'خروج',
        close: 'إغلاق',
        actionFailed: 'فشل الإجراء. حاول مرة أخرى.',
        noPendingRequests: 'لا توجد طلبات معلّقة',
        noOtherMembers: 'لا يوجد أعضاء آخرون بعد',
        noBans: 'لا يوجد مستخدمون محظورون',
        emptyChatHint: 'ابدأ المحادثة 👋',
        connectionFailed: 'تعذّر الانضمام إلى الغرفة',
        connectionLost: 'انقطع الاتصال',
        serviceNotAvailable: 'البث المباشر غير مفعّل لهذا التطبيق',
        invitePickerTitle: 'دعوة إلى الجست',
        inviteSomeoneCta: 'ادعُ شخصاً إلى الجست',
        invitationSent: 'تم إرسال الدعوة',
        leaveStage: 'النزول من الجست',
        kickFromBroadcast: 'طرد من البث المباشر',
        roleChangedTo: (role) {
          const labels = {
            'host': 'مضيف',
            'admin': 'مشرف',
            'guest': 'متحدث',
            'audience': 'مستمع',
          };
          return 'تم تغيير دورك إلى ${labels[role] ?? role}';
        },
      );
}
