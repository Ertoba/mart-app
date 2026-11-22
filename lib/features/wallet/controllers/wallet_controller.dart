import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/models/transaction_model.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/payment/screens/keepz_native_payment_screen.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/wallet/domain/models/wallet_keepz_payment.dart';
import 'package:sixam_mart/features/wallet/domain/models/wallet_filter_body_model.dart';
import 'package:sixam_mart/features/wallet/domain/models/fund_bonus_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:universal_html/html.dart' as html;
import 'package:sixam_mart/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:sixam_mart/features/wallet/widgets/fund_status_dialog_widget.dart';

class WalletController extends GetxController implements GetxService {
  final WalletServiceInterface walletServiceInterface;
  WalletController({required this.walletServiceInterface});

  List<Transaction>? _transactionList;
  List<Transaction>? get transactionList => _transactionList;

  List<String> _offsetList = [];
  
  int _offset = 1;
  int get offset => _offset;
  
  int? _pageSize;
  int? get popularPageSize => _pageSize;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;
  
  bool _amountEmpty = true;
  bool get amountEmpty => _amountEmpty;
  
  List<FundBonusModel>? _fundBonusList;
  List<FundBonusModel>? get fundBonusList => _fundBonusList;
  
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  String _type = 'all';
  String get type => _type;
  
  List<WalletFilterBodyModel> _walletFilterList = [];
  List<WalletFilterBodyModel> get walletFilterList => _walletFilterList;

  void setWalletFilerType(String type, {bool isUpdate = true}) {
    _type = type;
    if(isUpdate) {
      update();
    }
  }

  void insertFilterList(){
    _walletFilterList = [];
    for(int i=0; i < AppConstants.walletTransactionSortingList.length; i++){
      _walletFilterList.add(WalletFilterBodyModel.fromJson(AppConstants.walletTransactionSortingList[i]));
    }
  }

  void changeDigitalPaymentName(String name, {bool isUpdate = true}){
    _digitalPaymentName = name;
    if(isUpdate) {
      update();
    }
  }

  void isTextFieldEmpty(String value, {bool isUpdate = true}){
    _amountEmpty = value.isNotEmpty;
    if(isUpdate) {
      update();
    }
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<void> getWalletTransactionList(String offset, bool reload, String walletType) async {
    if(offset == '1' || reload) {
      _offsetList = [];
      _offset = 1;
      _transactionList = null;
      if(reload) {
        update();
      }

    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      TransactionModel? transactionModel = await walletServiceInterface.getWalletTransactionList(offset, walletType);

      if (transactionModel != null) {
        if (offset == '1') {
          _transactionList = [];
        }
        _transactionList!.addAll(transactionModel.data!);
        _pageSize = transactionModel.totalSize;

        _isLoading = false;
        update();
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  Future<void> addFundToWallet(
    double amount,
    String paymentMethod, {
    BuildContext? dialogContext,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    update();
    try {
      final Response response = await walletServiceInterface.addFundToWallet(
        amount,
        paymentMethod,
      );
      // X may have closed the amount dialog while the request was in flight.
      // Never pop its underlying wallet route or launch a late payment over it.
      if (dialogContext != null && !dialogContext.mounted) return;
      // The gateway link comes back on a 201, which a 200-only test dropped silently.
      if (ApiClient.isSuccessCode(response.statusCode)) {
        final String redirectUrl = response.body is Map
            ? '${response.body['redirect_link'] ?? ''}'
            : '';
        if (redirectUrl.isEmpty) {
          showCustomSnackBar('something_went_wrong'.tr);
        } else {
          final WalletKeepzPayment? embedded = GetPlatform.isWeb
              ? null
              : WalletKeepzPayment.fromResponse(
                  paymentMethod: paymentMethod,
                  body: response.body,
                  baseUrl: AppConstants.baseUrl,
                );
          if (dialogContext != null) {
            if (ModalRoute.of(dialogContext)?.isCurrent != true) return;
            Navigator.of(dialogContext).pop();
          } else if (Get.isDialogOpen == true) {
            Get.back();
          }
          _isLoading = false;
          update();
          if (GetPlatform.isWeb) {
            html.window.open(redirectUrl, "_self");
          } else if (embedded != null) {
            final String? status = await KeepzPaymentLauncher.showHosted(
              initialUrl: embedded.redirectUrl,
              resolvePaymentStatus: () async {
                final Response result = await Get.find<ApiClient>().getData(
                  embedded.statusPath,
                  handleError: false,
                );
                return embedded.verifiedStatus(
                  statusCode: result.statusCode,
                  body: result.body,
                );
              },
            );
            // The callback/ledger, never the hosted URL, owns the account balance.
            if (Get.isRegistered<ProfileController>()) {
              await Get.find<ProfileController>().getUserInfo();
            }
            await getWalletTransactionList('1', true, _type);
            if (status == 'success' || status == 'fail') {
              await Get.dialog<void>(
                FundStatusDialogWidget(isSuccess: status == 'success'),
              );
            }
          } else {
            Get.toNamed(
              RouteHelper.getPaymentRoute(
                '0',
                0,
                '',
                0,
                false,
                '',
                addFundUrl: redirectUrl,
                guestId: '',
              ),
            );
          }
        }
      }
    } catch (_) {
      showCustomSnackBar('something_went_wrong'.tr);
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> getWalletBonusList({bool isUpdate = true}) async {
    _isLoading = true;
    if(isUpdate) {
      update();
    }

    List<FundBonusModel>? bonuses = await walletServiceInterface.getWalletBonusList();
    if (bonuses != null) {
      _fundBonusList = [];
      _fundBonusList!.addAll(bonuses);

      _isLoading = false;
      update();
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  void setWalletAccessToken(String accessToken){
    walletServiceInterface.setWalletAccessToken(accessToken);
  }

  String getWalletAccessToken (){
    return walletServiceInterface.getWalletAccessToken();
  }

}

// SUMMARY
// Wallet state. Holds the transaction list and its filters, the wallet bonus offers and
// the selected payment method, and starts an add-fund payment by handing the gateway
// link it gets back to the payment screen.
