/// Local labels for the redesigned chats screen that don't yet have entries in
/// the shared [StringManager]. These are kept slice-local on purpose; once the
/// i18n keys are added to core they should be migrated to `StringManager.x.tr()`
/// (see central_changes_needed in the slice report).
class ChatStrings {
  ChatStrings._();

  static const String unreadTab = 'Unread';
  static const String newChat = 'New chat';
  static const String newGroup = 'New group';
  static const String chooseFriend = 'Choose a friend';

  // Contact discovery + invite (new-chat picker).
  static const String findFriendsFromContacts =
      'Find your friends from contacts';
  static const String contactsPermissionDenied =
      'Contacts permission denied — tap to retry';
  static const String contactsOnApp = 'Your contacts on the app';
  static const String noContactsOnApp = 'None of your contacts are on the app yet';
  static const String inviteFriendsToApp = 'Invite your friends to the app';
  static const String invite = 'Invite';

  // In-app friends picker (new chat).
  static const String loadingContacts = 'Loading your contacts...';
  static const String friendsOnApp = 'Your friends on the app';
  static const String noFriendsYet = 'You have no friends yet';
  static const String friendsFetchError = 'Could not load your friends';
  static const String inviteFromContacts = 'Invite from contacts';

  // Inline-search fallback (no local conversation matched).
  static const String startNewChat = 'Start a new chat';
  static const String noSearchResults = 'No results';
  static const String searchInContacts = 'Search contacts';

  // Phone-book picker screen (the dedicated contacts screen).
  static const String contacts = 'Contacts';
  static const String tryAgain = 'Try again';
  static const String contactsFetchError = 'Could not load contacts';
  static const String noPhoneContacts = 'No contacts on this device';
  static const String noContactsMatch = 'No results match your search';
  static const String messageAction = 'Chat';

  // Group profile screen (members header).
  static const String youBadge = 'You';
  static const String myPhoneLabel = 'My phone number';
}
