// import 'package:equatable/equatable.dart';

// abstract class EmojieEvents extends Equatable {
//   const EmojieEvents();

//   @override
//   List<Object?> get props => [];
// }

// class GetEmojieEvent extends EmojieEvents {
//   const GetEmojieEvent();
// }

// class FetchEmojisCategoryEvent extends EmojieEvents {
//   const FetchEmojisCategoryEvent();
// }

import 'package:equatable/equatable.dart';

abstract class EmojieEvents extends Equatable {
  const EmojieEvents();

  @override
  List<Object?> get props => [];
}

// Generic event for any emoji category
class FetchEmojisByCategoryEvent extends EmojieEvents {
  final int categoryId; // Use ID as key
  final int typeId; // The API type ID
  
  const FetchEmojisByCategoryEvent({
    required this.categoryId,
    required this.typeId,
  });

  @override
  List<Object?> get props => [categoryId, typeId];
}

// Event to fetch emoji categories from backend
class FetchEmojisCategoryEvent extends EmojieEvents {
  const FetchEmojisCategoryEvent();

  @override
  List<Object?> get props => [];
}