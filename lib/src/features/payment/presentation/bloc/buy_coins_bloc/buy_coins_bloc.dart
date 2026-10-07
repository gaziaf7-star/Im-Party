import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/domain/use_case/buy_coins_use_case.dart';
import 'package:general/src/features/payment/domain/use_case/redirect_link_use_case.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_event.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_state.dart';
import 'package:general/src/features/payment/presentation/view/in_app_purchases.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyCoinsBloc extends Bloc<BaseBuyCoinsEvent, BuyCoinsState> {
  final BuyCoinsUseCase buyCoinsUseCase;
  final RedirectLinkUseCase redirectLinkUseCase;

  BuyCoinsBloc({
    required this.buyCoinsUseCase,
    required this.redirectLinkUseCase,
  }) : super(const BuyCoinsState()) {
    on<BuyCoinsEvent>((event, emit) async {
      emit(state.copyWith(reqState: RequestState.loading));
      final result = await buyCoinsUseCase(
          BuyCoinsParam(method: event.method, productId: event.productId));

      result.fold(
        (left) {
          emit(
            state.copyWith(
                error: NetworkExceptions.getErrorMessage(left),
                reqState: handleErrorResponse(left)),
          );
          Methods.showToast(event.context, message: state.error, isError: true);
        },
        (right) async {
          emit(
            state.copyWith(
              data: right.data,
              reqState: handleLoadedResponse<String>(right.data),
            ),
          );
          // The backend doesn't always send a redirect link back -- for a
          // Google Play package it instead replies with this exact message
          // and `data` holding the bare product id, meaning "now start the
          // native Play Store purchase for this id" rather than "open this
          // URL". Previously that bare id (e.g. "2") failed the http/https
          // check below and unconditionally showed "Something went wrong",
          // even though the purchase was never actually attempted.
          if (right.message == 'Ready for Google Play purchase') {
            final wantedId = right.data.toString();
            // "2", "coin_2" and "iamparty_coin_2" all mean the same package.
            String bare(String id) =>
                id.replaceFirst(RegExp(r'^(iamparty_)?(coin_)?'), '');
            ProductDetails? findMatch(List<ProductDetails> products) =>
                products.where((p) => p.id == wantedId).firstOrNull ??
                products.where((p) => bare(p.id) == bare(wantedId)).firstOrNull;

            var product = findMatch(
                di<PurchaseService>().result?.productDetails ?? []);


            if (product == null) {
              final available =
                  await di<PurchaseService>().checkAvailability();
              Methods.printLog(
                '🛒 [IAP] no cached match for "$wantedId" -- billingAvailable=$available, querying Play directly',
              );
              if (!available) {
                Methods.showToast(
                  event.context,
                  message:
                      'Google Play billing is not available on this device/build.',
                  isError: true,
                );
                return;
              }
              try {
                // Timed -- confirmed this can hang indefinitely with no
                // error and no result on a build/device where billing
                // never actually connects, silently stalling this handler
                // forever instead of failing visibly.
                final live = await di<PurchaseService>()
                    .connection
                    .queryProductDetails({
                  wantedId,
                  bare(wantedId),
                  'coin_${bare(wantedId)}',
                  'iamparty_coin_${bare(wantedId)}',
                }).timeout(const Duration(seconds: 12));
                Methods.printLog(
                  '🛒 [IAP] live query ids=${live.productDetails.map((p) => p.id).toList()} '
                  'notFoundIDs=${live.notFoundIDs} error=${live.error?.message}',
                );
                product = findMatch(live.productDetails);
              } on TimeoutException {
                Methods.printLog('🛒 [IAP] live query timed out after 12s');
                Methods.showToast(
                  event.context,
                  message:
                      'Google Play did not respond. Check that Google Play Store is signed in and up to date on this device.',
                  isError: true,
                );
                return;
              } catch (e) {
                Methods.printLog('🛒 [IAP] live query threw: $e');
              }
            }

            if (product != null) {
              await di<PurchaseService>().buyProduct(product);
              return;
            }
            Methods.printLog(
              '🛒 [IAP] No matching Play Store product for "$wantedId" -- '
              'falling through to the URL-redirect path (will fail too).',
            );
          }
          final uri = Uri.tryParse(right.data.toString());
          final bool launched = uri != null &&
              (uri.isScheme('http') || uri.isScheme('https')) &&
              await canLaunchUrl(uri) &&
              await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!launched) {
            Methods.showToast(
              event.context,
              message: StringManager.someThingWentWrong.tr(),
              isError: true,
            );
          }
        },
      );
    });
    on<ChangeValueEvent>((event, emit) async {
      emit(state.copyWith(
          selectedTab: event.value,
          controllerIndex: event.controllerIndex,
          changeText: event.changeText));
    });

    on<RedirectLinkEvent>(
      (event, emit) async {
        emit(state.copyWith(reqStateRedirect: RequestState.loading));
        final result = await redirectLinkUseCase(event.link ?? '');

        result.fold(
          (left) {
            emit(
              state.copyWith(
                  errorRedirect: NetworkExceptions.getErrorMessage(left),
                  reqStateRedirect: handleErrorResponse(left)),
            );
          },
          (right) async {
            emit(
              state.copyWith(
                errorRedirect: right.data,
                reqStateRedirect: handleLoadedResponse<String>(right.data),
              ),
            );
          },
        );
      },
    );
  }
}
