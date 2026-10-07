import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/agency/domain/entity/hosts_agency_dollars_records_entity.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/hosts_agency_dollars_records/hosts_agency_dollars_records_bloc.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';

class HostsAgencyDollarsRecordsScreen extends StatefulWidget {
  const HostsAgencyDollarsRecordsScreen({super.key});

  @override
  State<HostsAgencyDollarsRecordsScreen> createState() =>
      _HostsAgencyDollarsRecordsScreenState();
}

class _HostsAgencyDollarsRecordsScreenState
    extends State<HostsAgencyDollarsRecordsScreen>
    with SingleTickerProviderStateMixin {
  final _detailsBloc = di<HostsAgencyDollarsRecordsBloc>();

  @override
  void initState() {
    if (_detailsBloc.state.senderState != RequestState.loaded) {
      _detailsBloc
          .add(const GetSenderHostsAgencyRecordsEvent(isFirstLoading: true));
    }
    _detailsBloc.add(SenderAddListenerEvent());
    _detailsBloc.add(SenderRemoveListenerEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBgAlt,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.scaffoldBg,
        title: StringManager.record.tr(),
        titleStyle: context.bodyLarge.w600.colorExt(ColorManager.textPrimary),
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: BlocBuilder<HostsAgencyDollarsRecordsBloc,
                HostsAgencyDollarsRecordsState>(
              bloc: _detailsBloc,
              buildWhen: (prev, curr) =>
                  prev.senderState != curr.senderState ||
                  prev.senderData != curr.senderData,
              builder: (context, state) {
                return HandlingDataWidget(
                  reqState: state.senderState,
                  title: StringManager.noDetailsReportsTitle.tr(),
                  subTitle: StringManager.noDetailsReportsSubTitle.tr(),
                  onTap: () {
                    _detailsBloc.add(const GetSenderHostsAgencyRecordsEvent());
                  },
                  child: _TabBarViewBody(
                    scrollController: state.senderScrollCtrl,
                    data: state.senderData,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarViewBody extends StatelessWidget {
  const _TabBarViewBody({
    this.data,
    required this.scrollController,
  });

  final List<HostsAgencyDollarsRecordsEntity>? data;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: ColorManager.primary,
      backgroundColor: ColorManager.scaffoldBg,
      onRefresh: () async {
        final bloc = di<HostsAgencyDollarsRecordsBloc>();
        bloc.add(const GetSenderHostsAgencyRecordsEvent());
      },
      child: ListView.builder(
        padding: context.paddingSymmetric(horizontal: 0, vertical: 5),
        controller: scrollController,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: data?.length ?? 0,
        itemBuilder: (context, index) {
          return _CustomRowData(
            id: data?[index].receiverEntity?.uuid ?? "",
            img: data?[index].receiverEntity?.img ?? "",
            name: data?[index].receiverEntity?.name ?? "",
            coloredName: data?[index].receiverEntity?.colorNamed ?? "",
            date: data?[index].time ?? "",
            value: data?[index].value ?? 0,
            stringValue: data?[index].stringValue ?? '0',
            type: data?[index].isSender ?? false,
            typeOfCharge: data?[index].receiverEntity?.type,
            idImage: (data?[index].receiverEntity?.type == 'user')
                ? (data?[index].receiverEntity?.idImage ?? '')
                : null,
            imageColorEntity: data?[index].receiverEntity?.type == 'user'
                ? (data?[index].receiverEntity?.imageColorEntity ??
                    const ImageColorEntity())
                : null,
          );
        },
      ),
    );
  }
}

class _CustomRowData extends StatelessWidget {
  const _CustomRowData({
    required this.img,
    required this.type,
    required this.name,
    required this.id,
    required this.value,
    required this.stringValue,
    required this.date,
    required this.typeOfCharge,
    required this.idImage,
    required this.imageColorEntity,
    required this.coloredName,
  });

  final String? img;
  final String? id;
  final String? name;
  final int? value;
  final String? stringValue;
  final String? date;
  final String? typeOfCharge;
  final String? idImage;
  final String? coloredName;
  final ImageColorEntity? imageColorEntity;
  final bool type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 15, vertical: 5),
      margin: context.paddingSymmetric(vertical: 5, horizontal: 7),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: 15.radius,
        border: Border.all(
          color: ColorManager.transparent,
        ),
      ),
      width: ScreenUtil().screenWidth,
      child: Row(
        children: [
          Row(
            children: [
              SizedBox(
                height: 55.h,
                width: 55.w,
                child: ImageViewWidget(
                  url: EndPoints.getImage(img ?? ''),
                  displayName: name ?? '',
                  height: 55.h,
                  width: 55.w,
                  radius: typeOfCharge == 'agency' ? 0 : 60,
                ),
              ),
              10.wBox,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientTextVip(
                    isVip: coloredName != "",
                    width: ScreenUtil().screenWidth * 0.5,
                    text: name ?? "",
                    color: Methods.safeHexColor(coloredName) ??
                        ColorManager.textPrimary,
                    mainAxisAlignment: MainAxisAlignment.center,
                    textAlign: TextAlign.center,
                    textStyle: context.bodyMedium.size(14).w600.colorExt(
                          Methods.safeHexColor(coloredName) ??
                              ColorManager.textPrimary,
                        ),
                  ),
                  7.hBox,
                  IdWithCopyIcon(
                    userId: id ?? "",
                    idStyle: context.bodyMedium.size(12).colorExt(
                        ColorManager.secondaryText),
                    idColor: ColorManager.secondaryText,
                    isNeedCopyIcon: true,
                    isSpecial: ((idImage ?? '') != ''),
                    specialImg: idImage ?? '',
                    color: imageColorEntity?.color,
                    img: imageColorEntity?.image,
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                  TextWidget(
                    Methods.formatTime(date ?? ""),
                    style: context.bodyMedium.size(12).colorExt(
                        ColorManager.secondaryText),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 20.h,
            width: 50.w,
            decoration: BoxDecoration(
              color: type
                  ? (Colors.green.withValues(alpha: 0.2))
                  : (Colors.red.withValues(alpha: 0.2)),
              borderRadius: 3.radius,
            ),
            child: Center(
              child: FittedBox(
                child: TextWidget(
                  Methods().convertToAbbreviatedString(value ?? 0).toString(),
                  style: context.bodyMedium.size(16).bold.colorExt(
                        type ? Colors.green : Colors.red,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
