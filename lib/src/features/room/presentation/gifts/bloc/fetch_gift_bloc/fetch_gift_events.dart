// import 'package:equatable/equatable.dart';

// abstract class FetchGiftEvent extends Equatable {
//   const FetchGiftEvent();
//   @override
//   List<Object?> get props => [];
// }

// class FetchAppGiftEvent extends FetchGiftEvent {
//   final int type;
//   const FetchAppGiftEvent({required this.type});

//   @override
//   List<Object?> get props => [type];
// }

// class FetchEventGiftEvent extends FetchGiftEvent {
//   final int type;
//   const FetchEventGiftEvent({required this.type});

//   @override
//   List<Object?> get props => [type];
// }

// class FetchLuckyGiftEvent extends FetchGiftEvent {
//   final int type;
//   const FetchLuckyGiftEvent({required this.type});

//   @override
//   List<Object?> get props => [type];
// }

// class FetchSpecialGiftEvent extends FetchGiftEvent {
//   final int type;
//   const FetchSpecialGiftEvent({required this.type});

//   @override
//   List<Object?> get props => [type];
// }

// class FetchMomentGiftEvent extends FetchGiftEvent {
//   final int type;
//   const FetchMomentGiftEvent({required this.type});

//   @override
//   List<Object?> get props => [type];
// }

// class FetchFamousGiftEvent extends FetchGiftEvent {
//   final int type;
//   const FetchFamousGiftEvent({required this.type});

//   @override
//   List<Object?> get props => [type];
// }

// class FetchCountryGiftEvent extends FetchGiftEvent {
//   final int type;
//   const FetchCountryGiftEvent({required this.type});

//   @override
//   List<Object?> get props => [type];
// }

// class FetchVipGiftEvent extends FetchGiftEvent {
//   final int type;
//   const FetchVipGiftEvent({required this.type});

//   @override
//   List<Object?> get props => [type];
// }
// class FetchBagGiftEvent extends FetchGiftEvent {
//   const FetchBagGiftEvent();

//   @override
//   List<Object?> get props => [];
// }

// class FetchGiftCategoryEvent extends FetchGiftEvent {
//   const FetchGiftCategoryEvent();

//   @override
//   List<Object?> get props => [];
// }

// import 'package:equatable/equatable.dart';

// abstract class FetchGiftEvent extends Equatable {
//   const FetchGiftEvent();
//   @override
//   List<Object?> get props => [];
// }

// // Generic event for any gift category
// class FetchGiftsByCategoryEvent extends FetchGiftEvent {
//   final String categoryType; // e.g., "normal", "event", "lucky", etc.
//   final int categoryId; // The API type ID

//   const FetchGiftsByCategoryEvent({
//     required this.categoryType,
//     required this.categoryId,
//   });

//   @override
//   List<Object?> get props => [categoryType, categoryId];
// }

// // Separate event for Bag (because it's special)
// class FetchBagGiftEvent extends FetchGiftEvent {
//   const FetchBagGiftEvent();

//   @override
//   List<Object?> get props => [];
// }

// // Event to fetch gift categories from backend
// class FetchGiftCategoryEvent extends FetchGiftEvent {
//   const FetchGiftCategoryEvent();

//   @override
//   List<Object?> get props => [];
// }

import 'package:equatable/equatable.dart';

abstract class FetchGiftEvent extends Equatable {
  const FetchGiftEvent();

  @override
  List<Object?> get props => [];
}

// Generic event for any gift category
class FetchGiftsByCategoryEvent extends FetchGiftEvent {
  final int categoryId; // Use ID as key instead of type
  final int typeId; // The API type ID

  const FetchGiftsByCategoryEvent({
    required this.categoryId,
    required this.typeId,
  });

  @override
  List<Object?> get props => [categoryId, typeId];
}

// Separate event for Bag (because it's special)
class FetchBagGiftEvent extends FetchGiftEvent {
  const FetchBagGiftEvent();

  @override
  List<Object?> get props => [];
}

// Event to fetch gift categories from backend
class FetchGiftCategoryEvent extends FetchGiftEvent {
  const FetchGiftCategoryEvent();

  @override
  List<Object?> get props => [];
}

class SearchGiftCategoryEvent extends FetchGiftEvent {
  final String keyWord;

  const SearchGiftCategoryEvent(this.keyWord);

  @override
  List<Object?> get props => [keyWord];
}
class SetCategoryIdEvent extends FetchGiftEvent {
  final int categoryId;

  const SetCategoryIdEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
