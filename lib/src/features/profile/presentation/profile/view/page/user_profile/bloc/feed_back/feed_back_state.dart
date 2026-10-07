
import 'package:general/src/core/index.dart';

 class FeedBackState extends Equatable {
  final RequestState? requestState;
  final String message, selectedProblem;

  final List<String> problemTypes;

  const FeedBackState({
    this.requestState,
    this.message = '',
    this.selectedProblem = '',
    this.problemTypes = const [],
  });

  FeedBackState copyWith({
    RequestState? requestState,
    String? message,
    String? selectedProblem,
    String? imagePath,
    List<String>? problemTypes,
  }) {
    return FeedBackState(
      requestState: requestState,
      message: message ?? this.message,
      selectedProblem: selectedProblem ?? this.selectedProblem,
      problemTypes: problemTypes ?? this.problemTypes,
    );
  }

  @override
  List<Object?> get props => [
    requestState,
    message,
    selectedProblem,
    problemTypes,
  ];
}
