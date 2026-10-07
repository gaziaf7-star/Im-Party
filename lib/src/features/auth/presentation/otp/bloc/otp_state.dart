part of 'otp_bloc.dart';

class OtpState extends Equatable {
  // final GlobalKey<FormState> key;
  final TextEditingController code;
  final Timer? timer;
  final int counter;
  final RequestState reqState;
  final String message;

  const OtpState({
   required this.code ,
   // required this.key ,
    this.reqState = RequestState.idle,
    this.message = '',
    this.timer,
    this.counter = 0,
  });

  OtpState copyWith({
    Timer? timer,
    int? counter,
    RequestState? reqState,
    String? message,
    String? code,
  }) {
    return OtpState(
      // key: key,
      timer: timer ?? this.timer,
      counter: counter ?? this.counter,
      reqState: reqState ?? this.reqState,
      message: message ?? this.message,
      code: this.code.copyWith(text: code),
    );
  }

  @override
  List<Object?> get props => [
        // key,
        timer,
        counter,
        message,
        message,
        code,
        reqState,
      ];
}
