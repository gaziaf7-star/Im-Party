import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/reaction_entity.dart';
import 'package:general/src/features/room/room.dart';

class EmojieState extends Equatable {
  // Dynamic emoji categories data - using ID as key
  final Map<int, List<EmojiEntity>> categoryEmojis;
  final Map<int, RequestState> categoryReqStates;
  final Map<int, String> categoryMessages;

  // Emoji categories from backend
  final List<ReactionEntity> categories;
  final RequestState reqStateEmojisCategory;
  final String msgEmojisCategory;

  const EmojieState({
    this.categoryEmojis = const {},
    this.categoryReqStates = const {},
    this.categoryMessages = const {},
    this.categories = const [],
    this.reqStateEmojisCategory = RequestState.idle,
    this.msgEmojisCategory = '',
  });

  EmojieState copyWith({
    Map<int, List<EmojiEntity>>? categoryEmojis,
    Map<int, RequestState>? categoryReqStates,
    Map<int, String>? categoryMessages,
    List<ReactionEntity>? categories,
    RequestState? reqStateEmojisCategory,
    String? msgEmojisCategory,
  }) {
    return EmojieState(
      categoryEmojis: categoryEmojis ?? this.categoryEmojis,
      categoryReqStates: categoryReqStates ?? this.categoryReqStates,
      categoryMessages: categoryMessages ?? this.categoryMessages,
      categories: categories ?? this.categories,
      reqStateEmojisCategory:
          reqStateEmojisCategory ?? this.reqStateEmojisCategory,
      msgEmojisCategory: msgEmojisCategory ?? this.msgEmojisCategory,
    );
  }

  // Helper methods - using ID
  List<EmojiEntity> getEmojisById(int id) {
    return categoryEmojis[id] ?? [];
  }

  RequestState getReqStateById(int id) {
    return categoryReqStates[id] ?? RequestState.loading;
  }

  String getMessageById(int id) {
    return categoryMessages[id] ?? "";
  }

  @override
  List<Object?> get props => [
        categoryEmojis,
        categoryReqStates,
        categoryMessages,
        categories,
        reqStateEmojisCategory,
        msgEmojisCategory,
      ];
}
