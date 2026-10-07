import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/home/data/model/room_model.dart';


class GetFamilyRoomsUC extends UseCaseWithParams<BaseResponse<List<RoomModel>>,String>{
  final BaseFamilyRepository baseFamilyRepository;
const GetFamilyRoomsUC({required this.baseFamilyRepository});
  @override
  ResultFuture<BaseResponse<List<RoomModel>>> call(String params) async{
    final result =await baseFamilyRepository.fetchFamilyRoom(params);
return result;
  }



}