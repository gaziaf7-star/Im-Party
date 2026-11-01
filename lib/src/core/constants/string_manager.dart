import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class StringManager {
  const StringManager._();

  static const int versionApp = 17;
  static const String versionAppName = "Version 1.0.15+17";
  static const String android = 'Android';
  static const String huawei = 'Huawei';
  static const String ios = 'IOS';

  static const String liveBanned = 'The Live is banned';
  static const String modeIsChanging = 'Mode is changing, please wait';
  static const String liveStreamingNotAvailable =
      'Live streaming is not available at this time';

  static const String got = 'Got';
  static const String turn = 'Return';

  static const String times = 'Times';
  static const String currentLevelIs = 'The Current Level Is';
  static const String andNextLevelIs = 'And The Next Level Is';
  static const String searchMusic = 'Search music...';

  static const String appUnderDevelopment = 'The app is under development';
  static const String livePaused = 'Live Paused';
  static const String theCreatorWillBeBackSoon =
      'The creator will be back soon';
  static const String unMute = "UnMute";
  static const String mute = "Mute";
  static const String beauty = "Beauty";
  static const String youAlreadySentRequest = "you already sent a request";
  static const String requestSent = "Request sent to the host";

  static const String invitToLive = "Invitation To Stream";
  static const String load = "Load";
  static const String leaveRoom = "Quit live stream";
  static const String leaveRoomHint =
      "Are you sure you want to end your live stream, this will put an end to all your live activities?";
  static const String loadingHint =
      "(Minimizing the content will interrupt the loading)";
  static const String liveHostInvite =
      "Host Invite You To Start Stream With Him";
  static const String rejectedrequest = "Your request were rejected";
  static const String newrequest = "New Request";
  static const String sendMessage = "Say Hi";
  static const String userAudioRoom = "User Audio Room";
  static const String userLiveRoom = "User Live Room";
  static const String hostDisabledTheComments =
      "The host has disabled the comments";
  static const String youDisabledTheComments =
      "you have disabled the comments, open it first";
  static const String unMuteUser = "UnMute User";
  static const String inviteGuest = "Invit A Guest";
  static const String youInvitedHim = "you already invited this user";
  static const String myMusic = "My Music";
  static const String free = 'Free';
  static const String enterRoom2 = 'Enter Room';
  static const String openPk = 'Open PK';
  static const String areYouSureEnterRoom =
      'Are you sure you want to enter this room?';
  static const String liveBroadcast = 'Live broadcast';
  static const String goToRoomQuestion =
      'Do you want to go to the room «{name}»?';
  static const String goToRoomQuestionNoName =
      'Do you want to go to the room?';
  static const String goToLiveQuestion =
      'Do you want to go to the live broadcast «{name}»?';
  static const String goToLiveQuestionNoName =
      'Do you want to go to the live broadcast?';

  static const String enterCode = 'Enter Code';
  static const String enterInvitationCode =
      'Please enter the friend invitation code to rerceive the reward immediately!';
  static const String receiveAward = 'Receive Award';
  static const String enterValidCode = 'Enter a valid code';
  static const String fillInInvitationCode = 'Invitation Code';
  static const String yourInvitationCode = 'Your Invitation Code';
  static const String invitationHint =
      'Friends can fill in the invitation code to bind the inviter within 3 days after rerdistration.';
  static const String congratulationsYouWin = 'Congratulations You Win';
  static const String superBoomHint =
      'The rewards here are for reference only. The specific gifts are determined by the contribution and luck of the super bomb.';
  static const String allSeats = 'All Seats';
  static const String youAreRemovedFromRoomAdmins =
      'You are removed from room admins';
  static const String roomDeleted = 'Room Deleted';
  static const String userHasAntiBan = 'User has anti-ban';
  static const String whatsAppNotInstalled =
      'Please make sure you have WhatsApp installed on your device.';
  static const String fontFamily = 'AppFont';
  static const String maxLengthExceeded = 'Max length exceeded';
  static String get addMoment =>
      ConstantsManager.isTheme2 ? 'Post News' : 'Post Moment';
  static const String postUpdates = 'Post updates';
  static const String lastActive = "Last Active: ";
  static const String mention = 'Mention';
  static const String wesam = 'Medal';
  static String get enterContent =>
      ConstantsManager.isTheme2
          ? 'Enter the content your news'
          : 'Enter the content your moment';
  static const String theContent = 'The content';
  static const String explainProblem = 'Explain Your Problem';
  static const String uploadRoomImage = 'Upload room’s  picture';
  static const String enterSecretNumber =
      'No new participants will be able to join.';
  static const String relationSpecial = "Special Relationships";
  static const String goRecharge = "No enough coins go recharge";
  static const String luckyCostPerSend = "Cost per send";
  static const String noUsersSelected = "Please select at least one user.";
  static const String noGiftSelected = "You haven’t chosen any gift.";
  static const String otherUserIsPlayingMusic = 'Other user is playing music';
  static const String lastTimeCacheGift = 'last_time_cache_gift';
  static const String lastTimeCacheEntro = 'last_time_cache_entro';
  static const String lastTimeCacheFrame = 'last_time_cache_gift_frame';
  static const String lastTimeCacheExtra = 'last_time_cache_Extra';
  static const String lastTimeCacheEmojie = 'last_time_cache_Emojie';
  static const String lastTimeCacheBanner = 'last_time_cache_Banner';
  static const String lastTimeCacheBoomTheme = 'last_time_cache_boom_theme';
  static const String lastTimeCacheSuperBoomVideos =
      'last_time_cache_SuperBoomVideos';
  static const String lastTimeCacheColors = 'last_time_cache_colors';
  static const String lastTimeWabbles = 'last_time_cache_Wabbles';
  static const String lastTimeBubbles = 'last_time_cache_bubbles';
  static const String lastTimeAgencyBadges = 'last_time_cache_agency_badges';
  static const String lastTimeCacheGames = 'last_time_cache_games';
  static const String specialBar = 'Special Bar';
  static const String enterTheRoom = 'Enter The Room';
  static const String noCommentFound = 'No Comments Found';
  static const String noLikesFound = 'No Likes Found';

  //new ui
  static const String resetCharisma = "Reset Charisma";
  static const String charisma = "Charisma";
  static const String sessionExpired =
      "Your session has expired. Please login again with this account";
  static const String tabToAddVideo = "Tab to add video";
  static const String youHaveReachedLimitMessages =
      "You have reached the limit for sending messages";
  static const String cinemaMode = "Cinema Mode";
  static const String messageLimit = "Message must be less than 255 characters";
  static const String quickGame = "Quick game";
  static const String sure = "Sure";
  static const String empty = "Empty";
  static const String swipeRight = "Swipe right if you like.";
  static const String seeProfile = "See Profile";
  static const String trendingTab = "Trending";
  static const String searchOnYouTube = "1-search on video on YouTube";
  static const String pressOnVideo = "2-Press on video which you need watch it";
  static const String everyOneWatchWithYou = "3-every one watch with you";
  static const String ownerCanSwitchVideo = "4-owner can switch video";
  static const String switchCamera = "Switch camera";
  static const String cinemaModeHint =
      'To open cinema mode you must agree on YouTube terms and conditions first';
  static const String cinemaModeHint2 =
      'Accept terms and conditions for YouTube';
  static const String cantOpenCinemaMode =
      'can\'t open cinema mode close pk first';
  static const String cantSave = 'You Can\'t Save Room PK is Running';
  static const String youCantSaveRoomBecauseCinemaMode =
      'You can\'t save the room with cinema on mode';

  static const String pickMedals =
      "The maximum number of medals you can choose is 10";
  static String get broadcastYourMoment =>
      ConstantsManager.isTheme2
          ? "Broadcast your news with the world and spread happiness"
          : "Broadcast your moment with the world and spread happiness";
  static const String chargeMedals = "Charge Medals";

  static const String roomBadge = "Room Badge";
  static const String achievementBadge = "Achievement Badge";
  static const String specialBadge = "Special Badge";
  static const String giftBadge = "Gift Badge";
  static const String haveRead = "Sign in to agree";
  static const String acceptTerms = 'Please accept Terms and Conditions';
  static const String notification = 'System Notifications';
  static const String rewardMessage = 'Reward Message';
  static const String operateMessage = 'Operate Message';
  static const String giftMedals = "Gift Medals";
  static const String entertainmentTools = "Entertainment Tools";
  static const String entertainment = "Entertainment";
  static const String personal = "Personal";
  static const String withValue = "with";
  static String get noMomentsFound =>
      ConstantsManager.isTheme2 ? "No news found" : "No moments found";
  static String get noMomentsFoundSubTitle =>
      ConstantsManager.isTheme2
          ? "No news now. try again!"
          : "No moments now. try again!";
  static const String roomType = "Room Type";
  static const String countDown = "Count Down:";
  static const String selectRoomType = "Please enter the room type";
  static const String achievements = "Madel";
  static const String pickedAchievements = "Picked Achievements";
  static const String roomManager = 'Room Manager';
  static const String liveManager = 'Live Manager';

  static const String event = "Event";
  static const String medals = "Medals";
  static const String noName = "No name";
  static const String myMedal = "My Medal";
  static const String myBadge = "My Badge";
  static const String myRoomBadge = "My Room Badge";
  static const String aristocracy = "Aristocracy";
  /// Our name for the top membership tier. The vendor called it
  /// "Aristocracy"; this brand uses SVIP.
  static const String svip = "SVIP";
  static const String honor = "Honor";
  static const String activity = "Activity";
  static const String achievement = "Achieve";
  static const String connect = "Connect";
  static const String privileges = "Level Privileges";
  static const String toBeOpened = "To be opened";
  static const String vipProblem = " VIP Problem";
  static const String diceGame = "Dice";
  static const String recent = "Recent";
  static const String luckyNumber = "lucky number";
  static const String orderOfValidity = " Order of validity";
  static const String noAchievements = " No Achievements found !!";
  static const String noAchievementSubtitle =
      "Visit the achievement center in onother time";
  static const String worldChatMessage = "World Chat Message notification";
  static const String sendWorldChat = "Send World Chat";
  static const String worldChat = "World Chat";
  static const String give = "Give";
  static const String keep = "Keep";
  static const String submit = "Submit";
  static String get moment => ConstantsManager.isTheme2 ? "News" : "Moment";
  static const String reels = "Reels";

  /// The "everything else" tab on a profile — bio, honours, relations.
  static const String profileGeneral = "General";
  static const String meet = "Meet";

  static const String porn = "Porn";
  static const String bullying = "Bullying";
  static const String violence = "Violence";
  static const String profilePic = "Profile pictures";
  static const String changeProfilephoto = "Change profile photo";

  ///auth
  static const String improveTheInfo = "HI, welcome to $appName";
  static const String improveTheInfo2 =
      "Improve information to match accurate friends~";
  static const String userName = "Name";
  static const String enterName = "Enter you First Name";
  static const String muteUser = "Mute User";
  static const String removeUser = "Remove User";
  static const String days = "Days";
  static const String youHaveInvitationToMic = "You have invitation to mic ?";
  static const String invite = "Invite";
  static const String inviteFriend = "Invite friends turn on the mic";
  static const String inviteFriends = "Invite friends";
  static const String invitationToMic = "Invitation to mic";
  static const String inviteToTheMic = "Invite to the mic";
  static const String closePkFirst = "Close PK first";
  static const String closeCharisma = "Close charisma first";
  static const String lockComments = "Lock Comments";
  static const String unlockComments = "Unlock Comments";
  static const String closeCinemaMode = "Close cinema mode first";
  static const String thisFeatureCommingSoon =
      "This feature is comming soon ..";
  static const String commingSoon = "Comming Soon";
  static const String myBackground = "My Background";
  static const String exit = "Exit";
  static const String exitRoom = "Exit Room";
  static const String areYouSureToEndLive =
      "Are you sure you want to end your live stream, this will put an end to all your live activities?";
  static const String muteRoom = "Mute Room";
  static const String removeMute = "Remove Mute";
  static const String micOn = "Take Mic";
  static const String micOff = "Un Mute";
  static const String remove = "Remove";
  static const String roomBlockList = "Room block list";
  static const String basicSetting = "Basic Settings";
  static const String basicTools = "Basic Tools";
  static const String jobSettings = "Job Settings";
  static const String unLockRoom = "UnLock Room";
  static const String unLockRoomMsg =
      "remove password from this room.by unlock room  any user can enter this room ";
  static const String otherSettings = "Other Settings";
  static const String effect = "Effect";
  static const String carEffect = "Car effect";
  static const String application = "Application";
  static const String roomSettings = "Room Settings";
  static const String minimize = "Minimize";
  static const String share = "Share";
  static const String roomOwner = "Room Owner";
  static const String roomInformation = "Room Information";
  static const String onlineList = "Online List";
  static const String roomVisitor = "Room Visitor";
  static const String enterANickname = "Enter a nickname";
  static const String username = " Enter your username";
  static const String verify = "Verification";
  static const String confirmPassword = "Confirm Password";
  static const String requiredField = "The field is required.";
  static const String passwordConfirmation = "The two field is not equal.";
  static const String agreeTerms = "Terms and condition";
  static const String codeSent = "The confirmation code has been sent";
  static const String whatsappCheck =
      "We have sent the code via SMS to ";
  static const String skip = 'Skip';
  static const String personalImage = 'Personal Image';
  static const String addInfoSubtitle =
      'please choose your Personal Image and you can skip if you want';

  static const String addInfoRoomSubtitle = 'Please choose your room image';
  static const String addLiveImage = 'Please choose your live image';
  static const String addRoomData = 'Please complete room data';
  static const String id = "ID";
  static const String login = "Login";
  static const String logOut = "Log out";
  static const String logOutDescribe = "Are you sure you want to sign out?";
  static const String clearCache = "Clear cache";
  static const String clearCacheDesc = "Clear temporary files and cached images";

  // App Settings
  static const String appSettings = "App Settings";
  static const String micBackgroundDialogTitle = "Running app in background";
  static const String micBackgroundDialogQuestion =
      "Do you want to use other apps while you're in the room?";
  static const String micBackgroundDialogExplanation =
      "Yes: Your voice will be temporarily muted until you return to the app, allowing you to use audio in other apps.\nNo: Your voice will remain audible in the room even if you leave the app.";
  static const String muteMicInBackground = "Mute microphone in background";
  static const String muteMicInBackgroundDescription =
      "When enabled, your microphone will be muted when you leave the app or enter PiP mode.\nWhen disabled, your microphone will remain active even when you leave the app or enter PiP mode.";

  static const String deleteDescribe =
      "Are you sure you want to delete account?";
  static const String rememberMe = "Remember me";
  static const String recoverPassword = "Forgot Password";
  static const String recoverPassword_ = "Forgot password";
  static const String loginTitle = "Log in ";
  static const String dataSaved = "All Data Saved";
  static const String next = "Next";
  static const String boy = "Boy";
  static const String girl = "Girl";
  static const String userUnder18 =
      "sorry you can't use this app because you are Under 18";
  static const String pickImage = "sorry you have to pick image";
  static const String getStarted = "Get Started";

  // reels
  static const String shareToMyFriends = "Share To My Friends";

  ///home
  static const String rooms = "Rooms";
  static const String chat = "Chat";
  static const String watsJo = "Chat";
  static const String profile = "Profile";
  static const String home = "Home";
  static const String myRoom = "My Room";
  static const String my = "My";
  static const String mine = "Mine";
  static const String me = "Me";
  static const String hot = "Hot";
  static const String nearby = "Nearby";
  static const String trend = "Trend";
  static const String discover = "Discover";
  static const String party = "Party";
  static const String ludo = "Ludo";
  static const String cP = "CP";
  static const String cpSpace = "CP space";
  static const String rank = "Rank";
  static const String cpRank = "CP Ranking";
  static const String cpRankLastWeek = "cp ranking last week";
  static const String ranking = "Ranking";
  static const String families = "Families";
  static const String popular = "Popular";
  static const String global = "Global";
  static const String pleaseComment = "Tell me what you think";
  static const String welcomeRoom = "Welcome in my room ..";
  static const String enjoyLiveRoom =
      "Enjoy the wonderful journey of Baby Cat Chat";
  static const String new_ = "New";
  static const String seeMore = "See more";
  static const String seeLess = "See less";
  static const String nextTo = "To next level";
  static const String personalProfile = "Personal Profile";
  static const String personalInformation = "Personal Information";
  static const String basicInformation = "Basic information";
  static const String coverPhoto = "Cover photo";
  static const String life = "Life";
  static const String travel = "Travel";
  static const String personalInformationIntro =
      "Welcome Back, (Host/Broadcaster)!\n\nUpdate your personal information to ensure a seamless experience on our globally recognized, high-quality live streaming platform.\nPlease provide accurate and up-to-date details.";
  static const String paymentMethod = "Payment Method";
  static const String cashApp = "Cash App";
  static const String stripe = "Stripe";
  static const String googlePlay = "Google Play";
  static const String zelle = "Zelle";
  static const String appStore = "App Store";
  static const String usdt = "USDT";
  static const String specialId = "Special Id";
  static const String profileFrame = "Profile Card";
  static const String send = "Send";
  static const String post = "Post";
  static const String postBy = "Posted by";
  static const String wallet = "Wallet";
  static const String exchange = "Exchange";
  static const String select = "Select";
  static const String selectAll = 'Select All';

  static const String selectGender = "Please select your gender";
  static const String balance = "Balance";
  static const String to = "to";
  static const String forText = "For";
  static const String completeYourProcess = 'Complete your process';
  static const String completeYourInfoData = 'Please complete information';
  static const String youWillExchange = "You will exchange";
  static const String youWillRech = "You will recharge";
  static const String thisImageWillCost = "This image will cost ";

  static String youWillEx({required String coin, required String dimond}) =>
      "${youWillExchange.tr()} $dimond ${diamond.tr()} ${to.tr()} $coin ${coins.tr()}";

  static String youWillRecharge({
    required String coin,
    required String price,
  }) => "${youWillRech.tr()} $coin ${coins.tr()} ${forText.tr()} $price\$";
  static const String confirmation = "Confirmation";
  static const String pleaseSelect = "Please Select Item";
  static const String change = "Change";
  static const String exchangeDiamondWarning =
      "You Can Not Exchange Diamonds Because Your Are a Host";
  static const String versionNumber = "1.0.0";
  static const String addImage = "Add Image";
  static const String addImageCountry =
      "Complete your incomplete information in your profile, enjoy a more personalized and efficient experience!";
  static const String addPicture = "Add Picture";
  static const String addImages = "Add Images";
  static const String add = "Add";
  static const String addMusic = "Add music";
  static const String contactDetails = "Contact details";
  static const String phone = "Phone number";
  static const String phoneOnly = "Phone";
  static const String whatsapp = "WhatsApp Number";
  static const String noTheme = "No Theme Now";
  static const String noThemeSubTitle =
      "No Theme Now Please Try Again Later...";
  static const String aristocracyPrivileges = "Aristocracy Privileges";
  static const String readAndAcceptToDeleteAccount =
      "I have understood all the consequences. Are you sure you want to delete the account?";
  static const String pleaseAcceptYoDeletion = "Please accept your deletion";
  static const String tittleDescriptionDeleteAccount =
      "Before deleting your account, please read the following important reminders carefully. After the account is deleted, you will no longer be able to use the account, including but not limited to:";
  static const String descriptionDeleteAccount1 =
      "(1).To protect your using rights of remaining services, after the account is deleted, your account data will be reserved for 60 days";
  static const String descriptionDeleteAccount2 =
      "(2).When all data cleared, you will not be able to log in and use Binmo, and you will not be able to retrieve any personal information.";
  static const String descriptionDeleteAccount3 =
      "(3).The account will be released from the binding or authorization relationship with other products, and cannot be retrieved.";
  static const String descriptionDeleteAccount4 =
      "(4).After the account is deleted, your assets and various paid rights and interests in the App will be cleared, including the rights and interests that have been generated but not consumed or expected rights in the future";
  static const String descriptionDeleteAccount5 =
      "(5).The deletion of your Binmo account does not mean that your account behavior and related responsibilities before the deletion are exempted or mitigated.";

  //handele data
  static const String noPreviewAvailable = "No preview available for this item";
  static const String tittleEmptyFrame = "No frames now !!";
  static const String pleaseSelect3Items = "Please select just three items!";
  static const String subTittleEmptyFrame =
      "no available frames now please try again later...";
  static const String tittleEmptyIntro = "No intro now !!";
  static const String subTittleEmptyIntro =
      "no available intro now please try again later...";
  static const String tittleEmptySpecialId = "No Special Id now !!";
  static const String subTittleEmptySpecialId =
      "no available Special Id now please try again later...";
  static const String tittleEmptyProfileFrame = "No Profile Card now !!";
  static const String subTittleEmptyProfileFrame =
      "no available Profile Card now please try again later...";
  static const String enjoyMoreThan = "enjoy more than ";
  static const String privilegesPart = " privileges";
  static const String registration = "Registration";
  static const String registerNow = "Register now";
  static const String receivingAndGifting = "Receiving and Gifting";

  static const String exclusiveStatusBadgeFor = "Exclusive Status Badge for";
  static const String specialEntryEffects = "Special Entry Effects";
  static const String soundWave = "Sound Wave For";

  static const String noAdmins = "No admins in room now !!";
  static const String noAdminsLive = "No admins in live now !!";
  static const String addAdminsNow = "Add admins now";
  static const String streamDetails = "Stream details";
  static const String streamSettings = "Stream settings";
  static const String streamNameLabel = "Stream name";
  static const String streamIntro = "Stream intro";
  static const String streamCover = "Stream cover";
  static const String streamOwner = "Stream host";
  static const String viewersLabel = "Viewers";
  static const String tapToJoin = "Tap to join";
  static const String shareLiveTitle = "Share live stream";
  static const String recentChats = "Recent chats";
  static const String maxFiveChats = "You can select up to 5 chats";
  static const String externalShare = "Share externally";
  static const String liveAudienceNow = "In the stream now";
  static const String noAdminsAgency = "No admins";
  static const String noAdminsEmptySubTitle =
      "No admins in room now please try again later...";
  static const String noAdminsEmptySubTitleLive =
      "No admins in live now please try again later...";
  static const String noOne = "No one with this ID !!";
  static const String noOneEmptySubTitle =
      "No one with this ID, now please try again later...";

  static const String toGetDailyPrize = "To get a 7-day login bonus";
  static const String dailyAttendance = "Daily Attendance";
  static const String youSignIn = "You sign in";

  static String youSignInDay({required String day}) =>
      "${youHaveChecked.tr()} $day ${days.tr()}";
  static const String youGetYourPrizeSuccess = "You get your prize success";
  static const String dailyRank = "Daily Rank";
  static const String hourly = "Hourly";
  static const String daily = "Daily";
  static const String weekly = "Weekly";
  static const String lucky = "Lucky Gift";
  static const String wealth = "Wealth";
  static const String wealthStar = "Wealth Star";
  static const String charm = "Charm";
  static const String charmStar = "Charm Star";
  static const String monthly = "Monthly";
  static const String room = "Room";
  static const String roomStar = "Room Star";
  static const String randomRoom = "Random Room";
  static const String rich = "Rich";
  static const String attractiveness = "Attractiveness";
  static const String minute = "minute";

  static String bloc({required String durationKickout}) =>
      "${youblockedFromRoom.tr()} $durationKickout ${minute.tr()}";

  static String getTime({required String reming}) =>
      "${youCanEnterAfter.tr()} $reming";
  static const String youCanEnterAfter =
      "You have been kicked out of this ROM, you may log in yet";

  static const String fiveMin = '5 minute ';
  static const String fiftyMin = '15 minute';
  static const String thirtyMin = '30 minute';
  static const String sixtyMin = '60 minute';
  static const String twenyFourMin = '24 hour';
  // Timed-kick durations (طرد) — ordered low→high.
  static const String oneMin = '1 minute';
  static const String threeMin = '3 minute';
  static const String tenMin = '10 minute';
  static const String youAreNotFriends = "You are not friends.";
  static const String block = "Block";
  // Timed kick (طرد): removes for a duration; room stays in the target's home.
  static const String kick = "Kick";
  // Permanent ban (حظر): hides the room from the target's home + blocks re-entry.
  static const String ban = "Ban";
  static const String userKicked = "User kicked";
  static const String confirmBanUser = "Ban this user permanently from the room?";
  static const String adminAssigned = "Admin assigned";
  static const String kickedFromRoomTitle = "You were kicked from this room";
  static const String bannedFromRoomMessage = "You are banned from this room";
  static const String canEnterAfter = "You can enter after";
  // UTD-Stream Engine ban feature
  static const String bannedUsers = "Banned Users";
  static const String banReason = "Reason";
  static const String permanent = "Permanent";
  static const String globalBan = "Global";
  static const String userBanned = "User banned";
  static const String userUnbanned = "Ban removed";
  static const String noBannedUsers = "No banned users";
  // UTD-Stream Engine mute feature
  static const String userMuted = "User muted";
  static const String userUnmuted = "User unmuted";
  static const String somethingWrong = "Something Wrong";
  static const String areYouSureBlock =
      "Are you sure you want to block this Person?";
  static const String youblockedFromRoom =
      "You have been kicked out of this room";
  static const String chooseYourWithdrawalMethod =
      "Choose your withdrawal method";
  static const String gift = "Gift";
  static const String gifts1 = "Gifts";
  static const String giftGide = "Gift Guide";
  static const String blockGift = "Block gift's effects";

  static const String giftEffect =
      "After stopping, gifts sent by others will not appear.";
  static const String entriesEffect =
      "After stopping, you will not see other users' entries.";
  static const String bannersEffect =
      "After stopping, you will not see gift banners sent by other users.";
  static const String bannersEffectAlert =
      "*which may cause you to miss important announcements or offers. Please choose carefully.";

  static const String sendGift = "Send Gift";
  static const String adminOfRoom = "Admins of room";
  static const String lockYourRoom = "Lock your Room";
  static const String effectSettings = "Effect Settings";
  static const String banners = "Banners";
  static const String entries = "Entries";
  static const String store = "Store";

  static const String deletedThisMessage = "You deleted this message";
  static const String messageWasDeleted = "This message was deleted";
  static const String messageRequired = "Message Required";
  static const String messages = "Messages";

  ////////////////////////

  // login_page && register_page
  static const String passwordsDoNotMatch = "Passwords do not match.";
  static const String loginSubtitle =
      'Login to your account and pick up right\nwhere you left off.';
  static const String registerSubtitle =
      'Create your account and start right\nwhere you want to chat.';
  static const String or = "Or";
  static const String phoneNum = "Enter Phone Number";
  static const String faceBook = "Facebook";
  static const String appleId = "Apple Id";
  static const String signInWithApple = "Sign up with Apple";
  static const String signInWithHuawei = "Sign up with Huawei";
  static const String googleAccount = "Google Account";
  static const String deleteAccount = "Delete account";
  static const String password = "Password";
  static const String setPassword = "Set Password";
  static const String passwordShouldBe6 = "Password should be 6 numbers";
  static const String signIn = "Sign in";
  static const String signInWithPhone = "Sign in with Phone";

  /// Quick / guest login. The key IS the English text (see locale_keys.g.dart:
  /// `_en` is empty by design), so this needs no English translation entry.
  static const String quickLogin = "Quick Login";
  static const String signUp = "Sign up";
  static const String checkIn = "Check in";
  static const String forgotPassword = "Recover password";
  static const String forgotPasswordTitle = "Forgot password";
  static const String doNotHaveAccount = "Don’t have an account? ";
  static const String registerTitle = "Sign Up";
  static const String createAnAccount = "Sign Up access your account";

  // add_information_page
  static const String addInformationTitle = "Let’s know about you";
  static const String addInformationSubtitle =
      "Help us personalize your experience";
  static const String male = "Male";
  static const String female = "Female";
  static const String coinsBalance = "Coins Balance";
  static const String fullName = "Full name";
  static const String birthday = "Your date of birth";
  static const String birthDay = "Birthday";
  static const String gender = "Gender";
  static const String modifyGender = "Modify gender";
  static const String modifyBirthday = "Modify birthday";
  static const String selectBirthday = "Please select your date of birth";
  static const String country = "Select country";
  static const String payment = "Select payment";
  static const String countries = "Select country/region";
  static const String confirm = "Confirm";
  static const String set = "Set";
  static const String save = "Save";

  // otp_code
  static const String verifyYourPhoneNumber = "Please verify your phone number";
  static const String otp = "Your code was send to";
  static const String otpSubtitle =
      "Input the code sent to your email address for confirmation of your phone number.";
  static const String resendCode = "Resend";

  // Recover Password
  static const String proceed = "Next";
  static const String recoverPasswordSubtitle =
      "Input your associated phone number below";
  static const String createNewPassword = "Create new password";
  static const String createNewPasswordSubtitle =
      "Create a new password for your account";

  static const String whatsAapNumber = "WhatsAap Number";

  // Layout
  static const String favorite = "Favorite";

  // Home
  static const String viscount = "Viscount";
  static const String count = "Count";
  static const String marquis = "Marquis";
  static const String duke = "Duke";
  static const String king = "King";
  static const String emperor = "Emperor";

  static const String all = "All";
  static const String unRead = "Unread ( ";
  static const String allInbox = "All Inbox";
  static const String interested = "You may be interested";

  // Handling data
  static const String noCountries = "No available counties !!";
  static const String noCountriesMsg =
      "We couldn't find any counties. Please try again later.";
  static const String noInterestRooms = "No available interested rooms !!";
  static const String noInterestRoomsMsg =
      "We couldn't find any interested rooms. Please try again later.";
  static const String noRooms = "No available rooms !!";
  static const String noRoomsMsg =
      "We couldn't find any rooms. Please try again later.";

  static const String noNewRoomsMsg =
      "There is no rooms now. Please try again later.";
  static const String noEventsNow = "No events now !!";
  static const String noEventsNowMsg =
      "We couldn't find any events. Please try again later.";
  static const String noGamesCategory = "No available game categories !!";
  static const String noGamesCategoryMsg =
      "We couldn't find any game categories. Please try again later.";
  static const String noGamesRoom = "No available game rooms !!";
  static const String noGamesRoomMsg =
      "We couldn't find any game rooms. Please try again later.";
  static const String noUsers = "No available users !!";
  static const String noUsersMsg =
      "We couldn't find any users. Please try again later.";
  static const String noChats = "It looks like there are no chats here!";
  static const String noChatsMsg = "Start chatting with friends now!";
  static const String noRankImages = "no available images";
  static const String noRankImagesMsg =
      "We couldn't find any images. Please try again later.";
  static const String noLevels = "no available levels";
  static const String noLevelsMsg =
      "We couldn't find any levels. Please try again later.";
  static const String noMessages = "No available messages !!";
  static const String noMusic = "Empty playlist";
  static const String clickToAddMusic = "Click to add music";
  static const String noMessagesMsg =
      "We couldn't find any messages. Please try again later.";

  // Explore
  static const String games = "Games";

  static const String noGamesNow = "No Games now";
  static const String noGamesNowMsg =
      "No games are available right now. Please check back later.";
  static const String gamesNotAvailableForYou =
      "Games are not available for you";
  static const String dynmic = "Dynmic";
  static const String gameCategory = "Game category";
  static const String activeGamer = "Active Gamer";
  static const String gameRoom = "Game Room";
  static const String gameStar = "Game Star";
  static const String diamonds = "Diamonds";
  static const String coins = "My Coins";
  static const String coins_ = "Coins";
  static const String contactSeller = "Contact to reseller whatsapp";
  static const String today = "Today";
  static const String explore = "Expolre";

  // Coin Seller (Reseller) system
  static const String coinSeller = "Coin Seller";
  static const String seller = "Seller";
  static const String coinSellerDashboard = "Coin Seller Dashboard";
  static const String resellerDirectory = "Top Coin Sellers";
  static const String top = "Top";
  static const String sellerBalance = "Seller Balance";
  static const String coinBalance = "Coin Balance";
  static const String totalTransferred = "Total Transferred";
  static const String todayTransferred = "Today's Transferred";
  static const String transferCoins = "Transfer Coins";
  static const String recipientUserId = "Recipient User ID";
  static const String enterUserId = "Enter the user's ID";
  static const String amount = "Amount";
  static const String enterAmount = "Enter amount";
  static const String noteOptional = "Note (optional)";
  static const String enterNoteOptional = "Add a note for this transfer";
  static const String transferNow = "Transfer Now";
  static const String confirmTransferTitle = "Confirm Transfer";
  static const String transferHistory = "Transfer History";
  static const String searchRecipient = "Search by name or user ID";
  static const String fromDate = "From date";
  static const String toDate = "To date";
  static const String noSellerHistoryTitle = "No transfers yet";
  static const String noSellerHistorySubTitle =
      "Coins/diamonds you transfer to users will appear here.";
  static const String invalidUserId = "Please enter a valid user ID";
  static const String invalidAmount = "Please enter a valid amount";

  // Favourite
  static const String reelFollowing = "Following";
  static const String following = "Following";
  static const String followBack = "Follow back";

  static const String newRoom = "New Room";
  static const String followings = "Followings";
  static const String friends = "Friends";
  static const String views = "Views";

  static const String followers = "Followers";
  static const String follow = "Follow";
  static const String mutualFollow = "UnFriend";
  static const String followed = "Followed";
  static const String unFollow = "UnFollow";
  static const String sureUnFollow = "Do you want to UnFriend?";
  static const String sureUnFollow2 =
      "Are you sure you want to stop following this person?";
  static const String relatedTab = 'Related';
  static const String friend = 'Friend';
  static const String couple = 'Couple';
  static const String brother = 'Brother';

  //explore
  static const String noDataYet = 'No found data yet !!';
  static const String success = "Success";
  static const String error = "Error";
  static const String allowMic = "Allow Mic";
  static const String MicPermission = "Can not use Microphone!";
  static const String MicPermissionDescription =
      "Please enable microphone access in the system settings!";
  static const String operationNumber = "Operation Number";
  static const String operationFailed = "Operation Failed";
  static const String unExpectedError = "Un Expected Error";

  ///family
  static const String create = "Create";
  static const String createRoom = "New Room";
  static const String no = "No";
  static const String noTypesFound = "No types found";
  static const String noPhoto = "No Photo";
  static const String photoWall = "Achievement Wall";
  static const String yes = "Yes";
  static const String pleaseWait_ = 'Please wait...';
  static const String createFamily = "Create Family";
  static const String createFamilyBody = "You did not join any Family";
  static const String edit = "Edit";
  static const String editReelDesc = "Edit reel description";
  static const String editProfileCover = "Edit Profile Cover";
  static const String editProfile = "Edit Profile";
  static const String owner = "Owner";
  static const String admin = "Admin";
  static const String adminsTool = "Admins";
  static const String member = "Member";
  static const String addAdmin = "Add Admin";
  static const String addFriend = "Add Friend";
  static const String deleteMember = "Delete Member";
  static const String removeAdmin = "Remove Admin";

  static const String showProfile = "Show Profile";
  static const String familyName = "Family Name";
  static const String enterFamilyName = "Please enter the family name";
  static const String familyMember = "Family Members";
  static const String thisWeek = "This week";
  static const String thisMonth = "This Month";
  static const String familyDescription = "Family Description";
  static const String pleaseEnterFamilyDescription =
      "Please enter the family description";
  static const String pleaseEnterAllData = "Please enter all data!!";
  static const String pleaseGoToRecharge = "Please go to recharge";
  static const String areYouSureDeleteFamily =
      "Are you sure do you want delete family?";
  static const String familyMemberDescription = "Up to 1000 members";
  static const String rateOfReturn = "Rate of return";
  static const String rateOfReturnDescription =
      "1% -2% of gifts sent by Family members";
  static const String dailySignin = "Daily Sign in";
  static const String weeklySignIn = "Weekly Sign-in";
  static const String dailyCheckIn = "Daily Check-in";
  static const String youHaveChecked = "You have Signed-in for ";
  static const String dailySigninDescription =
      "You can get rewards by Family members";
  static const String requirement = "Requirement";
  static const String requirementDescription =
      "User wealth level shall higher than 15";
  static const String nextSteps = "Next Steps";

  static const String areYouSureDeleteMusic =
      "Are you sure you want remove this item?";
  static const String deleteFamily = "Delete Family";
  static const String removeSong = "Remove Song";
  static const String family = "Family";
  static const String familyID = "Family ID";
  static const String newFamily = "New Family";
  static const String familyRank = "Family Ranking";
  static const String clickToSeeFamilies = "click to see top families";
  static const String join = "Join";
  static const String yourRequestIsUnderReview = "Your request is under review";
  static const String joinAgency = "Join";
  static const String joinIn = "Join In";
  static const String joined = "Joined";
  static const String amazingReel = "Amazing Reel!";
  static const String amazingRoom = "Amazing Room!";
  static String get amazingMoment =>
      ConstantsManager.isTheme2 ? "Amazing News!" : "Amazing Moment!";
  static const String unableToShare = "Unable to share this reel.";
  static String get unableToShareMoment =>
      ConstantsManager.isTheme2
          ? "Unable to share this news."
          : "Unable to share this momoent.";
  static const String joinToFamily = "Join the family";
  static const String joinRequests = "Join Requests";
  static const String exitFamily = "Exit Family";
  static const String thisUserAdmin = "this user is already admin";
  static const String thisUserMember = "this user is already member";
  static const String nextMonthLevelIs = "Next Level: ";
  static const String areYouSureToLeaveTheFamily =
      "Are you sure to leave the family";
  static const String familyRoom = "Family Room";
  static const String noUsersInRank = 'No users in rank now!!';
  static const String noUsersInFamily = 'Your family member is empty';
  static const String myFamily = "My Family";
  static const String fieldIsRequired = "Field is required";
  static const String noFamiliesToday = "No top families today yet !!";
  static const String noFamiliesWeekly = "No top families this week yet !!";
  static const String noFamiliesMonthly = "No top families this month yet !!";
  static const String pleaseRefresh = "Please refresh after a while ";
  static const String membersTitle = "Members of the Family";
  static const String membersDescription = "Up to 1000 members";
  static const String familyDescriptionTooLong =
      "Description must not exceed 120 characters";
  static const String familyNameTooLong =
      "Family name must not exceed 30 characters";

  static const String profitRateTitle = "Profit Rate";
  static const String profitRateDescription =
      "1% - 2% of gifts sent by family members";

  static const String dailyRegistrationTitle = "Daily Registration";
  static const String dailyRegistrationDescription =
      "You can receive gifts from family members";

  static const String requirementsTitle = "Requirements";
  static const String requirementsDescription =
      "The user's wealth level must be above 15";

  ///agency
  static const String cancelAnAgency = "Cancel agency";
  static const String agencyName = "Agency Name";
  static const String optional = "Optional";
  static const String wantToCancelAgency = "Do you want to cancel an agency?";
  static const String congratulations = 'Congratulations';
  static const String yourRequestWillBeRespondedToWithin3WorkingDays =
      'Your request will be responded to within 3 working days';
  static const String nameAgency = "Agency name";
  static const String agencyCenter = "Agency Center";
  static const String agency1 = "Agency";
  static const String agencySetting = "Agency Setting";
  static const String agencyID = "Agency ID";
  static const String hostCenter = "host center";
  static const String friendLike = "Friend Like";
  static const String income = "Income";
  static const String verified = "Verified";
  static const String operator = "operator";
  static const String bio = "This guy is so lazy. Nothing is written";
  static const String received = "Received";
  static const String agencyMembersRank = "Agency Member Rank";
  static const String agencyMembers = "Agency Members";
  static const String support = "Support";
  static const String supporters = "Supporters";
  static const String titleEmptySupport = "you don't have any supporter now!!";
  static const String subTitleEmptySupport =
      "you don't have any supporter now please try again later...";
  static const String reports = "Reports";
  static const String shippingFromTheAgency = "Shipping from the agency";
  static const String chargingFromTheSystem =
      "Charging from the charging system";
  static const String agencyOwner = "Agency Owner";
  static const String chargeCoins = "Charge Coins";
  static const String chargeDollars = "Charge Dollars";
  static const String details = "Details";
  static const String userID = "User ID";
  static const String enterUserID = "Enter User ID";
  static const String enterQuantityHere = "Enter Quantity Here";
  static const String members = "Members";
  static const String fans = "Fans";
  static const String profits = "Profits";
  static const String profitsDescription =
      "Profits are transferred to your wallet immediately and automatically, and remain stored without any deductions or deductions, regardless of the method of exiting the agency. You can also withdraw them at any time directly from your wallet, without any restrictions or exceptions.";
  static const String date = "date";
  static const String withdrawal = "Withdrawal";
  static const String google = "Google";
  static const String signInWithGoogle = "Sign in with Google";
  static const String continueHuawei = "Sign in with Huawei";
  static const String pleaseEnterID = "Enter the user ID here";
  static const String transferIsAvailable = 'Available Countries';
  static const String withdrawalAmount = "withdrawal amount";
  static const String successfulOperation = 'Successful Operation';
  static const String type = "Type: ";
  static const String noAgencyMember = "No Agency Members Now";
  static const String noAgencyRecords = "No Agency records Now";
  static const String agenciesRequest = "Agencies request";
  static const String agencyWarning =
      "To protect your rights, please fill out the following information truthfully and the platform will keep it confidential.";
  static const String countryTitle = "Enter the name of your country";
  static const String userIdTitle = "The ID that brought you here";
  static const String transactions = "Transactions";
  static const String hostsTitle =
      "Enter the number of broadcasters in agencies?";
  static const String appsTitle =
      "What platform have you worked on/are currently working with?";
  static const String whatsAppTitle = "*WhatsApp number";
  static const String salaryTitle = "*Salary";
  static const String addVideoTitle =
      "Please upload a video of yourself showing your face highlighted (5-10 seconds)";
  static const String addVideoSubtitle =
      "The video you upload will be used only to verify the real person and we will keep it confidential.";
  static const String addImagesTitle =
      "Please upload a photo of your official ID";
  static const String addImagesSubtitle =
      "(Add 2 photos)\nThe photos you upload will only be used to verify the real person and we will keep them confidential.";
  static const String submitting = "Submitting";
  static const String enter = "Enter";
  static const String public = "public";
  static const String compitations = "compitations";

  static const String application2 = "APPLICATION";
  static const String target = "target";
  static const String record2 = "RECORD";
  static const String textInputEnter = "Enter";
  static const String enterRoomPassword = "Enter Password 1-6";
  static const String youRemoveYourPassword = "you remove  your Password";
  static const String enterEachInformation =
      "Please enter all the required information";
  static const String cannotMakeRequest =
      "I have previously submitted a request and no action has been taken!";
  static const String totalUsd = "Total Usd";
  static const String ownerUsd = "Owner Usd";
  static const String totalDimonds = "Total Diamonds";
  static const String totalBeans = "Total Beans";
  static const String withdrawalBeans = "Withdrawal Beans";
  static const String pendingBeans = "Beans to be confirmed";
  static const String pending = "Pending";
  static const String joinagency = "Join a Agency";
  static const String beAHost = "you should be a host to open this";
  static const String years = "years";
  static const String month = "month";
  static const String updateAgency = "Update Agency";
  static const String addSomeData = "Add Comment ....";
  static const String addSomeData2 = "Add Some Data";
  static const String stopCharge = "you can't charge to your agency";
  static const String leaderBoard = "Leaderboard";
  static const String chooseType = "Choose Type";

  ///new agency
  static const String agencyMaster = "Agency Master";
  static const String updateTimeEvery = "Update time every 10 minutes";
  static const String anchorIncome = "Anchor Income";
  static const String anchorSalary = "Agent Salary";
  static const String guildSalary = "Agency Salary";
  static const String mounthlyData = "Monthly Data";
  static const String agencyMounthlyData = "Agency Monthly Data";
  static const String goldTarget = "Gold Target";
  static const String gold = "Gold";
  static const String onMicTime = "Mic Time";
  static const String minutes = "(Minutes)";
  static const String effectDays = "Effect Days";
  static const String dailyData = "Daily Data";
  static const String balanceTransfer = "Balance Transfer";
  static const String availableBalance = "Available Balance";
  static const String availableUSD = "Available usd";

  static const String identitySetting = "Identity Setting";
  static const String datas = "Datas";
  static const String removeAnchor =
      "Are you sure you want to remove this host from your agency?";
  static const String liveReport = "live Report";
  static const String withdrawMySalary = "Host Salary";
  static const String salaryNote = "in the wallet";
  static const String withdrawingTheAgencySalary = "Agency Salary";
  static const String addUserAgent =
      "Confirm to set this user as the Vice-Agent Master?";
  static const String removeUserAgent =
      "Confirm to remove this user as the Vice-Agent Master?";
  static const String cashWithdrawal = "Cash Withdrawal";
  static const String userInfo = "User Info";
  static const String refuse = "Reject";
  static const String agree = "Accept";
  static const String agreed = "Agreed";
  static const String rejected = "Rejected";
  static const String data = 'Data';
  static const String residual = "Residual";
  static const String amountYouWantToTransfer =
      "Enter amount you want to transfer";
  static const String pleaseEnterQuantity = "Please Enter Quantity";
  static const String pleaseEnterInteger =
      "Please enter whole numbers only, without decimals or fractions.";
  static const String transfer = "Transfer";
  static const String transferSuccess = "Transfer Successful!";
  static const String transferSuccessHint =
      "Your money has been transfered \n successfuly!";
  static const String transferAmount = "Transfer Amount";
  static const String dataAndTime = "Date & time";
  static const String noRef = "No. Ref";
  static const String search = "Search";
  static const String searchNow = "Search now";
  static const String searchById = "Search by ID or name";
  static const String pleaseEnterIdFriends = "Please enter your friends's id";
  static const String searchAgency = "Search Agency";
  static const String officeAdmin = "Office Admin";
  static const String createAgency = "Create Agency";
  static const String info = "Info";
  static const String amountMoney = 'the amount of money';
  static const String theDetails = 'The Details';
  static const String salaryTransfer = 'Salary Transfer';
  static const String withdrawelRequest = "Withdrawel Request";
  static const String theCountry = " The Country";
  static const String country_ = " Country";
  static const String thePayment = " The Payment";
  static const String howToWithdraw = "How to withdraw money?";
  static const String withdrawalRequest = "Withdrawal Request";
  static const String addCountryAndPaymentMethod =
      'Please make sure you added the country and payment method';
  static const String communication = 'Contact with me';
  static const String theAmountOfMoney = 'The Amount Of Money';
  static const String transactionAmount = 'Enter amount you want to transfer';
  static const String withdrawMoneyWay = 'Withdraw Money Way';
  static const String methodsWithdrawing = 'Enter methods of withdrawing money';
  static const String countriesWithdrawing =
      'Enter The country to receive money';
  static const String withdrawMoneyCountry = 'Withdraw country';
  static const String chooseMoneyCountry = 'Choose the country';
  static const String choosePaymentMethod = 'Choose available payment methods';
  static const String countrieswithdrawing =
      'Enter The country to receive money';
  static const String information = "Information";
  static const String addConfirmation = "Add Confirmation";
  static const String notesAppear = "If you click here, the notes will appear";
  static const String transferConfirmation =
      "please add the confirmation image";
  static const String theAmountOfDollars = 'The Amount Of Dollars';
  static const String theAmountOfCoins = 'The Amount Of Coins';
  static const String pleaseChooseAtype = "Please choose a type";
  static const String salaryWithdrawelRequest = "Salary Withdrawal Request";
  static const String waitingTab = "Waiting";
  static const String completeTab = "Complete";
  static const String acceptedTab = "Accepted";
  static const String rejectedTab = "Rejected";
  static const String transferedTab = "Transferred";
  static const String cash = "Cash";
  static const String selfWithdrawal = 'Self Withdrawal';
  static const String fixedTarget = "Live Details";
  static const String notChargeToAgancy =
      "Note: Your dollars will be converted into coins";
  static const String changeDollars = "Change dollars to coins";
  static const String forShippingAgent = "Change dollars for shipping agent";
  static const String pleseSelectUser = "Please Select User";
  static const String pleaseInterYourPhone = "Please enter your phone";
  static const String mail = "mil";
  static const String hello = "Hello";

  static const String helloEveryone = "Hello everyone";
  static const String niceToMeetYou = "Nice to meet you";
  static const String photo = "Photo";
  static const String day356 = "325 day";
  static const String haveMedalAmount = "Have medal amount: ";
  static const String usd = "USD";
  static const String hostRequestHint =
      "Make sure to transfer the money to your account first before selecting.";
  static const String chooseYourCountry = 'choose your country';
  static const String yourCountry = 'Your country';
  static const String hostRequest = "Host";
  static const String reject = "Reject";
  static const String availableCountries = 'Available countries';
  static const String availablePayments = 'Available payments';
  static const String chargeAgency = "Charge Agency";
  static const String charge = "Charge";
  static const String noPaymentsTitle = "no payment methods now ";
  static const String noPaymentsSubTitle = "no payment methods now. try again!";
  static const String noCountriesTitle = "no Countries now ";
  static const String noCountriesSubTitle = "no Countries now. try again!";
  static const String noAgentsTitle = "No agents now ";
  static const String noAgentsSubTitle = "No agents now. try again!";
  static const String noHostsAgentsTitle = "No Hosts Requests now.";
  static const String noHostsAgentsSubTitle =
      "no hosts requests now. try again!";
  static const String noDetailsReportsSubTitle =
      "no details reports now. try again!";
  static const String noDetailsReportsTitle = "No Details Reports now.";
  static const String addaNote = "Add a note";
  static const String enteraNote = "Enter a note";
  static const String pleaseEnterCountry = "Please Enter Country";
  static const String pleaseEnterPhone = "Please Enter your phone";
  static const String pleaseEnterPaymentMethod = "Please Enter Payment Method";
  static const String withdrawelAgentAnswer =
      "You will be answered by the agent within 24 hours";
  static const String noRequestsNowTitle = "No Requests Now";
  static const String noRequestsNowSubTitle =
      "No Requests Now. Try again later";
  static const String noRecordsNowTitle = "No Records Now";
  static const String noRecordsNowSubTitle = "No Records Now. Try again later";
  static const String noAgencyDataNowTitle = "No Agency Data Now.";
  static const String noAgencyDataNowSubTitle =
      "No Agency Data Now. Try again later";
  static const String noAgencyHostsNowTitle = "No Agency Hosts Data Now.";

  static const String noAgencyHostsNowSubTitle =
      "No Agency Hosts Data Now. Try again later";
  static const String noAgencyAdminsNowTitle = "No Agency Admins Data Now.";

  static const String noAgencyAdminsNowSubTitle =
      "No Agency Admins Data Now. Try again later";
  static const String noHostsDataNowTitle = "No Hosts Data Now.";
  static const String noHostsDataNowSubTitle =
      "No Hosts Data Now. Try again later";
  static const String useOfDiamonds = "Use of Diamonds";
  static const String diamondsNeeded = "1. 100 diamonds needed at least.";
  static const String receiveGifts = "2. Receive gifts to get Diamonds.";

  //chat
  static const String groupChat = "World Chat";
  static const String toSendMassage = "coin to send message";
  static const String sendMassageConins = "coins / Time";
  static const String youWillSpend = 'You will spend';
  static const String enterMessage = 'Enter Message';
  static const String message = 'Message';
  static const String enterYorFullData = "Enter your full data !!";
  static const String yourDescriptionLessThan =
      "Your Description Less Than 10 Char";
  static const String you = "You";
  static const String done = "Done";
  static const String deleteChatTitle =
      "Confirm deletion of this conversation?";
  static const String deleteChatSubTitle =
      "This action cannot be undone, and all messages in this chat will be permanently deleted.";
  static const String record = "Record";
  static const String voice = "Voice";
  static const String video = 'Video';
  static const String file = "file";
  static const String findMe = "Find me";
  static const String find = "Find";
  static const String cancel = "Cancel";
  static const String takePhoto = "Take photos";
  static const String selectFromAlbum = "Select from album";
  static const String ok = "OK";
  static const String accept = 'Accept';
  static const String denied = 'Denied';
  static const String team = 'Technical Support';
  static const String test = 'Test';
  static const String events = 'Events';
  static const String groups = 'Groups';
  static const String friendRequest = 'Friend request';
  static const String system = "System";
  static const String systemMessage = "System Messages";
  static const String officialMessage = "Official message";
  static const String stranger = "Stranger";
  static const String officialAccount = "Official Account";
  static const String thisMessageWasDeleted = "this message was deleted";
  static const String youDeletedThisMessage = "you deleted this message";
  static const String resendMessage = 'Resend Message';
  static const String deleteMessage = "Delete message?";
  static const String removeForAll = "Delete for everyone";
  static const String removeForMe = "Delete for me";
  static const String theTextHasBeenCopied = "The text has been copied";
  static const String pin = "pin";
  static const String copy = "copy";
  static const String copied = "copied";
  static const String report = "Report";
  static const String flag = "Flag";
  static const String addToBlacklist = "Add to blocklist";
  static const String offline = "Offline";
  static const String online = "Online";
  static const String onlineUser = "Online User";
  static const String camera = "Camera ";
  static const String gallery = "Gallery ";
  static const String audio = "Audio ";

  static String conversationChannelName(String chatId) =>
      'conversation-$chatId';
  static const String conversationChatEventName = 'update-conversation-list';
  static const String chatEventName = 'getChatUsersBloc';
  static const String openChatEvenName = 'open_chat';
  static const String reactMessageEvenName = 'react-event';
  static const String deleteMessageFromAll = 'delete-message';
  static const String deleteMessageFromAllCard = 'card-delete-message';

  static String chatChannelName() => 'user-${MyDataModel.getInstance().id}';
  static const String email = "Email";

  static String purchasedNumber(String id) => 'Purchased coins ($id)';

  static String receivedNumber(String id) => 'Received coins ($id)';

  ///mall_bag
  static const String cars = "Cars";
  static const String background = "Background";
  static const String myBag = 'Bag';
  static const String buy = "Buy";
  static const String use = "Use";
  static const String unUse = "Un use";
  static const String price = "with the price";
  static const String enterId = "Enter Id";
  static const String youWillBuy = "You will buy";
  static const String youWillUse = "You will use";
  static const String mall = "Mall";
  static const String i = "I";
  static const String bubble = "Bubbles";
  static const String frames = "Frames";
  static const String effects = "Entry effects";
  static const String emojis = "Emojis";

  ///profile
  static const String vip = "VIP";
  static const String vipCenter = "VIP Center";
  static const String vipGift = "VIP Gift";
  static const String bagGift = "Bag Gift";
  static const String host = "Host";
  static const String rechargeCoins = "Recharge coins";
  static const String rechargeDiamond = "Recharge using Diamonds";

  static const String customerSupport = "Customer Support";
  static const String visitors = 'Visitors';
  static const String settings = 'Settings';
  static const String myLevel = "My level";
  static const String myReels = "My Reels";
  static const String theLevel = "Level";
  static const String myIncome = "Income";
  static const String myIncome2 = "My Income";
  static const String rechargeOptions = "Recharge Options";
  static const String rechargeProblem =
      "If your recharge cannot be completed please click here";
  static const String badges = "Badges";
  static const String collectedAchievements = "COLLECTED ACHIEVEMENTS";
  static const String collectedGifts = "COLLECTED GIFTS";
  static const String rideQuantity = "Ride quantity";
  static const String giftQuantity = "Gift quantity";
  static const String badgeQuantity = "Badge quantity";

  static const String diamond = "Diamond";
  static const String agencyDiamond = "Agency Diamond";
  static const String berry = "Berry";
  static const String activate = "Activate";
  static const String cashOut = "Cash out";
  static const String myProps = "My Bag";
  static const String wearingMedals = "Wearing medals";
  static const String wear = "Wear";

  ///level
  static String level(String level) => 'LV $level';
  static const String sender = 'sender';
  static const String receiver = 'Receiver';
  static const String giftReward = 'Gift reward';
  static const String giftRank = 'Gift Rank';
  static const String giftList = 'gift list';
  static const String giftSent = 'gifts sent';
  static const String badgeReward = 'Badge reward';
  static const String badge = 'Badge';
  static const String ride = 'Ride';
  static const String goodRewards = 'Higher level get richer rewards';
  static const String goodBadges = 'Higher level get better-looking badges';
  static const String getTheCode_ = 'Get the code';
  static const String currentexperience = 'To the next level need ';
  static const String nextlevel = 'Next Level Experience';
  static const String whenSend = 'When send ';
  static const String whenReceive = 'When receive ';
  static const String currentExperienceLevel = 'Current Experience';

  static String currentExperience(String level) =>
      '${StringManager.currentexperience.tr()} $level';

  static String nextLevel(String nextLevel) =>
      '${StringManager.nextlevel.tr()}  $nextLevel';
  static const String levelPrivileege = 'Level privileege';
  static const String entryEffects = 'Entry effects';
  static const String headdress = 'Headdress';
  static const String icLevel = 'Level icons';
  static const String medal = 'Medals';
  static const String howToUpgrade = 'How To upgrade?';

  ///fffv
  static const String noVisitors = 'there is no visitore';

  ///setting
  static const String collectedOrdinaryGifts = 'COLLECTED ORDINARY GIFTS';
  static const String becomeVipTiger = 'Become a $appName VIP';

  static String nowVipTiger(String level) =>
      'Now your are in $appName VIP $level';
  static const String gin = 'GIN';
  static const String avaiableCoins = 'Avaiable Coins';
  static const String artist = 'artist';
  static const String accountSettings = 'Account Settings';
  static const String account = 'Account binding';
  static const String privacy = ' Vip Privacy';
  static const String privacyPolicy = 'Privacy statement';
  static const String privacySetting = 'Privacy';
  static const String purchaseAgreement = 'Purchase Agreement';
  static const String vipPrivilege = 'Vip Privilege';
  static const String security = 'Security';
  static const String language = 'Language settings';
  static const String english = 'English';
  static const String arabic = 'عربي';
  static const String turkish = 'Turkish';
  static const String urdu = 'Urdu';
  static const String india = 'India';
  static const String indonesia = 'Indonesia';

  static const String title = 'Title';
  static const String code = 'Enter verification code';
  static const String aboutUs = 'About $appName';
  static const String profilePhotoHint =
      'Upload a recent photo of yourself, those that do not meet the requirements cannot pass the review';
  static const String uploadProfilePhoto = 'Upload profile photo';
  static const String uploadBackGroundPhoto = 'Upload a background photo';
  static const String changeCover = 'Change cover';
  static const String versionNum = 'Version Number';
  static const String reportAProblem = 'Report a problem';
  static const String termsAndCondition = ' « $appName User Agreement » ';
  static const String termsOfService = 'Terms of Service';
  static const String twoFactorAuthentication = '2- Factor Authentication';
  static const String changePassword = 'Change password';
  static const String changePhoneNumber = 'Change phone number';
  static const String writeDescription = 'Write Description';
  static const String bind = 'Link';
  static const String bindCp = 'Bind CP';
  static const String and = 'and';
  static const String beforeCharge = 'before charging';
  static const String bound = 'Linked';
  static const String unBound = 'link';
  static const String mobileNumber = 'Mobile Number';
  static const String createFamilyTitle1 = 'What is a family';
  static const String createFamilySubTitle1 =
      'A family is an organization created by users themselves. Users join the family and work together with like-minded partners to continuously strengthen the family';
  static const String createFamilyTitle2 = 'Conditions for creating a family';
  static const String createFamilySubTitle2 = 'Wealth level reaches level 30';

  static const String conferm =
      'Please keep in mind that the selection of the house must be valid, and no one will receive the verification code';

  static const List<String> securityTitles1 = [
    changePassword,
    changePhoneNumber,
    google,
  ];

  static const List<String> settingTitles1 = [account, privacy, security];
  static const List<String> settingTitles2 = [
    language,
    reportAProblem,
    termsAndCondition,
  ];

  static String thisFeatureisNotAvailableForYou({required String vip}) =>
      "${youHaveToBuy.tr()} $vip ${toEnjoyIt.tr()}";
  static const String youHaveToBuy = "You have to buy VIP";
  static const String toEnjoyIt = "or more to enjoy it";

  ///home
  static const String searchResult = "Search result";
  static const String ops = "Oops!";
  static const String warning = "Warning";
  static const String needToExitFromOther =
      "do you need to log out from all devices?";
  static const String noUsersHour = "No leading users this hour so far!";
  static const String noUsersHourMsg =
      "The hourly leaderboard will update shortly!";
  static const String noUsersToday = "No leading users for today so far!";
  static const String noUsersWeekly = "No leading users this week so far!";
  static const String noUsersMonthly = "No leading users this month so far!";
  static const String noUsersTodayMsg =
      "The leaderboard will update as more users join!";
  static const String noUsersWeeklyMsg =
      "The weekly leaderboard will update shortly!";
  static const String noUsersMonthlyMsg =
      "The monthly leaderboard is updating—check back soon!";

  ///common
  ///errors and toasts
  static const String tryAgain = "try again";
  static const String more = "More";
  static const String moreRooms = "More Rooms";
  static const String moreLives = "More Live Streams";
  static const String noLives = "No live streams right now !!";
  static const String noLivesMsg = "Try again later";
  static const String endLiveTitle = "End Live Stream";
  static const String endLiveMsg =
      "Do you want to end your live stream now? All viewers will leave once it ends.";
  static const String searchUsers = "Search for users";
  static const String someThingWentWrong = "Some thing went wrong";
  static const String modeHasFixedBackground =
      "This mode has a fixed background and cannot be changed";
  static const String unableToConnectToTheServer =
      "Unable To Connect To The Server";
  static const String unexcepectedError = "unexpected error";
  static const String areYouSureDeleteChat =
      "Are you sure do you want delete Chat";

  static const String functionalProblem = "Function Problem";
  static const String havingFun = "i'm having fun in this room";
  static const String suggestion = 'Suggestion';
  static const String suggestionAndOpinions = 'Suggestion And Opinions';
  static const String bug = 'Bug';
  static const String help = 'Help';
  static const String rechargeId = "Recharged ID";
  static const String recharge = "Recharge";
  static const String rechargeNow = "Recharge Now";
  static const String exchangeNow = "Exchange Now";
  static const String other = 'Other';
  static const String userRoom = 'User Room';
  static const String userReport = "User Report";
  static const String typeOfProblem = "Type of problem";
  static const String description = "Description";
  static const String uploadPicture = "Profile Photo";
  static const String uploadScreenshots =
      "Upload screenshots can help us identify the offending content for further action.";
  static const String submission = "Submission";
  static const String enterYourProblem =
      "Please explain your problem in detail so that our customer service staff can understand and deal with it";
  static const String screenshot = 'Screenshot';
  static const String comingSoon = 'Soon';
  static const String comingSoon2 = '❝Cooming Soon❞';
  static const String live = "Live";
  static const String liveTrackBadge = "Live";
  static const String goLive = "Go Live";

  // Pre-live broadcast shapes (the tab strip under the composer).
  static const String liveModeSolo = "Live";
  static const String liveModeThreeSeats = "3 Seats";
  static const String liveModeSevenSeats = "7 Seats";
  static const String liveModeVoice = "Voice";
  static const String audioRoom = "Audio Room";
  static const String enterMyRoom = "Enter My Room";
  static const String createRoom2 = "Create Room";
  static const String notAvailabale = 'This feature is not available yet.';
  static const String uploadScreenShot =
      'Upload screenshots can help us identify the offending content for further action.';

  static Map<int, bool> userType = {
    0: false, //user
    1: false, //host
    2: false, //hosts agent
    3: false, //shipping agent
    4: false, //hosts and shipping agent
    5: false, //manager
    6: false, //host and shipping agent
    7: false, // coin seller and reseller
    8: false, // coin seller and reseller
  };

  /// Whether the signed-in account is a registered Coin Seller (reseller).
  /// Parsed straight from the login/my-data response's `coin_seller` field
  /// in [MyDataModel._update] -- kept as a standalone flag (same pattern as
  /// [userType] above) instead of a [MyDataEntity]/[MyDataModel] field,
  /// since that model's constructor/copyWith is duplicated across many
  /// call sites and a plain global flag is far less risky to add safely.
  /// Gates the "Coin Seller" menu item in the profile Wallet grid so only
  /// an actual seller ever sees it.
  static bool isCoinSeller = false;

  static const String gameType = "gameType";
  static const String useridkey = "useridkey";
  static String privateCommentKey = "privateComment";
  static const String result = "Result";
  static const String privateComment = "P comment";
  static const String comments = "Comments";
  static const String comment = "Comment";
  static const String likes = "Likes";
  static const String liked = "Liked";
  static const String rps = "RPS";
  static String diceGameKey = "${RoomData.instance.differentCommentKey}dice";
  static String rpsGameKey = "${RoomData.instance.differentCommentKey}rps";
  static String spinGameKey = "${RoomData.instance.differentCommentKey}spin";
  static String luckyDrawGameKey =
      "${RoomData.instance.differentCommentKey}draw";
  static String luckyGiftCommentKey =
      "${RoomData.instance.differentCommentKey}lucky_gift";
  static String rpsGameResultKey =
      "${RoomData.instance.differentCommentKey}${StringManager.result.tr()}rps";
  static String diceGameResultKey =
      "${RoomData.instance.differentCommentKey}${StringManager.result.tr()}dice";
  static const String luckyNumGame = "Lucky Number";
  static String enterRoom = "enterRoom";
  static String winInLuckyBox = "winInLuckyBox";
  static String differentCommentKey = "";
  static String enterRoomKey =
      "${StringManager.differentCommentKey}${StringManager.enterRoom.tr()}Key";
  static const String chooseTimePK = "Set PK duration";
  static const String start = "Start";
  static const String commentsLocked =
      "the host or an Admin have locked the comments";
  static const String selectedStart = "Selected start time";
  static const String selectedEnd = "Selected end time";
  static const String appGift = "App Gift";
  static const String youDoNotHaveVip = "You do not have vip";
  static const String youDoNotHaveVipGoBuy =
      'You don t have vip go buy vip and try again...';
  static const String eventGift = "Event Gift";
  static const String spicalGift = "Special Gift";
  static const String famousGifts = "Famous gifts";
  static const String luckyGifts = "Lucky gifts";
  static const String seat = "Seat";
  static const String typeSomething = "Type your message here";
  static const String diamondsContribution = "Diamonds contribution";
  static const String hours24 = '24 hours';
  static const String hours = 'hours';
  static const String total = "Total";
  static const String noDaimonsNow = "No Diamonds Now";
  static const String roomIntro = "Room intro";
  static const String roomDescription = "Room Description";
  static const String enterRoomIntro = "Please enter the room intro";
  static const String roomNotice = "Room Notice";
  static const String notice = "Notice";
  static const String roomPortrait = "Room Portrait";
  static const String roomName = "Room Name";
  static const String roomId = "Room ID";
  static const String roomPhoto = "Room Photo";
  static const String enterRoomName = "Please enter the room name";
  static const String hideRoom = "Hide Room";
  static const String showRoom = "Show Room";
  static const String useTheFeatureAndEnjoyIt = "Use the feature and enjoy it";
  static const String advice = "Advice";
  static const String active = "Active";
  static const String everyoneOnTheSeats = "Everyone on the seats";
  static const String everyoneOnTheRoom = "Everyone in the room";
  static const String mySteriousPerson = "Anonymous Man";
  static const String thisGiftForbiden = "This gift for VIP";
  static const String noble = 'NOBLE';
  static const String exclusive = 'Exclusive';
  static const String exchangeDiamond = 'Exchange Diamonds';
  // New v2 diamond -> coin Exchange feature strings.
  static const String exchangeDiamondsToCoins = "Exchange Diamonds to Coins";
  static const String diamondBalance = "Diamond Balance";
  static const String exchangeRateLabel = "Exchange Rate";
  static const String enterDiamondsAmount = "Enter diamonds amount";
  static const String youWillReceive = "You will receive";
  static const String exchangeHistory = "Exchange History";
  static const String noExchangeHistory = "No exchange history yet";
  static const String insufficientDiamonds = "Insufficient diamond balance";
  // (StringManager.invalidAmount already exists elsewhere in this file --
  // reused as-is, not redeclared here.)
  // New professional Withdraw feature strings.
  static const String withdrawMethod = "Withdraw Method";
  static const String bkash = "bKash";
  static const String nagad = "Nagad";
  static const String bankTransfer = "Bank Transfer";
  static const String enterAccountNumber = "Enter account number";
  static const String withdrawAmount = "Withdraw Amount";
  static const String submitRequest = "Submit Request";
  static const String withdrawRequestSubmitted =
      "Withdraw request submitted successfully";
  static const String pleaseSelectMethod = "Please select a withdraw method";
  // Live "amount preview" card on the Withdraw tab, mirroring the
  // Exchange tab's "You will receive" card, per request.
  static const String youWillWithdraw = "You will withdraw";

  // ---------------------------------------------------------------------
  // New Withdrawal System (full spec) -- payment methods, create request,
  // history, and the reseller-side incoming-requests screen.
  // ---------------------------------------------------------------------
  static const String withdrawSystemDisabled =
      "Withdrawals are temporarily unavailable. Please check back later.";
  // (StringManager.paymentMethod already exists elsewhere in this file --
  // reused as-is, not redeclared here.)
  static const String selectPaymentMethod = "Select a payment method";
  static const String managePaymentMethods = "Manage Payment Methods";
  static const String myPaymentMethods = "My Payment Methods";
  static const String noPaymentMethodsYet = "No payment methods yet";
  static const String addPaymentMethodFirstSubtitle =
      "Add a payment method to start withdrawing";
  static const String addPaymentMethodTitle = "Add Payment Method";
  static const String editPaymentMethodTitle = "Edit Payment Method";
  static const String accountHolderName = "Account Holder Name";
  static const String enterAccountHolderName = "Enter account holder name";
  static const String extraInfoOptional = "Extra Info (optional)";
  static const String enterExtraInfoOptional = "e.g. bank branch name";
  static const String paymentMethodSaved = "Payment method saved";
  static const String deletePaymentMethodConfirmTitle =
      "Delete this payment method?";
  static const String deletePaymentMethodConfirmMessage =
      "This payment method will be removed from your account.";
  // (StringManager.delete already exists elsewhere in this file -- reused
  // as-is, not redeclared here.)
  static const String paymentMethodDeleted = "Payment method deleted";
  static const String receivedBy = "Received By";
  static const String receivedByAdmin = "Admin";
  static const String receivedByReseller = "Coin Seller";
  static const String selectCoinSeller = "Select Coin Seller";
  static const String noCoinSellersAvailable = "No coin sellers available";
  static const String pleaseSelectCoinSeller = "Please select a coin seller";
  static const String pleaseSelectPaymentMethod =
      "Please select a payment method";
  static const String minWithdraw = "Min";
  static const String maxWithdraw = "Max";
  static const String amountOutOfRange =
      "Amount must be within this method's allowed limit";
  static const String earnedCoinsLabel = "Coins earned";
  static const String withdrawHistory = "Withdraw History";
  static const String noWithdrawHistoryYet = "No withdraw requests yet";
  static const String withdrawHistorySubtitle =
      "Your withdraw requests will appear here";
  static const String filterAll = "All";
  static const String statusPending = "Pending";
  static const String statusAccepted = "Accepted";
  static const String statusRejected = "Rejected";
  static const String incomingWithdrawRequests = "Withdraw Requests";
  static const String noIncomingWithdrawRequests = "No requests right now";
  static const String noIncomingWithdrawRequestsSubtitle =
      "Withdraw requests sent to you will show up here";
  // (StringManager.accept and StringManager.reject already exist elsewhere
  // in this file -- reused as-is, not redeclared here.)
  static const String acceptWithdrawConfirmTitle =
      "Accept this withdraw request?";
  static const String rejectWithdrawConfirmTitle =
      "Reject this withdraw request?";
  static const String requestedBy = "Requested by";
  static const String bill = "Bill";
  static const String strip = "Strip";
  static const String resetSuccessful = "Reset successful";
  static const String fawry = "Fawry";
  static const String opay = "Opay";
  static const String reelDescription =
      "Hey! 👋\nCome watch this reel with me!\nIt’s really interesting! 🔥";
  static const String googlePay = "Google Pay";
  static const String roomDescriptionChat =
      "Hey! 👋\nCome join this room with me!\nIt's really interesting! 🔥";

  static String getGateWay({required String gateway}) {
    switch (gateway) {
      case 'strip':
        return strip.tr();
      case 'fawry':
        return fawry.tr();
      case 'google_pay':
        return googlePay.tr();
      case 'opay':
        return opay.tr();
      default:
        return gateway;
    }
  }

  static const String day = "days";
  static const String defaultText = "Default";
  static const String becomeVip = "Become VIP";
  static const String lockYourChat = "Lock your chat";
  static const String cleanchat = "Clean chat";
  static const String cleanComments = "Clear Comments";
  static const String cleanchatSubtitle =
      "Are you sure you want to permanently clean all your chat?";
  static const String lockYourChatSubtitle =
      "Set the pin for locking your room";
  static const String youAreAristocracy =
      'You’re currently not a VIP member, buy any of this VIP to enjoy exclusive items';

  static const String youAreNowAristocracy = 'You’re currently Vip';

  static String vipLevelGift({required int level}) =>
      "${thisGiftForbiden.tr()} $level";
  static const String pk = "PK";
  static const String clearChat = "Clear Chat";
  static const String lockRoom = "Lock Room";
  static const String lockRoomDialog = "Do you want to lock the room?";
  static const String unlockRoom = "Unlock Room";
  static const String lockChat = "Lock Chat";
  static const String theme = "Theme";
  static const String manager = "Manager";
  static const String music = "Music";
  static const String localMusic = "Local music";
  static const String musicList = "Music List";
  static const String choosePreferableMicMode = "Choose preferable mic mode";
  static const String micMode = "Room Mode";
  static const String micMode12 = "12 Mic";
  static const String micMode16 = "16 Mic";
  static const String micMode22 = "22 Mic";
  static const String micMode30 = "30 Mic";
  // Party room view mode: anyone may enter and watch, but a seat has to be
  // applied for and approved.
  static const String viewMode = "View mode";
  static const String viewModeOn = "View mode on: seats need approval";
  static const String viewModeOff = "View mode off: anyone can take a seat";
  static const String apply = "Apply";
  static const String seatRequests = "Seat requests";
  static const String noSeatRequests = "No one is waiting";
  static const String couplesMode = "Couples Mode";
  static const String micMode9 = "9 Mic";
  static const String micMode8 = "8 Mic";
  static const String micMode2 = "2 Mic";
  static const String tools = "Tools";
  static const String task = "Task";
  static const String noFamily = 'No Family Yet';
  static const String cantOpenPk = 'Can\'t open in this mood';
  static const String cantClosePk = 'Can\'t close the pk';

  //levels

  static const String level1 = "1-9";
  static const String level2 = "10-19";
  static const String level3 = "20-29";
  static const String level4 = "30-39";
  static const String level5 = "40-49";
  static const String level6 = "50-59";
  static const String level7 = "60-69";
  static const String level8 = "70-79";
  static const String level9 = "80-89";
  static const String level10 = "90-99";
  static const String level11 = "+100";
  static const String level0 = "LV.0";

  //level page
  static const String sendGifts = "Send Gifts";
  static const String sendGiftsDetails =
      "Send cool gifts to users to get experience";

  static const String buyAristocracy = "Buy Aristocracy";
  static const String buyAristocracyDetails =
      "Active/renew Aristocracy get experience";
  static const String purchase = "Purchase";
  static const String renew = "Renew";
  static const String know = "Know";
  static const String rule = "Rule";

  static const String purchaseItems = "Purchase items";
  static const String purchaseItemsDetails =
      "Purchase cool items in the mall to get experience";

  static const String customRoom = "Custom room theme";
  static const String customRoomDetails =
      "Custom the exclusive room theme to get experience";

  static const String sendWorld = "Send World Chat";
  static const String sendWorldDetails =
      "Participate in world chat to get experience";

  static const String sendSpoof = "Send Spoof emoji";
  static const String sendSpoofDetails =
      "Spoof emoji in the room to get experience";

  static const String roomTop = "Room On Top";
  static const String roomTopDetails =
      "Use Room On Top function to get experience ";

  static const String applyRoom = "Apply for room event";
  static const String applyRoomDetails =
      "Apply for room event display to get experience";

  // Recover Password

  static const String recoverPhone = "Recover phone";
  static const String bindPhone = "Bind phone number";
  static const String recoverNewPhone = "Recover new phone";

  static const String recoverNewPasswordSubtitle =
      "Input your new phone number";

  static const titleFriend = "It looks like there are no friends here! 😔";
  static const subtitleFriend = "You haven’t added any friends. ";

  static const titleFollowers = "It looks like there are no followers here! 😔";
  static const subtitleFollowers = "You haven’t followed anyone yet.";

  static const titleFollowing = "It looks like there are no following here! 😔";
  static const subtitleFollowing = "You haven’t followed anyone yet.";

  static const titleVisitors = "It looks like there are no visitors here! 😔";
  static const subtitleVisitors = "you don't have anyone visited you";

  static const deadline = "Deadline";

  static const tabHereToActive = "Tap here to activate or apply this item.";
  static const cantBeUse = "This item cannot be used at the moment.";
  static const itemAvailable = "Item available";
  static const itemUnAvailable = "Item unavailable";
  static const completeYourPayment = "Complete the purchase process";

  ///Room
  static const String hostMode = "Host Mode";
  static const String createYourRoom = "Create my room";
  static const String partyMode = "Party Mode";
  static const String midPartyMode = "Mid party mood";
  static const String roomPassword = "Room Password";
  static const String roomMemberSendMessage = "Room member Send the message";
  static const String sendToMe = "Send To ";
  static const String allow = "allow";
  static const String postMomentHint =
      "Show yourself and share life through pictures to get more likes and followers!";
  static const String choseYourMic = "Choose your music";
  static const String win = "win";
  static const String leaveTheRoom = "Leave the room";
  static const String areYouSureLeaveTheRoom =
      "Are you sure to leave the room?";
  static const String toRoom = "too room";
  static const String youGet = "You Get ";
  static const String saySomething = "Say Something...";
  static const String sayHello = "Say Hello";
  static const String sayHi = "Say Hi";
  static const String delete = "Delete";
  static const String song = "Songs";
  static const String checkInternet = "Check your internet";
  static const String noGift =
      "There is no gift available now, please try again later.";
  static const String pleaseCheckInternet =
      "Please check your internet connection";

  static String joinedRoom(String name) => "$name Entered the room";
  static String winInLuckyBoxMessageKey = "winInLuckyBoxMessageKey";
  static String sendBoxMessageKey = "sendBoxMessageKey";
  static const String youHaveNoAccess =
      "Application doesn't have access to the library";
  static const String youCanObtainRoom =
      "You can obtain it through one of the participating members within the room";
  static const String loading = "Loading...";
  static const String pleaseWait = "Please wait while we fetch your data....";
  static const String someThingWrong = "Something went wrong, please try again";
  static const String someWrong = "Something went wrong !!";
  static const String unableToConnect =
      "Unable to connect to the server. Please check your internet connection.";
  static const String liveServiceUnavailable =
      "There's a problem with the live service. You can browse and send gifts, but audio/video isn't available — please contact technical support.";
  static const String too = "To";
  static const String icon = "Icon";
  static const String unitsOfDigitalCurrencies = "Units of digital currencies";
  static const String refresh = "Refresh";
  static const String dontHaveAccount = "Don't have an account?";
  static const String createAccount = " Create account";
  static const String don0tHaveAccount = "Don’t have an account? ";
  static const String alreadyHaveAccount = "Already have an account? ";
  static const String addToBlock = "Add too block";
  static const String yourCoinChargeHistoryAppear =
      "Your coin charge history will appear here.";
  static const String noTransactionsYet = "No Transactions Yet";
  static const String transactionCanceled = "Transaction Canceled";
  static const String takeOnSeat = "Take On Seat";
  static const String switchSeat = "Switch Seat";
  static const String leaveSeat = "Leave Seat";
  static const String lockSeat = "Lock Seat";
  static const String unLockSeat = "UnLock Seat";
  static const String micRequestSent = "Your request to join the mic was sent to the host";
  static const String couldNotTakeSeat = "Could not take the seat";
  static const String pleaseTryAgine = "Please try again later ...";
  static const String noAlerts = "No alerts available !!";
  static const String emptyNotifications =
      "You're all caught up, no new notifications for now";
  static const String titleEmptyFamily = "No requests at the moment";
  static const String subTitleEmptyFamily =
      "There are currently no requests in your family";
  static const String titleEmptyPrize = "No Prize";
  static const String subEmptyPrize = "No Prize Found Here";

  static const String titleEmptyFrame = "No frames available !!";
  static const String subEmptyFrame =
      "Add frames to your collection, and they’ll appear here.";

  static const String titleEmptyCar = "No entry effects Available";
  static const String subEmptyCar =
      "Add entry effects to your collection, and they’ll appear here.";

  static const String titleEmptySpecialId = "No special id Available";

  static const String titleEmptyBubbles = "No bubbles Available";
  static const String subEmptyBubbles =
      "Add Bubbles to your collection, and they’ll appear here.";
  static const String titleEmptyProfileFrame = "No profile card Available";
  static const String subEmptyProfileFrame =
      "Add Bubbles to your collection, and they’ll appear here.";
  static const String subEmptySpecialId =
      "Add special id to your collection, and they’ll appear here.";

  static const String titleEmptyTransaction = "No transaction now !!";
  static const String subEmptyTransaction =
      "please go to send gifts and try again..";
  static const String subEmptyTransaction1 =
      "please receive gifts and try again.";
  static const String subEmptyTransaction2 =
      "please go to recharge and try again.";
  static const String ownerSeat = "This seat for room owner !!";
  static const String showDetails = "Show user details";
  static const String showLess = "Show less";
  static const String showMore = "Show more";
  static const String bindNumber = "Bind Number";
  static const String sendVip = "Send Vip";
  static const String notFoundUsers = "Not found users !!";
  static const String thisUserNotInRoom = "This user is not in room";
  static const String thisUserDoNotHaveRoom = "This user do not have room";
  static const String turnOffSound = "Turn off sound";
  static const String turnOnSound = "Turn on sound";
  static const String yourPhoneIsFound = "Your found is bound";
  static const String yourPhoneIsUnFound = "Your found is unbound";
  static const String addYourPhone =
      "Link your phone number to enhance security and receive important updates";
  static const String pleaseBindYouPhone =
      "Your have logged in by google bind your phone first";
  static const String pleaseBindYouPass =
      "Your have logged in by google bind your phone first";
  static const String blockList = "Block List";

  static const String titleBlockList = "No Bad People Here!!";
  static const String subTitleBlockList = "We Hope this Screen always Empty";
  static const String numberOfAchevment = "Number of badges achieved :";
  static const String numberOfGift = "Number of badges achieved:";
  static const String thisUser = "this user ";
  static const String top1 = "Top 1";
  static const String top2 = "Top 2";
  static const String top3 = "Top 3";
  static const String number = "Number";
  static const String memeberCount = "Member Count";

  static const String updat = "Update";
  static const String updateNow = "Update Now";

  static const String updateOptionalTitle = "New features and improvements";
  static const String updateOptionalSubtitle =
      "We've added new features and fixed bugs to improve your experience.";
  static const String updateForcedTitle =
      "Please update to continue using the app";
  static const String updateForcedSubtitle =
      "A critical update is available. To continue enjoying our app, please update to the latest version.";
  static const updateRequired = "Update Required";
  static const updatAvailable = "Update Available";
  static const maybeLater = "Maybe Later";
  static const mustUpdateMessage = "You must update to continue using the app";

  static const String updatDesc = "Update App to enjoy new features";
  static const String pleaseEnterUserID = "Please Input User ID";
  static const String recommend = "Recommend";
  static const String forYou = "For You";
  static const String feedBack = "Customer Service";
  static const String latest = "Latest";
  static const String noAgency = "This person doesn't belong to agency now";

  static const String noAgen = "No Agency";

  static const String noFamilys = "doesn't belong to any family";
  static const String nickname = "Nickname";
  static const String editPersonalizedSignature = "Edit personalized signature";
  static const String changeTheUsername = "Change the username";
  static const String status = "Status";
  static const String statusDetails = "Status details";
  static const String filledNotYet = "Filled not yet";
  static const String image = "Head portrait";
  static const String personalizedSignature = "Personalized signature";
  static const String pleaseInputCountryName = "Please input country name";
  static const String pleaseSelectCountry = "Select country or region";
  static const String registrationForm = "Registration Form";
  static const String fullRealName = "Full Real Name";
  static const String recommendedWhatsapp =
      "Recommended to be same with your whatsapp";
  static const String checkInRegister =
      "I acknowledge that I have read and agree to theabove Terms and Conditions";
  static const String registrationIntro =
      "Almost here let's complete your information";
  static const String userLevel = "User level";
  static const String anchorLevel = "Anchor Level ";
  static const String levelUnplaced = "Top 100: Unplaced";
  static const String userLevelText =
      "User Level: Earned by placing orders and sending gifts";
  static const String anchorLevelText =
      "Anchor Level: Earn 1 income for each Gold Coin gift received";
  static const String textLevel = "You still need to consume";
  static const String textRecevierLevel = "You still need to receive";
  static const String coinsLevel = " coins before";
  static const String consumptionLevel = " Consumption ";
  static const String incomeLevel = " Income ";
  static const String topRoom = "Top Room";
  static const String supercarRacing = "Supercar Racing";
  static const String recommended = "Recommended";
  static const String recommendedGames = "Recommended Games";
  static const String subTitleFriendRequest =
      "You have received a friend request~";
  static const String subTitleNotification =
      "You have received a system notification~";
  static const String subTitleOfficial =
      "Official Messages - Official Technical Support Department for the Application";
  static const String invit = "Invite Creator& Agency";
  static const String fansNumber = "Fans Number";
  static const String cpRelationship = "CP Relationship";
  static const String cpRelationRanking = "CP Ranking";
  static const String uploadPic = "Take photo and click to upload it";
  static const String uploadCover = "Upload cover";
  static const String uploadImage = "Click to upload image";
  static const String emailNotValid = "Invalid email format";
  static const String noAchievement = "No Achievement";
  static const String noGifts = "No Gifts";
  static const String receivedGift =
      "You have already received the gift. Please try again another day.";
  static const String noGiftsToday = "No gifts today please try again later!!";
  static const String pleaseAgree = 'Please read and agree to the ';
  static const String exchangeRate =
      "*When the international exchange rate fluctuates significantly, the price of Crystals will also be adjusted accordingly. The final value is subject to the actual purchase price";
  static const String levelDescriptionBody =
      "When send 1- gold coin gift of will increase 1 wealth experience point. As your level upgrade, the color your level icon will change accordingly.";
  static const String levelDescription = "Level Description";
  static const String experiencePoint = " experience point";
  static const String welcomeBack = "Welcome Back";
  // White-label brand name used in compile-time interpolated strings (and as the
  // translation KEY for those strings in locale_keys.g.dart — both reference this
  // same const, so changing it keeps key and lookup in sync). It MUST stay a
  // const (it feeds `const` strings + `.tr()` keys), so it can't be a runtime
  // config value; the LIVE user-facing brand is ConstantsManager.appDisplayName
  // (read from the native app label at startup) / ConstantsManager.appURL (from
  // config_app). The neutral default here is overridable per build:
  //   flutter build ... --dart-define=APP_BRAND_NAME=<Brand>
  static const String appName =
  String.fromEnvironment('APP_BRAND_NAME', defaultValue: 'Live');
  static const String welcome = "Welcome ";
  static const String uploadPhoto = "Upload Your Photo";
  static const String uploadYourPicture = "Upload Your Picture";
  static const String chatVoiceRoom =
      "Voice chat, Play Games,\nFind more friends";

  static const String theTapWillBeAvailable =
      "This tap will be available in new version";

  //onBoarding

  static const String onBoarding1title = 'Explore Trending Content';
  static const String onBoarding1Subtitlt =
      'Dive into the endless stream of captivating videos. From comedy sketches to dance challenges.';
  static const String onBoarding2title = 'Customize Your Feed';
  static const String onBoarding2Subtitlt =
      'Tailor your $appName experience by following your favorite creators and interests';
  static const String onBoarding3title = 'Engage with the Community';
  static const String onBoarding3Subtitlt =
      'Join the conversation! Like, comment, and share videos that spark your interest. ';

  static const String linkedAccounts = "Linked Accounts";

  //support
  static const String faqSupport = "FAQ";
  static const String emailSupport = "Email support";
  static const String chatSupport = "Chat support";
  static const String writeYourComplaint = "Write your complaint...";
  static const String agencyAddInfo = 'Add your agency information';
  static const String agencyAddBio = 'Add your bio';
  static const String agencyAddImage = 'Add your image';
  static const String agencyAddPhone = 'Add your phone';
  static const String agencyAddName = 'Add your name';
  static const String supportTips = 'Tips';
  static const String supportTipsBody = '1. Please provide true information';
  static const String supportTipsBody3 = '3. We thank you for your support';
  static const String supportTipsBody2 =
      '2. The platform will review your feedback as soon as possible; If you have any other questions, please go to the customer service room (ID: 10000) for feedback';
  static const String problemTime = 'Problem Time';

  //inviteScreen
  static const String youHaveBeenInvited = "You have been invited";
  static const String youCantInviteYourSelf = "you can't invite yourself";
  static const String enterTheInviteCode = "Enter the invitation code here";
  static const String dayEarned = "Day earned";
  static const String dayInvited = "Day invited";
  static const String totalEarned = "Total earned";
  static const String totalInvited = "Total invited";
  static const String watch = "Watch";
  static const String profitProcess = "profit process ";
  static const String coinsCharged = "coins charged ";
  static const String percentage = "percentage";
  static const String howToGainFreeCoins = "How to get";
  static const String freeCoins = " Free Coins";
  static const String invitation = "Invitation";
  static const String inviteFriendsTitle = "Invite friends";
  static const String invitationRewards = "Invitation rewards";

  // Invite Bonus (gold-treasure) screen
  static const String inviteBonus = "Invite Bonus";
  static const String inviteNow = "Invite your friends now";
  static const String commissionPercent = "Commission";
  static const String myInviteIncome = "My Invitation Income";
  static const String extractCoins = "Extract Coins";
  static const String myInvitations = "My Invitations";
  static const String invitationCode = "Invitation Code";
  static const String claimBonus = "Claim Bonus";
  static const String oneTimeBonus = "One-time welcome bonus";
  static const String extractUpTo = "You can extract up to";
  static const String coinsPerRequest = "coins per request.";
  static const String invitationRules = "Invitation Rules";
  static const String noIncomeToExtract = "No income to extract yet";
  static const String claimableNow = "Available to withdraw now";
  static const String shareInviteCode = "Share & Invite Friends";
  static const String userType_ = "User Type";
  static const String whatsappDetails = "WhatsApp ";
  static const String go = "Go ";
  static const String reelsAddComment = 'Add a comment ...';
  static const String reelsNoCommentsTitle = 'No Comments found !!';
  static const String reelsNoCommentsSubTitle = 'Comments';
  static const String reelsJustNow = 'Just now';
  static const String largeVideo = 'your video is so big to be uploaded';
  static const String areYouSureExit = "Are you sure you want to close app?";
  static const String roomNotAvailable =
      "Zego Feature is Disabled, Contact the administration";
  static const String note = "Notes";
  static const String noFriends = "No friends found";

  //CP
  static const String relationshipRules = "Relationship rules";
  static const String relationshipPrivileges = "Relationship privileges";
  static const String specialFriend = "Special Friend";
  static const String cpTabRules = "Rules";
  static const String cpTabPrivileges = "Privileges";
  static const String cpTabFriend = "Friend";
  static const String cpRequestTitle = "CP Request";
  static const String dedication = "Give";
  static const String createRelation = "Create Relation";
  static const String relationLevel = "Relation Level";
  static const String relationLevelTitle =
      "After creating a relationship, you can level up the relationship by sending gifts to each other or talking on the microphone in the room at the same time to gain experience value.";
  static const String relationLevelRule1 =
      "1 gold = 1 experience value, there is no upper limit to the experience value that can be obtained by sending gifts every day";
  static const String relationLevelRule2 =
      "Talk on the microphone for 10 minutes in the room at the same time to get 5 experience value, maximum is 240 each day";
  static const String relationLevelNote =
      "Note: On the 15th of every month, CP Memorial Day, the accumulated experience value for sending mutual gifts and talking on the microphone in the same room at the same time will be doubled based on the above.";
  static const String relationRecoveryR1 =
      "After establishing the relationship, you can manually terminate the relationship. After the relationship is terminated, the relationship level, privileges and other records will be deleted. Please think carefully and do not get angry in your heart.";
  static const String relationRecoveryR2 =
      "A relationship that has been stopped can be restored by purchasing a restoration card. You can restore the level, experience value and privileges at the time the relationship was stopped, but the date and number of days for the relationship will be reset and recalculated again.";
  static const String relationRecoveryTitleR1 = "Stop the relationship";
  static const String relationRecoveryTitleR2 = "Restore the relationship";
  static const String createRelationRule1 =
      "Gift relationship stones in the store to other users, create a relationship with you successfully after your request is approved";
  static const String createRelationRule2 =
      "In addition to the CP relationship, each user can create a maximum of 15 distinct relationships with friends, and the relationships will be displayed on the personal home page.";
  static const String createRelationRule3 =
      "Users can only display 3 special friends on their personal homepage. If they purchase the expansion card to increase 3 slots or purchase vip4 to increase 3 more slots, a maximum of 9 friends can be displayed on their personal homepage.";
  static const String myRelations = "My Relations";
  static const String myCp = "My CP";
  static const String cpLevelPrivileges = "CP Level Privileges";
  static const String noSpecialFriends =
      "There are no special friends currently.";
  static const String bestFriend = "Best Friend";
  static const String relationPrivileges = "Relation Privileges";
  static const String relationSpecialFriendPrivileges =
      "Special Friend Privileges";
  static const String relationPrivilegesL1 = "Special effect on the mic seat";
  static const String relationPrivilegesL2 = "Private chat box";
  static const String relationPrivilegesL3 = "Private chat background";
  static const String relationPrivilegesL4 = "Private Entry Effect";
  static const String relationPrivilegesL6 =
      "Chat bubble effects on microphone";
  static const String relationPrivilegesL7 = "special effects for microphone";
  static const String relationPrivilegesL8 = "Exclusive frame";
  static const String expandable = "Expandable";
  static const String noReals = "No reels found";
  static const String noRealsSubTitle = "No reels now. try again!";
  static const String noFollowingRealsSubTitle =
      "Follow people to see their clips here\nor watch live streams and audio rooms";

  static const String wealthDescription = "Wealth level description";

  static String wealthDescriptionBody =
      "When send 1 gold coin gift of will increase ${MyDataModel.getInstance().level?.expSender ?? ""} wealth experience point. As your level upgrade, the color of your level icon will change accordingly.";
  static const String charmDescription = "Charm level description";
  static const String chargeDescription = "Charge level description";
  static String charmDescriptionBody =
      "When receive 1 gold coin gift of will increase ${MyDataModel.getInstance().level?.expSender ?? ""} charm experience point. As your level upgrade, the color of your level icon will change accordingly.";
  static String chargeDescriptionBody =
      "When receive 1 gold coin gift of will increase ${MyDataModel.getInstance().level?.expSender ?? ""} charge experience point. As your level upgrade, the color of your level icon will change accordingly.";
  static const String roomLevel = "Room Level";
  static const String roomLevelDescription = "Room level description";
  static String roomLevelDescriptionBody =
      "Increase your room level by being active in rooms. As your level upgrade, the color of your level icon will change accordingly.";

  static const String roomSupport = "Room Support";
  static const String rewardCoins = "Reward Coins";
  static const String roomCoins = "Room Coins";
  static const String rewardSendTime = "Reward send time";
  static const String targetAndReward = "Target & Reward";
  static const String managePartners = "Manage Room Partners";
  static const String addPartner = "Add Room Partner";
  static const String removePartner = "Remove Partner";
  static const String partnerId = "Partner ID";
  static const String roomSupportInfo =
      "If you achieve Room Support Owner and multiple Room Support members, your room will receive weekly reward coins based on activity.";

  static const String hiTemp = "HI, welcome to $appName";
  static const String loginTel = "Login by tel";
  static const String codeCountry = "Country Code";
  static const String agreeLogin = "Agree to the $appName ";
  static const String userAgreementLogin = "User Agreement ";
  static const String andLogin = "and log in";
  static const String receiveCode = "Receive verification code";
  static const String cpr = "phone and code is required";
  static const String dontReceiveCode = "Didn't receive the verification code?";
  static const String reasonsCodeError = '''
Possible reasons for error:
1. The country code may be wrong. Please check;
2. The mobile phone number is wrong or illegal. Please do not add additional country codes or other numbers (0-9) in front of the mobile phone number. Please check or try again after replacing;
3. The verification code may be blocked to the dustbin. Please check the text message carefully;
4. The operation is too frequent, limited to 3 times in 5 minutes.
''';
  static const String rechargeRecord = "Recharge record";
  static const String diamondRecord = "Diamond record";
  static const String coinsRecord = "Coins record";
  static const String selectCountry =
      "The country can only be selected once and cannot be modified after selection. Please select your country carefully.";
  static const String selectFeedback = "Select feedback type";
  static const String selectRoomTyp = "Select Room type";
  static const String feedbackDescription =
      "Your feedback helps us improve. While we may not be able to respond to every message, we truly appreciate your input. Thank you for your understanding!";
  static const deleteAccountTitle = "Delete Account";
  static const deleteAccountWarning = "You are deleting your account";
  static const deleteAccountConfirmation =
      "Please confirm the following and proceed with caution";
  static const deleteAccountDetails =
      "Deleting your account means you will temporarily give up access to your current account and its data. However, if you register again using the same registration method, your previous data may be restored and linked to your new account automatically. Until then, you will not be able to log in or access any associated information.";

  static const deleteAccountCheckbox =
      "I have understood all the consequences. Are you sure you want to delete the account?";
  static const deleteButtonText = "Delete";
  static const deleteDialogTitle = "Delete Account";
  static const deleteDialogContent =
      "Are you sure you want to delete your account? This action cannot be undone.";
  static const cancelButtonText = "Cancel";
  static const String profilePicture = "Family Photo";
  static const String becomeVIP = "Become VIP";
  static const String familyRequest = "Family  Request";

  static const notRegisteredYet =
      "Your phone number has not been registered yet, register to join $appName now! Register now";
  static const String registerBody = "Register Page";
  static const String exitDialogTitle = "Do you want to give up logging in ?";
  static const String exitDialogForgetPass =
      "Do you want to give up resat password ?";
  static const String exitDialogContent = "Your progress will be lost.";
  static const String thinkAgain = "Think again";
  static const String giveUpRegistering = "Give up logging in";
  static const String giveUpResat = "Give up resat password";
  static const String phoneValidator = "Please enter a valid phone number";
  static const String requestAccepted = "Request accepted";
  static const String requestDenied = "The request was denied";
  static const String reference = 'Ref';
  static const String user = 'User';
  static const String shippingAgents = "Shipping Agents";
  static const String invalidEmail = 'Please enter a valid email address';
  static const String noConnection = 'No connection';
  static const String backOnline = 'Connection';
  static const String waterMark =
      "Enjoy a trial version of the amazing JO LIVE app. For more information about purchasing and support, click here to visit our website.";
  static const String internetConnection =
      'No internet connection. Please check your network settings';

  static const String rulesCpRank = '''
1. 1 Diamond = 1 CP value 2. Statistics receive gifts, and CP relationship increases CP value by giving gifts to each other.
3. The CP list is sorted according to the intimacy value, the higher the intimacy value, the higher the ranking.
''';
  static const String getTheCode = 'You Have to press on get the code first';
  static const String exitRoomFirst = 'You have to exit room first';
  static const String youNowHave = 'You now have ';

  static const String cantSendGift =
      "you can't send gifts in the anonymous mood .. please go and inactivate it first";
  static const String anonymous = "Anonymous";
  static const String setAsAdministrator = "set as administrator";
  static const String agencyHeros = "Agency Heros";
  static const String agencyAdmins = "Agency Admins";
  static const String agencyStars = "Agency Stars";
  static const String directTransfer = 'Direct Transfer';
  static const String agentWithdrawal = 'Agent Withdrawal';
  static const String internalSale = 'Internal Sale';
  static const String noHosts = 'No Hosts';
  static const String noStars = 'No Stars';
  static const String noHeros = 'No Heros';
  static const String transferNote =
      'you should contact with the agency first and agree on the payment and salling the mony outside the app';
  static const String top3Supporters = 'top Supporters';
  static const String chart = 'chart';
  static const String warningRemoveAdmin =
      'This admin if you ban him we remove from room admins too';
  static const String giveGift = 'Give a gift to be on the list';
  static const String lockedSeat = 'This seat is locked';
  static const String gifNotAllow = 'Gif Not Allow Now';
  static const String gifNotAllowForYou = 'Gif Not Allow For You';
  static const String subttitelGif =
      'GIF files are currently not allowed. Please become vip or select an image in JPG or PNG format.';
  static const String warningGif =
      'Animated images (GIF or WebP) are not allowed.';
  static const String invalidImageFormat =
      'Invalid image format. Please select a JPG or PNG image.';
  static const String roomCoverSizeLimit =
      'The image size is too large. Please select an image smaller than 1 MB.';
  static const String publishedOn = 'Published on';
  static const String agencies = "Agencies";
  static const String searchAgencyID = "Search for agency ID";
  static const String picSize =
      "The image size is too large. Please select an image smaller than 2 MB";

  static const String createRoomDefult = "Create room";
  static const String createRoomPaid = "Create room will cost";

  static String willDeductCoins(int coins, String lang) {
    switch (lang) {
      case 'ar':
        return "سيتم خصم $coins عملة.\nيرجى التأكيد للمتابعة";
      case 'tr':
        return "$coins coin tahsil edilecektir.\nDevam etmek için lütfen onaylayın";
      case 'ur':
        return "آپ سے $coins سکے وصول کیے جائیں گے۔\nبرائے مہربانی جاری رکھنے کے لیے تصدیق کریں";
      case 'hi':
        return "आपसे $coins सिक्के लिए जाएंगे।\nकृपया जारी रखने के लिए पुष्टि करें";
      default:
        return "You will be charged $coins coins.\nPlease confirm to continue.";
    }
  }

  static const String expandCp = "Expand CP For";

  static String craeteRoomPaid({required String coins}) =>
      "${createRoomPaid.tr()}($coins)";

  static const String pressToComeBack = 'Press to come back';
  static const String banUser =
      'You have a action ban with get moment for 1 hours because q';

  static String youInRoomNow({String? roomName, String lan = 'ar'}) =>
      lan == 'ar'
          ? 'أنت في غرفة ${roomName ?? ''} ألان'
          : 'You in room ${roomName ?? ''} now';

  static const String sentATreasureBox = "Sent a Treasure Box With";
  static const String missedTheLuckyBag =
      "You missed the Lucky Bag… better luck next time";

  // static const String hardLuck = "Hard Luck";
  static const String goodLuck = "Congratulations, you get";
  static const String sendASpecialBox = "Send a special box:";
  static const String sendASuperLuck = "send a super luck";
  static const String quantity = "Quantity";
  static const String superLuckyBagWillBeDisplayedInAllRoom =
      "super lucky bag will be displayed in all room";
  static const String goldCoins =
      "Any one who opens the lucky bag can get gold coins";
  static const String luckyBox = "Lucky Bag";
  static const String superBox = "Super Box";
  static const String coinsIsEmpty = 'Coins is Empty';
  static const String quantityIsEmpty = 'Quantity is Empty';
  static const String sendALuckyBag = "Send A Lucky Bag";
  static const String congrats =
      'Congrats! You can use the Coins in LIVE videos, for example, to send Gifts';
  static const String unlockAndGetCoins =
      "After the countdown ends, everyone can click on unlock and get coins.";
  static const String byTappingOpen =
      'By tapping "Open", you accept the Treasure Box Rules.';
  static const String open = "OPEN";
  static const String coinCollect = 'Coin collect';
  static const String boxTime = "The box time is";
  static const String sendALuckyBagWorht = " send a lucky bag worht of ";
  static const String continueToTheRoom = " coins to the room";
  static const String coinsInLuckyBag = " coins in lucky bag";
  static const String superBomb = "Super Bomb";
  static const String emptyRoom = "no one in the room now";
  static const String superBombRewards =
      "The rewards here are for reference only. The specific gifts are determined by the contribution and luck of the super bomb.";

  static const String viewCountry = "View Country";
  static const String enterCountry = "Enter Country";
  static const String locationPermissionTitle = "locationPermissionTitle";
  static const String locationPermissionMessage = "locationPermissionMessage";

  static const String countryDialogTitle = "Country Options";
  static const String countryDialogSubtitle =
      "Choose what you want to do with this country";

  static const String administratorManagement = "Administrator Management";
  static const String roomTrophy = "Room Trophy";
  static const String lastWeek = "Last Week";
  static const String roomVisitors = "Room Visitors";
  static const String levelSmall = "level";
  static const String roomRewards = "Room Rewards";
  static const String supportedAdmin = "Supported Admin";
  static const String roomActivity = "Room Activity";

  static const String adminManagementRules =
      "1. The room support level depends on the last week's room trophy and current room visitor number.\n"
      "2. Room support collection time: Monday to Tuesday. Admin list edit/quit time: Wednesday–Sunday.\n"
      "3. When the support level decreases, the seats of admins will decrease.\n"
      "4. The weekly trophy runs from Monday 00:00 to Sunday 24:00 (GMT+8).\n"
      "5. The room owner can apply with at least Level ≥ LV10.\n"
      "6. Non-owner admins should quit current support before applying for new one.\n"
      "7. Under same IP, only three accounts can get support. Violations will be penalized.";

  static const String noRoomData = 'noRoomData';
  static const String checkBackLater = 'checkBackLater';

  static const String weeklyRoomSupport = 'weeklyRoomSupport';
  static const String weeklyCondition = 'weeklyCondition';
  static const String totalSupport = 'totalSupport';
  static const String supportReward = 'supportReward';

  static const String enableLocationTitle = 'Enable Location';
  static const String enableLocationDesc =
      'This app needs location services to work properly. Please enable it.';
  static const String enableLocationAllow = 'Allow';

  static const String processingPayment = 'Processing Payment';
  static const String connectingSecureGateway =
      'Connecting to secure payment gateway';
  static const String doNotCloseWindow = 'Please do not close this window';
  static const String sslEncrypted = '256-bit SSL Encrypted';
  static const String openingLink = 'Opening Link';
  static const String launchingDefaultBrowser =
      'Launching in your default browser';
  static const String externalLink = 'External Link';
  static const String pleaseWaitAMoment = 'Please wait a moment...';
  static const String redirectExternalSite =
      'You are being redirected to an external website in your browser';
  static const String loadingGame = 'Loading game...';
  static const String pleaseWaitGameLoading = 'Please wait ';
  static const String playStreamConnect = "Play • Stream • Connect";
  static const String bySigningUp = "By signing up, you agree to our";
  static const String privacyPolicy_ = "Privacy Policy";
  static const String paymentPending =
      "Payment is pending. Your transaction is temporarily on hold.";
  static const String recommend_ = "🎉 Recommend";
  static const String friends_ = "✨ Friends";
  static const String multiPk = "✨ Multi-PK";
  static const String stream = "✨ Stream";
  static const String myWallet = "My Wallet";
  static const String check = "Check";
  static const String become = "Become";
  static const String grade = "Grade";
  static const String wealthRankings = "Wealth Rankings";
  static const String charmRankings = "Charm Rankings";
  static const String nextStage = "Next Level";
  static const String stage = "Level";
  static const String dailyLevel = "Daily Level";
  static const String weeklyLevel = "Weekly Level";
  static const String monthlyLevel = "Monthly Level";
  static const String diamondAmountThisWeek = "Diamond amount this week";
  static const String rewards = "Rewards";
  static const String tasks = "Tasks";
  static const String thisWeeksTotalHostDiamondIncome =
      "This week's total host\ndiamond income ≧";
  static const String noRewardsMessage =
      "Looks like there are no rewards to display right now. Stay tuned for upcoming rewards!";
  static const String done_ = "Done";
  static const String undone = "Undone";
  static const String rules = "Rules";
  static const String joinRequest = "Join request submitted";
  static const String reachedMaxLevel = "Maximum level reached";
  static const String noEmojis = "no available emojis";
  static const String noEmojisMsg =
      "We couldn't find any emojis. Please try again later.";
  static const String contributorsRank = 'Contributors Rank';
  static const String contributed = 'Contributed';

  static const String youStillNeed = "You still need";
  static const String toUpgarde = "experiance to upgrade";

  // VIP
  static const String vipHeaderText = 'Become VIP to give exclusive gifts.';
  static const String vipHeaderAction = 'Become VIP >';

  // CP
  static const String cpHeaderText = 'Send special CP gifts.';
  static const String cpHeaderAction = 'Explore CP >';

  // Lucky
  static const String luckyHeaderText =
      'If you sell gifts, you\'ll earn more than 1000 times.';
  static const String luckyHeaderAction = 'Try Now >';
  static const String areYouSureopenPk = 'Are you sure you want to open pk?';
  static const String per = "per";
  static const String choosePaymentGateways = "Choose payment gateways";
  static const String coinsConversionTitle = "Diamond to Coins Conversion";
  static const String coin = "Coin";
  static const String diamondsCount = "Diamonds Count";
  static const String diamondsBalance = "Diamonds Balance";
  static const String dollarsBalance = "Dollars Balance";
  static const String dollars_ = "Dollars";
  static const String enterDiamondsCount = "Enter number of diamonds";
  static const String youWillGet = "You will receive";
  static const diamondSources = "Diamond Sources";
  static const convertDiamonds = "Convert Diamonds";
  static const audioRooms = "Audio Rooms";
  static const audioRoomsSubtitle =
      "Earn diamonds by hosting or joining audio rooms";
  static const liveStream = "Live Stream";
  static const liveStreamSubtitle = "Get diamonds by streaming live";
  static const otherSources = "Other Sources";
  static const otherSourcesSubtitle = "Collect diamonds from other activities";
  static String get reelsMoments =>
      ConstantsManager.isTheme2 ? "Reels & News" : "Reels & Moments";
  static String get reelsMomentsSubtitle =>
      ConstantsManager.isTheme2
          ? "Share your reels and news to earn"
          : "Share your reels and moments to earn";
  static const liveBroadcastDiamonds = "Live Broadcast Diamonds";
  static const totalDiamonds = "Total Diamonds";
  static const filter = "Filter";
  static const from = "From";
  static const diamondsLog = "Diamonds Log";
  static const diamondIcon = "💎";
  static const String mostUsed = "Most Used";
  static const String emptyRecordsTitle = "No Records Found";
  static const String emptyRecordsSubtitle =
      "You don’t have any diamond records yet.";

  // Action Buttons
  static const withdraw = "Withdraw";
  static const p2p = "P2P";

  // Earning Sources
  static const earningSources = "Earning Sources";
  static const hostEarnings = "Host Earnings";
  static const agencyEarnings = "Agency Earnings";
  static const bdEarnings = "BD Earnings";

  // Recent Transactions
  static const recentTransactions = "Recent Transactions";
  static const liveEarnings = "Live Earnings";
  static const transferToUser = "Transfer ToUser";
  static const agencyProfit = "Agency Profit";
  static const bankWithdraw = "Bank Withdraw";
  static const referral = "referral";
  static const watchingAds = "watchingAds";
  static const exchangingCoins = "exchangingCoins";
  static const dailyBonus = "dailyBonus";
  static const levelUp = "levelUp";

  static const withdrawOptionsTitle = "Choose Withdrawal Method";
  static const withdrawAgentsTitle = "Withdraw via Agents";
  static const withdrawMobileTitle = "Withdraw to Mobile Wallet";
  static const withdrawBankTitle = "Withdraw to Bank Account";

  // Options cards
  static const agentsTitle = "Agents";
  static const agentsSubtitle = "Withdraw through certified agents";

  static const mobileTitle = "Digital Wallet";
  static const mobileSubtitle = "Vodafone • Etisalat • Orange • WE";

  static const bankTitle = "Bank Account";
  static const bankSubtitle = "Direct transfer to your bank account";

  // Agents modal
  static const agentIdLabel = "Agency ID";
  static const agentIdHint = "Enter agency ID";
  static const agentIdHintBelow =
      "Before sending the dollars to the shipping agent, contact him beforehand to finalize the transaction.";

  static const agentAmountLabel = "Amount";
  static const agentAmountHint = "Enter amount";
  static const agentAmountHintBelow = "Minimum: \$50.00";

  static const confirmAgentWithdraw = "Confirm Withdrawal";

  // Mobile modal
  static const chooseWallet = "Choose Wallet";
  static const chooseBank = "Choose Bank";
  static const chooseWalletHint = "Select provider";

  static const phoneNumberLabel = "Phone Number";
  static const phoneNumberHint = "01XXXXXXXXX";

  static const mobileAmountLabel = "Amount";
  static const mobileAmountHint = "Enter amount";
  static const mobileAmountHintBelow = "Minimum: \$50.00";

  static const confirmMobileWithdraw = "Confirm Withdrawal";

  // Bank modal
  static const bankNameLabel = "Bank Name";
  static const bankNameHint = "Example: National Bank of Egypt";

  static const bankAccountLabel = "Account Number / IBAN";
  static const bankAccountHint = "Enter account number";

  static const accountHolderLabel = "Account Holder";
  static const accountHolderHint = "Name as registered in the bank";

  static const bankAmountLabel = "Amount";
  static const bankAmountHint = "Enter amount";
  static const bankAmountHintBelow = "Minimum: \$50.00 • Transfer fee: \$2.00";

  static const confirmBankWithdraw = "Confirm Withdrawal";
  static const String sendDollarsForUser = "Send dollar for user";
  static const hostWallet = "Host Wallet";
  static const agencyWallet = "Agency Wallet";
  static const dbWallet = "DB Wallet";
  static const earningsDetails = "Earnings Details";
  static const noRecords = "No records found";
  static const noRecordsDesc = "here are no records to display at the moment.";
  static const noTransactions = "No recent transactions available";

  static const transaction_liveProfit = "Live Stream Earnings";
  static const transaction_userTransfer = "Transfer to User";
  static const transaction_agencyProfit = "Agency Earnings";
  static const transaction_bankWithdraw = "Bank Withdrawal";

  static const transaction_date = "Date";
  static const transaction_time = "Time";
  static const transaction_id = "ID";
  static const youWillSendDollars =
      "You will send a dollar to the user by entering their ID within the application.";
  static const isRequired = "is required";
  static const minimumAmount = "Minimum amount is";

  // Todo translate from here
  static const responseTime = "Response Time";
  static const successfulOperations = "Successful Operations";
  static const startChat = "Start Chat";
  static const back = "back";
  static const enterValidAmount = "enter valied amount";

  // Groups
  static const noGroupsYet = "No groups yet";
  static const noGroupsYetMsg = "Create a group to start chatting together";
  static const createGroup = "Create Group";
  static const groupName = "Group Name";
  static const groupNameHint = "Enter a group name";
  static const groupInfo = "Group Info";
  static const groupSettings = "Group Settings";
  static const groupMembers = "Members";
  static const groupOwner = "Owner";
  static const groupAdmin = "Admin";
  static const groupMember = "Member";
  static const groupAdmins = "Admins";
  static const membersCount = "members";
  static const promote = "Make Admin";
  static const demote = "Remove Admin";
  static const kickMember = "Remove from Group";
  static const muteMember = "Mute";
  static const unmuteMember = "Unmute";
  static const transferOwnership = "Transfer Ownership";
  static const leaveGroup = "Leave Group";
  static const deleteGroup = "Delete Group";
  static const addMembers = "Add Members";
  static const groupPrivacy = "Privacy";
  static const groupPublic = "Public";
  static const groupPrivate = "Private";
  static const joinPolicy = "Who Can Join";
  static const joinOpen = "Anyone";
  static const joinByRequest = "By Request";
  static const joinInviteOnly = "Invite Only";
  static const onlyAdminsPost = "Only Admins Can Post";
  static const joinGroup = "Join Group";
  static const noMembersYet = "No members yet";
  static const noMembersYetMsg = "Invite people to join this group";
  static const muted = "Muted";
  static const muteDuration = "Mute Duration";
  static const muteFor1Hour = "1 Hour";
  static const muteFor8Hours = "8 Hours";
  static const muteFor1Day = "1 Day";
  static const muteForever = "Until I unmute";
  static const confirmLeaveGroup = "Are you sure you want to leave this group?";
  static const confirmDeleteGroup =
      "Are you sure you want to permanently delete this group? This cannot be undone.";
  static const confirmKickMember =
      "Are you sure you want to remove this member from the group?";
  static const confirmTransferOwnership =
      "Are you sure you want to transfer ownership? You will become an admin.";
  static const groupCreated = "Group created";
  static const groupUpdated = "Group updated";
  static const groupDeleted = "Group deleted";
  static const leftGroup = "You left the group";
  static const ownershipTransferred = "Ownership transferred";
  static const groupNameRequired = "Group name is required";
  static const saveChanges = "Save Changes";
  static const inviteLink = "Invite Link";

  // Group chat (Phase 7 part B)
  static const typeMessage = "Type a message";
  static const replyingTo = "Replying to";
  static const readBy = "Read by";
  static const onlyAdminsPostHint = "Only admins can post in this group";
  static const sysMemberJoined = "joined the group";
  static const sysMemberLeft = "left the group";
  static const sysMemberKicked = "was removed from the group";
  static const sysMemberPromoted = "is now an admin";
  static const sysMemberDemoted = "is no longer an admin";
  static const sysMemberMuted = "was muted";
  static const sysGroupRenamed = "Group name was changed";
  static const sysAvatarChanged = "Group photo was changed";
  static const sysOwnerTransferred = "is now the group owner";

  // ─── Theme2 Home Strings ───────────────────────────────────────
  static const String theme2Trending = "Trending";
  static const String theme2Related = "Related";
  static const String theme2Recommend = "Recommend";
  static const String theme2Party = "Party";
  static const String theme2Broadcast = "Broadcast";
  static const String theme2NewUser = "New User";
  static const String theme2All = "All";
  static const String theme2Joined = "Joined";
  static const String theme2MyFollowing = "My Following";
  static const String theme2Recently = "Recently";
  static const String theme2CreateRoom = "Create Room";
  static const String theme2StartJourney = "Start your journey now";
  static const String theme2CreateNow = "Create Now";
  static const String theme2Empty = "Empty";
  static const String theme2Game = "Game";
  static const String theme2P = "2P";
  static const String theme2Singing = "Singing";
  static const String theme2Mic = "mic";
  static const String theme2More = "More";
  static const relationships = "Relationships";
  static const keeping = "Keeping";
  static const giftWall = "Gift Wall";

  // Start-a-show hub (Theme2)
  static const String theme2StartShow = "Start a Show";
  static const String theme2EnterLive = "Enter Live";
  static const String theme2NoShowYet = "Not created yet";

  // Daily tasks
  static const String taskCollect = "Collect";
  static const String taskCollected = "Collected";
  static const String taskPoints = "Points";
  static const String taskMyPoints = "My points";
  static const String taskDayNumber = "Day";
  static const String taskNoTasksTitle = "No tasks yet";
  static const String taskNoTasksSubtitle =
      "New daily tasks will appear here soon";
  static const String taskDayReward = "Day reward";
  static const String taskDayCompleted = "Day completed";
  static const String taskCoinsEarned = "coins";

  // Device music picker (party room)
  static const String musicPermissionTitle = "Music access needed";
  static const String musicPermissionMessage =
      "Allow access to your audio files to pick a song from this phone";
  static const String noSongsFound = "No songs on this phone";
  static const String noSongsFoundMessage =
      "Download or copy some music to your phone first";
  static const String songFileMissing =
      "That file no longer exists on this phone";
  static const String clearAll = "Clear all";
  static const String musicAdded = "Music added";
  static const String musicAddFailed = "Could not add the music";
  static const String musicAddPartial = "failed";

  // End-of-session summary (party room and live)
  static const String sessionEnded = "Session ended";
  static const String sessionDuration = "Duration";
  static const String sessionViewers = "Viewers";
  static const String sessionCoins = "Coins";
  static const String sessionFollowers = "New followers";
  static const String sessionTopGifters = "Top supporters";
  // ───────────────────────────────────────────────────────────────

  // ─── Screens that used to hardcode their copy ──────────────────
  // The value of each constant IS the English string: `_en` is empty, so
  // easy_localization falls back to the key. Every one of these also has an
  // entry in `_ar` (locale_keys.g.dart), so Arabic is unchanged.

  // Reels / short video
  static const String reelPreparingVideo = "Preparing video…";
  static const String reelSaveFailed = "Couldn't save the video";
  static const String reelSaveVideo = "Save video";

  // Relative time labels (chats list, chat header, profile)
  static const String timeNow = "Now";
  static const String timeMinutesAgo = "{minutes} min ago";
  static const String timeYesterday = "Yesterday";
  static const String lastSeenAt = "Last seen {time}";

  // Inline text / lazy media
  static const String readMore = "Read more";
  static const String tapToLoadImage = "Tap to load image";

  // Invite sharing (system share sheet)
  static const String inviteGreeting = "Hi {name}! ";
  static const String inviteShareMessage =
      "Join me on {app}! Download the app here: {link}";

  // Chats
  static const String chatsSection = "Chats";
  static const String searchByNameOrMessage = "Search by name or in messages";
  static const String noResults = "No results";
  static const String blockUser = "Block User";
  static const String blockUserConfirm =
      "This user will no longer be able to message you. Continue?";
  static const String reportUser = "Report User";
  static const String clearConversation = "Clear Conversation";

  // Media settings
  static const String mediaSettings = "Media Settings";
  static const String autoDownload = "Auto-Download";
  static const String autoSaveMediaToDevice =
      "Save media to this device automatically";
  static const String autoSaveMediaOn = "Photos and clips download on their own";
  static const String autoSaveMediaOff =
      "You have to tap media to download it (uses less data)";
  static const String whenToAutoDownload = "When to auto-download";
  static const String autoDownloadAlways = "Always";
  static const String autoDownloadAlwaysHint = "Wi-Fi + mobile data";
  static const String autoDownloadWifiOnly = "Wi-Fi only";
  static const String autoDownloadWifiOnlyHint = "Saves mobile data";
  static const String autoDownloadMobileOnly = "Mobile data only";
  static const String autoDownloadMobileOnlyHint = "Useful when Wi-Fi is limited";

  // Groups (additions to the block above)
  static const String viewGroupInfo = "View group info";
  static const String discoverPublicGroups = "Discover public groups";
  static const String groupNoLongerExists = "This group no longer exists";
  static const String noInviteLinkForGroup = "This group has no invite link";
  static const String inviteLinkCopied = "Invite link copied";
  static const String confirmLeaveNamedGroup =
      'Are you sure you want to leave "{name}"?';
  static const String leaveAction = "Leave";
  static const String editGroup = "Edit Group";
  static const String copyInviteLink = "Copy Invite Link";
  static const String leaveGroupFailed = "Couldn't leave the group";
  static const String publicGroupLabel = "Public group";
  static const String youAreOwner = "You're the owner";
  static const String youAreAdmin = "You're an admin";
  static const String membersHiddenInPublicGroups =
      "The member list is hidden in public groups";
  static const String couldNotLoadMembers = "Couldn't load members";
  static const String publicGroupsTitle = "Public Groups";
  static const String noPublicGroups = "No public groups";
  static const String noPublicGroupsHint =
      "Try again later, or search for another name";

  // Room / visitor profile
  static const String specialMicSeatEffect = "Special mic-seat effect";
  static const String gifImagesNotAllowed = "GIF images are not allowed";
  static const String giftsSent = "Gifts Sent";
  // Event feed. An empty list is the normal state on a fresh deployment,
  // so the copy names the panel screen that fills it rather than implying a
  // fault.
  static const String noEventsHint =
      "Events added from the admin panel appear here.";
// ───────────────────────────────────────────────────────────────
}