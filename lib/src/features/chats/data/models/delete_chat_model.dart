import '../../../chats/chats.dart';

// DeleteChatModel
class DeleteChatModel extends DeleteChatEntity {
  const DeleteChatModel({super.files});

  factory DeleteChatModel.fromJson(Map<String, dynamic> json) {
    return DeleteChatModel(
      files: parseValue<List<String>>(json['midea'], []),
    );
  }

  @override
  List<Object?> get props => [
    files,
  ];
}
