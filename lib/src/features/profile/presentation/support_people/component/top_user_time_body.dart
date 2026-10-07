import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/support_people/component/others_users.dart';

import '../../../data/model/top_support.dart';
import 'first_sec_thr_users.dart';

class TopUserTimeBody extends StatelessWidget {
  final TopSupportModel? topSupport;
  final RequestState state;

  const TopUserTimeBody(
      {required this.topSupport,
      required this.state,
      super.key});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case RequestState.loaded:
        return Padding(
          padding: context.paddingSymmetric(horizontal: 0),
          child: SizedBox(
            height: ScreenUtil().screenHeight,
            child: Column(
              children: [
                120.hBox,
                Container(
                  height: 240.h,
                  padding: context.paddingSymmetric(horizontal: 7),
                  // decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //         image: AssetImage(AssetsManager.topSupportersBackground),
                  //         fit: BoxFit.fill,
                          
                  //         ),
                  //         ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //sec
                        if((topSupport?.topUser??[]).length>1)
                        FirstSecThrUsers(
                          userData: topSupport!.topUser[1],
                          height: 105.h,
                          topNumber: 2,
                          position: 0.h,
                          leftPosition: 0.h,
                          frameSize: 95.h,
                          bottomPosition: 0.h,
                        ),

                        // first
                        if((topSupport?.topUser??[]).isNotEmpty)
                        FirstSecThrUsers(
                          userData: topSupport!.topUser[0],
                          frameSize: 100.h,
                          topNumber: 1,
                          leftPosition: 0.h,
                          height: 115.h,
                          position: 0.h,
                          bottomPosition: 60.h,
                        ),
                        //third
                        if((topSupport?.topUser??[]).length>2)
                        FirstSecThrUsers(
                          userData: topSupport!.topUser[2],
                          height: 105.h,
                          topNumber: 3,
                          leftPosition: 0.h,
                          position: 0.h,
                          bottomPosition: 0.h,
                        ),
                      ]),
                ),
                if((topSupport?.otherUsers??[]).isNotEmpty)
                OthersUsers(
                  usersData: topSupport!.otherUsers,
                ),
              ],
            ),
          ),
        );
      default:
        {
          return const LoadingWidget();
        }
    }
  }
}
