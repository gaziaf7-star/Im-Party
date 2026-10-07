part of 'ranking_bloc.dart';

class RankingStates extends Equatable {
  final RankingEntity? usersRankDD;
  final RequestState dDState;
  final NetworkExceptions? dDError;

  final RankingEntity? usersRankDh;
  final RequestState dhState;
  final NetworkExceptions? dhError;

  final RankingEntity? usersRankDW;
  final RequestState dWState;
  final NetworkExceptions? dWError;

  final RankingEntity? usersRankDM;
  final RequestState dMState;
  final NetworkExceptions? dMError;

  final RankingEntity? usersRankCD;
  final RequestState cDState;
  final NetworkExceptions? cDError;

  final RankingEntity? usersRankCh;
  final RequestState chState;
  final NetworkExceptions? chError;

  final RankingEntity? usersRankCW;
  final RequestState cWState;
  final NetworkExceptions? cWError;

  final RankingEntity? usersRankCM;
  final RequestState cMState;
  final NetworkExceptions? cMError;

  final RankingEntity? usersRankRh;
  final RequestState rhState;
  final NetworkExceptions? rhError;

  final RankingEntity? usersRankRD;
  final RequestState rDState;
  final NetworkExceptions? rDError;

  final RankingEntity? usersRankRW;
  final RequestState rWState;
  final NetworkExceptions? rWError;

  final RankingEntity? usersRankRM;
  final RequestState rMState;
  final NetworkExceptions? rMError;

  final RankingEntity? usersRankLh;
  final RequestState lhState;
  final NetworkExceptions? lhError;

  final RankingEntity? usersRankLD;
  final RequestState lDState;
  final NetworkExceptions? lDError;

  final RankingEntity? usersRankLW;
  final RequestState lWState;
  final NetworkExceptions? lWError;

  final RankingEntity? usersRankLM;
  final RequestState lMState;
  final NetworkExceptions? lMError;

  final RankingEntity? usersRankGh;
  final RequestState ghState;
  final NetworkExceptions? ghError;

  final RankingEntity? usersRankGD;
  final RequestState gDState;
  final NetworkExceptions? gDError;

  final RankingEntity? usersRankGW;
  final RequestState gWState;
  final NetworkExceptions? gWError;

  final RankingEntity? usersRankGM;
  final RequestState gMState;
  final NetworkExceptions? gMError;

  final List<AgencyRankingEntity>? usersRankAgencyH;
  final RequestState agencyHState;
  final NetworkExceptions? agencyHError;

  final List<AgencyRankingEntity>? usersRankAgencyD;
  final RequestState agencyDState;
  final NetworkExceptions? agencyDError;

  final List<AgencyRankingEntity>? usersRankAgencyW;
  final RequestState agencyWState;
  final NetworkExceptions? agencyWError;

  final List<AgencyRankingEntity>? usersRankAgencyM;
  final RequestState agencyMState;
  final NetworkExceptions? agencyMError;

  final int index;
  final int indexTimeLucky;
  final int indexTimeRoom;
  final int indexTimeSender;
  final int indexTimeReceiver;
  final int indexTimeAgency;

  final String imageRank;
  final String imageBackground;
  final Color backgroundColor;
  const RankingStates({
    this.usersRankCD,
    this.usersRankCM,
    this.usersRankLM,
    this.usersRankRM,
    this.usersRankCW,
    this.usersRankRW,
    this.usersRankLW,
    this.usersRankRD,
    this.usersRankLD,
    this.usersRankDD,
    this.usersRankDM,
    this.usersRankDW,
    this.usersRankDh,
    this.usersRankCh,
    this.usersRankRh,
    this.usersRankGh,
    this.usersRankLh,
    this.usersRankGD,
    this.usersRankGW,
    this.usersRankGM,
    this.usersRankAgencyH,
    this.usersRankAgencyD,
    this.usersRankAgencyW,
    this.usersRankAgencyM,
    this.cMState = RequestState.idle,
    this.cDState = RequestState.idle,
    this.cWState = RequestState.idle,
    this.dDState = RequestState.idle,
    this.dMState = RequestState.idle,
    this.dWState = RequestState.idle,
    this.dhState = RequestState.idle,
    this.chState = RequestState.idle,
    this.rhState = RequestState.idle,
    this.ghState = RequestState.idle,
    this.lhState = RequestState.idle,
    this.rDState = RequestState.idle,
    this.lDState = RequestState.idle,
    this.lWState = RequestState.idle,
    this.lMState = RequestState.idle,
    this.rMState = RequestState.idle,
    this.rWState = RequestState.idle,
    this.gWState = RequestState.idle,
    this.gDState = RequestState.idle,
    this.gMState = RequestState.idle,
    this.agencyHState = RequestState.idle,
    this.agencyDState = RequestState.idle,
    this.agencyWState = RequestState.idle,
    this.agencyMState = RequestState.idle,
    this.cDError,
    this.cMError,
    this.cWError,
    this.dDError,
    this.dMError,
    this.dWError,
    this.lWError,
    this.lMError,
    this.lDError,
    this.rDError,
    this.rWError,
    this.rMError,
    this.chError,
    this.dhError,
    this.rhError,
    this.ghError,
    this.lhError,
    this.gMError,
    this.gWError,
    this.gDError,
    this.agencyHError,
    this.agencyDError,
    this.agencyWError,
    this.agencyMError,
    this.index = 0,
    this.indexTimeReceiver = 0,
    this.indexTimeSender = 0,
    this.indexTimeRoom = 0,
    this.indexTimeLucky = 0,
    this.indexTimeAgency = 0,
    this.imageRank = AssetsManager.backgroundCharmRAnk,
    this.imageBackground = AssetsManager.senderBackgroundRank,
    this.backgroundColor = const Color(0xffBC8D28),
  });

  RankingStates copyWith({
    RankingEntity? usersRankDh,
    RequestState? dhState,
    NetworkExceptions? dhError,
    RankingEntity? usersRankDD,
    RequestState? dDState,
    NetworkExceptions? dDError,
    RankingEntity? usersRankDW,
    RequestState? dWState,
    NetworkExceptions? dWError,
    RankingEntity? usersRankDM,
    RequestState? dMState,
    NetworkExceptions? dMError,
    RankingEntity? usersRankCh,
    RequestState? chState,
    NetworkExceptions? chError,
    RankingEntity? usersRankCD,
    RequestState? cDState,
    NetworkExceptions? cDError,
    RankingEntity? usersRankCW,
    RequestState? cWState,
    NetworkExceptions? cWError,
    RankingEntity? usersRankCM,
    RequestState? cMState,
    NetworkExceptions? cMError,
    RankingEntity? usersRankLh,
    RequestState? lhState,
    NetworkExceptions? lhError,
    RankingEntity? usersRankLD,
    RequestState? lDState,
    NetworkExceptions? lDError,
    RankingEntity? usersRankLW,
    RequestState? lWState,
    NetworkExceptions? lWError,
    RankingEntity? usersRankLM,
    RequestState? lMState,
    NetworkExceptions? lMError,
    RankingEntity? usersRankRh,
    RequestState? rhState,
    NetworkExceptions? rhError,
    RankingEntity? usersRankRD,
    RequestState? rDState,
    NetworkExceptions? rDError,
    RankingEntity? usersRankRW,
    RequestState? rWState,
    NetworkExceptions? rWError,
    RankingEntity? usersRankRM,
    RequestState? rMState,
    NetworkExceptions? rMError,
    RankingEntity? usersRankGh,
    RequestState? ghState,
    NetworkExceptions? ghError,
    RankingEntity? usersRankGD,
    RequestState? gDState,
    NetworkExceptions? gDError,
    RankingEntity? usersRankGM,
    RequestState? gMState,
    NetworkExceptions? gMError,
    RankingEntity? usersRankGW,
    RequestState? gWState,
    NetworkExceptions? gWError,
    List<AgencyRankingEntity>? usersRankAgencyH,
    RequestState? agencyHState,
    NetworkExceptions? agencyHError,
    List<AgencyRankingEntity>? usersRankAgencyD,
    RequestState? agencyDState,
    NetworkExceptions? agencyDError,
    List<AgencyRankingEntity>? usersRankAgencyW,
    RequestState? agencyWState,
    NetworkExceptions? agencyWError,
    List<AgencyRankingEntity>? usersRankAgencyM,
    RequestState? agencyMState,
    NetworkExceptions? agencyMError,
    int? index,
    int? indexTimeLucky,
    int? indexTimeSender,
    int? indexTimeReceiver,
    int? indexTimeRoom,
    int? indexTimeAgency,
    String? imageRank,
    String? imageBackground,
    Color? backgroundColor,
  }) {
    return RankingStates(
      usersRankDD: usersRankDD ?? this.usersRankDD,
      usersRankDM: usersRankDM ?? this.usersRankDM,
      usersRankDW: usersRankDW ?? this.usersRankDW,
      usersRankCD: usersRankCD ?? this.usersRankCD,
      usersRankCM: usersRankCM ?? this.usersRankCM,
      usersRankCW: usersRankCW ?? this.usersRankCW,
      usersRankLW: usersRankLW ?? this.usersRankLW,
      usersRankLM: usersRankLM ?? this.usersRankLM,
      usersRankLD: usersRankLD ?? this.usersRankLD,
      usersRankRW: usersRankRW ?? this.usersRankRW,
      usersRankRM: usersRankRM ?? this.usersRankRM,
      usersRankRD: usersRankRD ?? this.usersRankRD,
      usersRankGD: usersRankGD ?? this.usersRankGD,
      usersRankGW: usersRankGW ?? this.usersRankGW,
      usersRankGM: usersRankGM ?? this.usersRankGM,
      usersRankAgencyD: usersRankAgencyD ?? this.usersRankAgencyD,
      usersRankAgencyW: usersRankAgencyW ?? this.usersRankAgencyW,
      usersRankAgencyM: usersRankAgencyM ?? this.usersRankAgencyM,
      chError: chError ?? this.chError,
      gDError: gDError ?? this.gDError,
      gWError: gWError ?? this.gWError,
      gMError: gMError ?? this.gMError,
      agencyDError: agencyDError ?? this.agencyDError,
      agencyWError: agencyWError ?? this.agencyWError,
      agencyMError: agencyMError ?? this.agencyMError,
      chState: chState ?? this.chState,
      agencyDState: agencyDState ?? this.agencyDState,
      agencyWState: agencyWState ?? this.agencyWState,
      agencyMState: agencyMState ?? this.agencyMState,
      usersRankCh: usersRankCh ?? this.usersRankCh,
      dhError: dhError ?? this.dhError,
      dhState: dhState ?? this.dhState,
      usersRankDh: usersRankDh ?? this.usersRankDh,
      usersRankRh: usersRankRh ?? this.usersRankRh,
      rhState: rhState ?? this.rhState,
      rhError: rhError ?? this.rhError,
      usersRankGh: usersRankGh ?? this.usersRankGh,
      ghState: ghState ?? this.ghState,
      ghError: ghError ?? this.ghError,
      usersRankLh: usersRankLh ?? this.usersRankLh,
      lhState: lhState ?? this.lhState,
      lhError: lhError ?? this.lhError,
      usersRankAgencyH: usersRankAgencyH ?? this.usersRankAgencyH,
      agencyHState: agencyHState ?? this.agencyHState,
      agencyHError: agencyHError ?? this.agencyHError,
      dDState: dDState ?? this.dDState,
      dMState: dMState ?? this.dMState,
      dWState: dWState ?? this.dWState,
      cDState: cDState ?? this.cDState,
      cMState: cMState ?? this.cMState,
      cWState: cWState ?? this.cWState,
      dDError: dDError ?? this.dDError,
      dMError: dMError ?? this.dMError,
      dWError: dWError ?? this.dWError,
      cDError: cDError ?? this.cDError,
      cMError: cMError ?? this.cMError,
      cWError: cWError ?? this.cWError,
      lDState: lDState ?? this.lDState,
      lMState: lMState ?? this.lMState,
      lWState: lWState ?? this.lWState,
      rDState: rDState ?? this.rDState,
      rMState: rMState ?? this.rMState,
      rWState: rWState ?? this.rWState,
      gDState: gDState ?? this.gDState,
      gWState: gWState ?? this.gWState,
      gMState: gMState ?? this.gMState,
      index: index ?? this.index,
      indexTimeReceiver: indexTimeReceiver ?? this.indexTimeReceiver,
      indexTimeSender: indexTimeSender ?? this.indexTimeSender,
      indexTimeRoom: indexTimeRoom ?? this.indexTimeRoom,
      indexTimeLucky: indexTimeLucky ?? this.indexTimeLucky,
      indexTimeAgency: indexTimeAgency ?? this.indexTimeAgency,
      imageRank: imageRank ?? this.imageRank,
      imageBackground: imageBackground ?? this.imageBackground,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  List<Object?> get props => [
        usersRankDh,
        dhState,
        dhError,
        usersRankCh,
        chState,
        chError,
        usersRankRh,
        rhState,
        rhError,
        usersRankGh,
        ghState,
        ghError,
        usersRankLh,
        lhState,
        lhError,
        usersRankAgencyH,
        agencyHState,
        agencyHError,
        usersRankDD,
        dDState,
        dDError,
        usersRankDW,
        dWState,
        dWError,
        usersRankDM,
        dMState,
        dMError,
        usersRankCD,
        cDState,
        cDError,
        usersRankCW,
        cWState,
        cWError,
        usersRankCM,
        cMState,
        cMError,
        usersRankLD,
        lDState,
        lDError,
        usersRankLW,
        lWState,
        lWError,
        usersRankLM,
        lMState,
        lMError,
        usersRankRD,
        rDState,
        rDError,
        usersRankRW,
        rWState,
        rWError,
        usersRankRM,
        rMState,
        rMError,
        usersRankAgencyD,
        agencyDState,
        agencyDError,
        usersRankAgencyW,
        agencyWState,
        agencyWError,
        usersRankAgencyM,
        agencyMState,
        agencyMError,
        index,
        indexTimeLucky,
        indexTimeReceiver,
        indexTimeSender,
        indexTimeRoom,
        indexTimeAgency,
        imageRank,
        imageBackground,
        backgroundColor,
        gDError,
        gDState,
        usersRankGD,
        gWError,
        gWState,
        usersRankGW,
        gMError,
        gMState,
        usersRankGM,
      ];
}
