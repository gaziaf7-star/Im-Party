/// User-facing strings for the package's built-in default UI.
///
/// All labels are defaulted via the [UTDRoomStrings.en] / [UTDRoomStrings.ar]
/// factories, so a consumer never has to supply strings to get a working room.
/// Pass a custom instance (or one of the factories) to `UTDAudioRoomConfig.strings`
/// to translate/relabel without replacing whole widgets.
///
/// A few entries are templates that take an argument — these are functions
/// (e.g. [seatNumber], [invitedToSeat], [roleChangedTo]).
class UTDRoomStrings {
  // Seat actions
  final String takeSeat;
  final String switchSeat;
  final String leaveSeat;
  final String stepDown;
  final String lockSeat;
  final String unlockSeat;
  final String muteUser;
  final String unmuteUser;
  final String kickFromSeat;
  final String inviteToSpeak;

  // Audience / speaker requests
  final String applyToSpeak;
  final String cancelRequest;
  final String requestSent;

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

  // Feedback / states
  final String seatLocked;
  final String seatReserved;
  final String actionFailed;
  final String noPendingRequests;
  final String noOtherMembers;
  final String noBans;
  final String emptyChatHint;
  final String connectionFailed;
  final String connectionLost;

  /// Shown on the connect-error view when the engine refuses because audio rooms
  /// are not activated for the project (a non-ban 403 / forbidden), as opposed to
  /// a transient network failure.
  final String serviceNotAvailable;

  // Confirm dialogs
  final String leaveSeatTitle;
  final String leaveSeatBody;
  final String stepDownTitle;
  final String stepDownBody;

  // Templates
  final String Function(int seatNumber) seatNumber;
  final String Function(String name, int seatNumber) invitedToSeat;
  final String Function(String role) roleChangedTo;

  /// Room-chat system line shown when [name] is promoted to admin.
  final String Function(String name) becameAdmin;

  /// Room-chat system line shown when [name] loses the admin role.
  final String Function(String name) removedFromAdmins;

  // Comment lock
  /// Shown in place of the composer when chat is locked and the local user
  /// (guest/audience/visitor) may not comment.
  final String commentsLocked;

  /// Host/admin control label/tooltip to lock comments.
  final String lockComments;

  /// Host/admin control label/tooltip to unlock comments.
  final String unlockComments;

  /// Room-chat system line posted when the host locks comments.
  final String commentsLockedAnnouncement;

  /// Room-chat system line posted when the host unlocks comments.
  final String commentsUnlockedAnnouncement;

  const UTDRoomStrings({
    required this.takeSeat,
    required this.switchSeat,
    required this.leaveSeat,
    required this.stepDown,
    required this.lockSeat,
    required this.unlockSeat,
    required this.muteUser,
    required this.unmuteUser,
    required this.kickFromSeat,
    required this.inviteToSpeak,
    required this.applyToSpeak,
    required this.cancelRequest,
    required this.requestSent,
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
    required this.seatLocked,
    required this.seatReserved,
    required this.actionFailed,
    required this.noPendingRequests,
    required this.noOtherMembers,
    required this.noBans,
    required this.emptyChatHint,
    required this.connectionFailed,
    required this.connectionLost,
    required this.leaveSeatTitle,
    required this.leaveSeatBody,
    required this.stepDownTitle,
    required this.stepDownBody,
    required this.seatNumber,
    required this.invitedToSeat,
    required this.roleChangedTo,
    // Optional (English defaults) so existing callers constructing
    // [UTDRoomStrings] directly don't break when these are added.
    this.becameAdmin = _enBecameAdmin,
    this.removedFromAdmins = _enRemovedFromAdmins,
    this.commentsLocked = 'Comments are locked by the host',
    this.lockComments = 'Lock comments',
    this.unlockComments = 'Unlock comments',
    this.commentsLockedAnnouncement = '🔒 Comments locked by the host',
    this.commentsUnlockedAnnouncement = '🔓 Comments unlocked',
    this.serviceNotAvailable = 'Audio rooms are not available for this app',
  });

  static String _enBecameAdmin(String name) => '$name became an admin';
  static String _enRemovedFromAdmins(String name) =>
      '$name was removed from admins';

  /// English defaults.
  factory UTDRoomStrings.en() => UTDRoomStrings(
        takeSeat: 'Take seat',
        switchSeat: 'Switch to this seat',
        leaveSeat: 'Leave seat',
        stepDown: 'Step down',
        lockSeat: 'Lock seat',
        unlockSeat: 'Unlock seat',
        muteUser: 'Mute',
        unmuteUser: 'Unmute',
        kickFromSeat: 'Remove from seat',
        inviteToSpeak: 'Invite to speak',
        applyToSpeak: 'Apply to speak',
        cancelRequest: 'Cancel request',
        requestSent: 'Request sent',
        memberList: 'Members',
        requestQueue: 'Speak requests',
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
        seatLocked: 'This seat is locked',
        seatReserved: 'This seat is reserved',
        actionFailed: 'Action failed. Please try again.',
        noPendingRequests: 'No pending requests',
        noOtherMembers: 'No other members yet',
        noBans: 'No banned users',
        emptyChatHint: 'Say hello 👋',
        connectionFailed: 'Could not join the room',
        connectionLost: 'Connection lost',
        leaveSeatTitle: 'Leave seat?',
        leaveSeatBody: 'You will leave your seat and stop speaking.',
        stepDownTitle: 'Step down?',
        stepDownBody: 'You will leave the host seat.',
        seatNumber: (n) => 'Seat ${n + 1}',
        invitedToSeat: (name, n) =>
            '$name invited you to sit on seat #${n + 1}',
        roleChangedTo: (role) => 'Your role changed to $role',
        becameAdmin: (name) => '$name became an admin',
        removedFromAdmins: (name) => '$name was removed from admins',
        commentsLocked: 'Comments are locked by the host',
        lockComments: 'Lock comments',
        unlockComments: 'Unlock comments',
        commentsLockedAnnouncement: '🔒 Comments locked by the host',
        commentsUnlockedAnnouncement: '🔓 Comments unlocked',
      );

  /// Arabic defaults.
  factory UTDRoomStrings.ar() => UTDRoomStrings(
        takeSeat: 'الجلوس على الكرسي',
        switchSeat: 'الانتقال إلى هذا الكرسي',
        leaveSeat: 'مغادرة الكرسي',
        stepDown: 'النزول من الكرسي',
        lockSeat: 'قفل الكرسي',
        unlockSeat: 'فتح الكرسي',
        muteUser: 'كتم',
        unmuteUser: 'إلغاء الكتم',
        kickFromSeat: 'إزالة من الكرسي',
        inviteToSpeak: 'دعوة للتحدث',
        applyToSpeak: 'طلب التحدث',
        cancelRequest: 'إلغاء الطلب',
        requestSent: 'تم إرسال الطلب',
        memberList: 'الأعضاء',
        requestQueue: 'طلبات التحدث',
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
        seatLocked: 'هذا الكرسي مقفل',
        seatReserved: 'هذا الكرسي محجوز',
        actionFailed: 'فشل الإجراء. حاول مرة أخرى.',
        noPendingRequests: 'لا توجد طلبات معلّقة',
        noOtherMembers: 'لا يوجد أعضاء آخرون بعد',
        noBans: 'لا يوجد مستخدمون محظورون',
        emptyChatHint: 'ابدأ المحادثة 👋',
        connectionFailed: 'تعذّر الانضمام إلى الغرفة',
        connectionLost: 'انقطع الاتصال',
        serviceNotAvailable: 'غرف الصوت غير مفعّلة لهذا التطبيق',
        leaveSeatTitle: 'مغادرة الكرسي؟',
        leaveSeatBody: 'سوف تغادر الكرسي وتتوقف عن التحدث.',
        stepDownTitle: 'النزول من الكرسي؟',
        stepDownBody: 'سوف تغادر كرسي المضيف.',
        seatNumber: (n) => 'الكرسي ${n + 1}',
        invitedToSeat: (name, n) => 'دعاك $name للجلوس على الكرسي رقم ${n + 1}',
        roleChangedTo: (role) {
          const labels = {
            'host': 'مضيف',
            'admin': 'مشرف',
            'guest': 'متحدث',
            'audience': 'مستمع',
          };
          return 'تم تغيير دورك إلى ${labels[role] ?? role}';
        },
        becameAdmin: (name) => 'أصبح $name مشرفًا',
        removedFromAdmins: (name) => 'تمت إزالة $name من المشرفين',
        commentsLocked: 'التعليقات مقفلة من قبل المضيف',
        lockComments: 'قفل التعليقات',
        unlockComments: 'فتح التعليقات',
        commentsLockedAnnouncement: '🔒 تم قفل التعليقات من قبل المضيف',
        commentsUnlockedAnnouncement: '🔓 تم فتح التعليقات',
      );
}
