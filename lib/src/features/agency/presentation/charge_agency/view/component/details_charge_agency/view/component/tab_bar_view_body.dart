part of 'package:general/src/features/agency/presentation/charge_agency/view/component/details_charge_agency/view/details_charge_agency_screen.dart';

class _TabBarViewBody extends StatelessWidget {
  const _TabBarViewBody({
    this.data,
    required this.scrollController,
    required this.type,
  });

  final List<DetailsChargeAgencyModel>? data;
  final ScrollController scrollController;
  final bool type;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: ColorManager.primary,
      backgroundColor: ColorManager.scaffoldBg,
      onRefresh: () async {
        final bloc = di<GetChargeAgencyDetailsBloc>();
        if (type) {
          bloc.add(const ClearDataReceiverEvent());
          bloc.add(const GetChargeAgencyDetailsReceiverEvent());
        } else {
          bloc.add(const ClearDataSenderEvent());
          bloc.add(const GetChargeAgencyDetailsSenderEvent());
        }
      },
      child: ListView.builder(
        padding: context.paddingSymmetric(horizontal: 0, vertical: 5),
        controller: scrollController,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: data?.length ?? 0,
        itemBuilder: (context, index) {
          final item = data?[index];
          return _CustomRowData(
            model: item,
            uuid: type == true
                ? (item?.senderEntity?.uuid ?? "").toString()
                : (item?.receiverEntity?.uuid ?? "").toString(),
            id: type == true
                ? (item?.senderEntity?.id ?? "").toString()
                : (item?.receiverEntity?.id ?? "").toString(),
            imageColorEntity: type == true
                ? (item?.senderEntity?.imageColorEntity)
                : (item?.receiverEntity?.imageColorEntity),
            idImage: type == true
                ? (item?.senderEntity?.idImage ?? "").toString()
                : (item?.receiverEntity?.idImage ?? "").toString(),
            coloredName: type == true
                ? (item?.senderEntity?.colorNamed ?? "").toString()
                : (item?.receiverEntity?.colorNamed ?? "").toString(),
            img: type == true
                ? (item?.senderEntity?.img ?? "")
                : (item?.receiverEntity?.img ?? ""),
            name: type == true
                ? (item?.senderEntity?.name ?? "")
                : (item?.receiverEntity?.name ?? ""),
            date: item?.time ?? "",
            value: item?.value ?? 0,
            stringValue: item?.stringValue ?? '0',
            type: type,
            isAgency: type == true
                ? (item?.senderEntity?.type == 'agency')
                : (item?.receiverEntity?.type == 'agency'),
          );
        },
      ),
    );
  }
}
