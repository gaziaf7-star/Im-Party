import '../../../../../../core/index.dart';
import '../../../../family.dart';

class DeleteScreen extends StatelessWidget {
  final String familyId ;
  const DeleteScreen({
    required this.familyId,

    super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteFamilyBloc, DeleteFamilyState>(
      bloc: di<DeleteFamilyBloc>(),
      buildWhen: (prev, curr) => false,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: ColorManager.transparent,
            centerTitle: true,
            title: Text(StringManager.deleteFamily.tr()),
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                size:25.w,
                Icons.arrow_back_ios,
              ),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                AssetsManager.emptyFamily,
                width: MediaQuery.of(context).size.width,
                height: 400.h,
                color: Colors.red,
              ),
              SizedBox(
                width: 269.w,
                child: Text(
                  StringManager.areYouSureDeleteFamily.tr(),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: context.bodyMedium.w600.size(20).colorExt(Colors.red,),
                ),
              ),
              40.hBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ButtonWidget(
                    onPressed: () {
                      di<DeleteFamilyBloc>()
                          .add( DeleteFamilyEvent(id: familyId.toString()));
                    },
                    title: StringManager.yes.tr(),
                    backgroundColor: Colors.red.shade500,
                    width: 150.w,
                    height: 50.h,
                    radius: 4,
                    borderColor: ColorManager.black,
                  ),
                  ButtonWidget(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: StringManager.no.tr(),
                    backgroundColor: ColorManager.transparent,
                    width: 150.w,
                    height: 50.h,
                    radius: 4,
                    borderColor: ColorManager.black,
                    titleColor: ColorManager.blackColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
