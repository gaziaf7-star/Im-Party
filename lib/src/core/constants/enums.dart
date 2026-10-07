enum RequestState { idle, loading, loaded, error, offline, empty, ban_user }

enum LanguageType { ar, en, tr, ur, hi, id }

enum OverlyType { error, success, warning }

enum MallOrBagType {
  gift,
  frame,
  intro,
  extra,
  emoji,
  banner,
  bubble,
  vip,
  specialId,
  profileFrame
}

enum TypeGetRooms {
  interests,
  global,
  popular,
  following,
  friends,
  lastCreate,
  follow
}

enum RankingType { daily, weekly, monthly }

enum RelationType {
  following,
  friends,
  followers,
  visitors,
  profile,
  friendsRequest,
  reels,
}

enum GenderType { none, male, female }

enum MomentType { follow, recommend, latest, myMoment }

enum ReelsType { following, forYou, myReels }

enum OtpType {
  register,
  resetPassword,
  verifyOldPhone,
  verifyNewPhone,
  passwordChange,
  bindAccount,
}

enum SavedData {
  addInfo,
  resetPassword,
}

enum TypesCache {
  gift,
  frame,
  intro,
  extra,
  emojie,
  banner,
  color,
  wabbles,
  badges,
  bubble,
  games,
  boom,
  boomTheme,
}

enum MessageState { loading, sent, sending, error, none }

enum ShowGiftType { svga, mp4, alpha, vap, image }

// enum TypeGift { normal, lucky, spical, famous, country, event, vip, bag }

enum TypeCandy { non, luckyCandy, normalCandy }

enum CommentInRoomType {
  normal,
  game,
  dicGame,
  rpsGame,
  luckyDrawGame,
  spinGame,
  dicGameResult,
  rpsGameResult,
  luckyGiftComment,
  luckyNumGame,
}

enum MDIndicatorSize { full, normal, tiny }

enum CountdownType { daily, weekly, monthly }

enum MusicAction {
  play,
  resume,
  pause,
  repeat,
  kill,
  volume,
  seekTo,
  playerExit
}

enum TypeLuckyBox { normalBox, superBox }

class TypeGift {
  final String value;

  const TypeGift._(this.value);

  static const normal = TypeGift._('normal');
  static const lucky = TypeGift._('lucky_gift');
  static const spical = TypeGift._('spical_gift');
  static const famous = TypeGift._('famous');
  static const country = TypeGift._('country');
  static const event = TypeGift._('event');
  static const vip = TypeGift._('vip');
  static const bag = TypeGift._('bag');
  static const cp = TypeGift._('cp');

  static TypeGift fromString(String type) {
    switch (type) {
      case 'normal':
        return normal;
      case 'lucky_gift':
        return lucky;
      case 'spical_gift':
        return spical;
      case 'famous':
        return famous;
      case 'country':
        return country;
      case 'event':
        return event;
      case 'vip':
        return vip;
      case 'bag':
        return bag;
      case 'cp':
        return cp;
      default:
        return TypeGift._(type);
    }
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is TypeGift && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
