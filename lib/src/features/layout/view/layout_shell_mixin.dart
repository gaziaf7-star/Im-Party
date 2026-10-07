import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/video_cache_manager.dart';
import 'package:general/src/core/widgets/update_dialog.dart';
import 'package:general/src/features/agency/data/model/host_requests_model.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/host_requests_manager/host_requests_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';

/// Behaviour shared verbatim by every layout shell (the default [LayoutPage] and
/// the [Theme2LayoutPage]). Both shells used to carry byte-identical copies of
/// this logic; it now lives here so the two shells stay in lockstep and the
/// later phases can collapse them into one.
///
/// Pure extraction — no behaviour change. Mix in AFTER [WidgetsBindingObserver]:
/// `class _State extends State<X> with WidgetsBindingObserver, LayoutShellMixin<X>`.
mixin LayoutShellMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  /// Guards the host-request dialog so it is shown at most once at a time.
  bool isDialogVisible = false;

  /// The UI variant this shell was built with. If a config reload picks up a
  /// different variant from the panel, we re-navigate to [Routes.layout] so
  /// onGenerateRoute re-evaluates and the correct shell/home renders live —
  /// otherwise the change is invisible until a full cold relaunch.
  final String builtVariant = ConstantsManager.appUiVariant;
  bool isRebuildingForVariant = false;

  /// Re-navigates to [Routes.layout] when the admin-panel variant changed since
  /// this shell mounted, so the correct shell is rebuilt live.
  void reactToVariantChange() {
    if (isRebuildingForVariant) return;
    if (ConstantsManager.appUiVariant == builtVariant) return;
    isRebuildingForVariant = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navContext = SafeNavigator.context;
      if (navContext == null) {
        isRebuildingForVariant = false;
        return;
      }
      navContext.pushNamedAndRemoveUntil(Routes.layout);
    });
  }

  /// Shows the force/optional update dialog when the backend reports the app is
  /// not on the latest version.
  void checkForUpdate() {
    final configState = di<ConfigAppBloc>().state;
    if (configState.requestState.isLoaded &&
        configState.config?.isLastVersion != true) {
      showDialog(
        context: context,
        barrierDismissible: !(configState.config?.isForce ?? false),
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => PopScope(
          canPop: false,
          child: ForceUpdateDialog(
            description: StringManager.updatDesc.tr(),
            isOptionalUpdate: !(configState.config?.isForce ?? false),
            onConfirm: () => Methods.openUrl(ConstantsManager.appURL),
          ),
        ),
      );
    }
  }

  /// Common [HostRequestsBloc] listener body: surface a pending host request
  /// once, and toast the result of an accept/reject action.
  void handleHostRequestsState(HostRequestsState state, BuildContext context) {
    if (state.getListStatus.isLoaded) {
      if ((state.hostRequestsModel ?? []).isNotEmpty && !isDialogVisible) {
        isDialogVisible = true;
        showHostRequestDialog(state.hostRequestsModel![0], context);
      }
    }
    if (state.makeActionStatus.isLoaded) {
      Methods.showToast(context, message: state.message ?? '');
    } else if (state.makeActionStatus.isError) {
      Methods.showToast(context, message: state.message ?? '', isError: true);
    }
  }

  /// The host withdrawal/request approval dialog (payment method + USD + bill
  /// image), with the confirm action wired to [HostRequestsBloc].
  Future<void> showHostRequestDialog(
    HostRequestsModel data,
    BuildContext context,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AnimatedDialog(
        title: StringManager.hostRequest.tr(),
        onTap: () {
          di<HostRequestsBloc>().add(
            HostRequestActionEvent(id: data.id.toString(), answer: "confirm"),
          );
          Navigator.pop(context);
        },
        billText: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: "${StringManager.paymentMethod.tr()}: ",
                style: context.bodyMedium.w300),
            TextSpan(
                text: data.paymentGateway ?? "",
                style:
                    context.bodyMedium.w300.colorExt(ColorManager.primary)),
            TextSpan(
                text: "  ${StringManager.usd.tr()}: ",
                style: context.bodyMedium.w300),
            TextSpan(
                text: (data.usd ?? 0).toString(),
                style:
                    context.bodyMedium.w300.colorExt(ColorManager.primary)),
            TextSpan(
                text: '   ${StringManager.hostRequestHint.tr()}',
                style: context.bodyMedium.w300),
          ]),
          textAlign: TextAlign.center,
        ),
        child: ImageViewWidget(
          url: data.billImage ?? '',
          radius: 12.r,
          height: ScreenUtil().screenHeight * 0.15,
          width: ScreenUtil().screenWidth * 0.5,
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(AssetCacheManager().evictExpiredCache());
      unawaited(VideoAssetCacheManager().evictExpiredCache());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
