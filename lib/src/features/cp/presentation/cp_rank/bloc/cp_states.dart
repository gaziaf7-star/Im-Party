part of'cp_bloc.dart';


class CpStates extends Equatable {
  final CpEntity? usersRankFriendsCpD;
  final RequestState cpFriendsDState;
  final NetworkExceptions? cpFriendsDError;

  final CpEntity? usersRankFriendsCpW;
  final RequestState cpFriendsWState;
  final NetworkExceptions? cpFriendsWError;

  final CpEntity? usersRankFriendsCpM;
  final RequestState cpFriendsMState;
  final NetworkExceptions? cpFriendsMError;

  final CpEntity? usersRankBroCpD;
  final RequestState cpBroDState;
  final NetworkExceptions? cpBroDError;

  final CpEntity? usersRankBroCpW;
  final RequestState cpBroWState;
  final NetworkExceptions? cpBroWError;

  final CpEntity? usersRankBroCpM;
  final RequestState cpBroMState;
  final NetworkExceptions? cpBroMError;

  final CpEntity? usersRankLoveCpD;
  final RequestState cpLoveDState;
  final NetworkExceptions? cpLoveDError;

  final CpEntity? usersRankLoveCpW;
  final RequestState cpLoveWState;
  final NetworkExceptions? cpLoveWError;

  final CpEntity? usersRankLoveCpM;
  final RequestState cpLoveMState;
  final NetworkExceptions? cpLoveMError;


  final int index;

  const CpStates(
      {this.usersRankFriendsCpD,
        this.usersRankFriendsCpW,
        this.usersRankFriendsCpM,
        this.usersRankBroCpD,
        this.usersRankBroCpW,
        this.usersRankBroCpM,
        this.usersRankLoveCpD,
        this.usersRankLoveCpW,
        this.usersRankLoveCpM,

        this.cpFriendsDState = RequestState.idle,
        this.cpFriendsWState = RequestState.idle,
        this.cpFriendsMState = RequestState.idle,
        this.cpBroDState = RequestState.idle,
        this.cpBroWState = RequestState.idle,
        this.cpBroMState = RequestState.idle,
        this.cpLoveDState=RequestState.idle,
        this.cpLoveWState = RequestState.idle,
        this.cpLoveMState=RequestState.idle,

        this.cpFriendsDError,
        this.cpFriendsWError,
        this.cpFriendsMError,
        this.cpBroDError,
        this.cpBroWError,
        this.cpBroMError,
        this.cpLoveDError,
        this.cpLoveWError,
        this.cpLoveMError,
        this.index =0,
      });

  CpStates copyWith({
    CpEntity? usersRankFriendsCpD,
    RequestState? cpFriendsDState,
    NetworkExceptions? cpFriendsDError,

    CpEntity? usersRankFriendsCpW,
    RequestState? cpFriendsWState,
    NetworkExceptions? cpFriendsWError,

    CpEntity? usersRankFriendsCpM,
    RequestState? cpFriendsMState,
    NetworkExceptions? cpFriendsMError,

    CpEntity? usersRankBroCpD,
    RequestState? cpBroDState,
    NetworkExceptions? cpBroDError,

    CpEntity? usersRankBroCpW,
    RequestState? cpBroWState,
    NetworkExceptions? cpBroWError,

    CpEntity? usersRankBroCpM,
    RequestState? cpBroMState,
    NetworkExceptions? cpBroMError,

    CpEntity? usersRankLoveCpD,
    RequestState? cpLoveDState,
    NetworkExceptions? cpLoveDError,

    CpEntity? usersRankLoveCpW,
    RequestState? cpLoveWState,
    NetworkExceptions? cpLoveWError,

    CpEntity? usersRankLoveCpM,
    RequestState? cpLoveMState,
    NetworkExceptions? cpLoveMError,


    int? index,

  }) {
    return CpStates(
      usersRankFriendsCpD: usersRankFriendsCpD?? this.usersRankFriendsCpD,
      usersRankFriendsCpW: usersRankFriendsCpW ?? this.usersRankFriendsCpW,
      usersRankFriendsCpM: usersRankFriendsCpM ?? this.usersRankFriendsCpM,
      usersRankBroCpD: usersRankBroCpD ?? this.usersRankBroCpD,
      usersRankBroCpW: usersRankBroCpW ?? this.usersRankBroCpW,
      usersRankBroCpM: usersRankBroCpM ?? this.usersRankBroCpM,
      usersRankLoveCpD: usersRankLoveCpD ?? this.usersRankLoveCpD,
      usersRankLoveCpW: usersRankLoveCpW ?? this.usersRankLoveCpW,
      usersRankLoveCpM: usersRankLoveCpM ?? this.usersRankLoveCpM,
      index: index ?? this.index,
      cpFriendsDState: cpFriendsDState ?? this.cpFriendsDState,
      cpFriendsWState: cpFriendsWState ?? this.cpFriendsWState,
      cpFriendsMState: cpFriendsMState ?? this.cpFriendsMState,
      cpBroDState: cpBroDState ?? this.cpBroDState,
      cpBroWState: cpBroWState ?? this.cpBroWState,
      cpBroMState: cpBroMState??this.cpBroMState,
      cpLoveDState: cpLoveDState??this.cpLoveDState,
      cpLoveWState: cpLoveWState??this.cpLoveWState,
      cpLoveMState: cpLoveMState??this.cpLoveMState,
      cpFriendsDError: cpFriendsDError??this.cpFriendsDError,
      cpFriendsWError:cpFriendsWError??this.cpFriendsWError ,
      cpFriendsMError: cpFriendsMError?? this.cpFriendsMError,
      cpBroDError: cpBroDError??this.cpBroDError,
      cpBroWError: cpBroWError??this.cpBroWError,
      cpBroMError: cpBroMError ?? this.cpBroMError,
      cpLoveDError: cpLoveDError ?? this.cpLoveDError,
      cpLoveWError: cpLoveWError ?? this.cpLoveWError,
      cpLoveMError: cpLoveMError ?? this.cpLoveMError,
    );
  }

  @override
  List<Object?> get props => [
    usersRankFriendsCpD,
    usersRankFriendsCpW,
    usersRankFriendsCpM,
    usersRankBroCpD,
    usersRankBroCpW,
    usersRankBroCpM,
    usersRankLoveCpD,
    usersRankLoveCpW,
    usersRankLoveCpM,

    cpFriendsDState,
    cpFriendsWState,
    cpFriendsMState,
    cpBroDState,
    cpBroWState,
    cpBroMState,
    cpLoveDState,
    cpLoveWState,
    cpLoveMState,

    cpFriendsDError,
    cpFriendsWError,
    cpFriendsMError,
    cpBroDError,
    cpBroWError,
    cpBroMError,
    cpLoveDError,
    cpLoveWError,
    cpLoveMError,
    index,
  ];
}
