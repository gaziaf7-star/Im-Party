part of'../bill_page.dart';

class BillTabBarViewBody extends StatelessWidget {
  const BillTabBarViewBody({super.key,required this.billEntityList,required this.type});

  final List<BillEntity> billEntityList;
  final int type;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicatorWidget(
      onRefresh: ()async{
        if (type == 1) {
          di<BillBloc>().add(const GetBillGivingEvent(param: BillParam(
              type: 'givin'
          )));
        }
        if (type == 2) {
          di<BillBloc>().add(const GetBillReceivedEvent(param: BillParam(
              type: 'receving'
          )));
        }
        if (type == 3) {
          di<BillBloc>().add(const GetBillRechargeEvent(param: BillParam(
              type: 'recharge'
          )));
        }

      },
      child: ListView.builder(
          itemCount: billEntityList.length,
          padding: context.paddingSymmetric(horizontal: 10,vertical: 10),
          itemBuilder: (context,index){
        return BillItemRow(billEntityList: billEntityList[index],);
      }),
    );
  }
}
