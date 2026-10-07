import '../../../../core/index.dart';
import '../../profile.dart';

class GetBillHistoryUC extends UseCaseWithParams <BaseResponse<List<BillModel>>,BillParam> {
 final ProfileBaseRepository _repo;
 const GetBillHistoryUC(this._repo);

  @override
  ResultFuture <BaseResponse<List<BillModel>>> call( BillParam params) async {
    final result = await _repo.fetchBill(param: params);
    return result;
  }
}