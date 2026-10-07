import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';


class RemovePinChatToTopUC extends UseCaseWithParams<BaseResponse<String>,String>{

 final  BaseMessagesRepository _repo ;


 const RemovePinChatToTopUC( this._repo);

  @override
  ResultFuture<BaseResponse<String>> call( params) async {
    final result = await _repo.removePinChatToTop(userId: params);
    return result ;
  }


}
