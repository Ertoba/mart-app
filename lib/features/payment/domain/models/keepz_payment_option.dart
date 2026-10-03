import 'package:sixam_mart/util/images.dart';

class KeepzPaymentOption {
  final String key;
  final String title;
  final String flow;
  final String provider;
  final String iconAsset;
  final bool externalFirst;
  final bool requiresPersonalNumber;

  const KeepzPaymentOption({
    required this.key,
    required this.title,
    required this.flow,
    required this.provider,
    required this.iconAsset,
    this.externalFirst = false,
    this.requiresPersonalNumber = false,
  });

  static const KeepzPaymentOption credo = KeepzPaymentOption(
    key: 'credo',
    title: 'Credo bank',
    flow: 'open_banking',
    provider: 'CREDO',
    iconAsset: Images.keepzCredo,
    externalFirst: true,
  );

  static const KeepzPaymentOption bankOfGeorgia = KeepzPaymentOption(
    key: 'bog',
    title: 'Bank of Georgia',
    flow: 'open_banking',
    provider: 'BOG',
    iconAsset: Images.keepzBog,
    externalFirst: true,
  );

  static const KeepzPaymentOption tbc = KeepzPaymentOption(
    key: 'tbc',
    title: 'TBC bank',
    flow: 'open_banking',
    provider: 'TBC',
    iconAsset: Images.keepzTbc,
    externalFirst: true,
  );

  static const KeepzPaymentOption liberty = KeepzPaymentOption(
    key: 'liberty',
    title: 'Liberty bank',
    flow: 'open_banking',
    provider: 'LB',
    iconAsset: Images.keepzLiberty,
    externalFirst: true,
  );

  static const KeepzPaymentOption card = KeepzPaymentOption(
    key: 'card',
    title: 'ბარათით გადახდა',
    flow: 'hosted',
    provider: '',
    iconAsset: Images.keepzCard,
  );

  static const KeepzPaymentOption installment = KeepzPaymentOption(
    key: 'installment',
    title: 'დაყავი',
    flow: 'installment',
    provider: 'CREDO',
    iconAsset: Images.keepzInstallment,
    requiresPersonalNumber: true,
  );

  static const KeepzPaymentOption crypto = KeepzPaymentOption(
    key: 'crypto',
    title: 'Crypto',
    flow: 'crypto',
    provider: 'CITYPAY',
    iconAsset: Images.keepzCrypto,
  );

  static const KeepzPaymentOption defaultOption = card;

  static const List<KeepzPaymentOption> values = <KeepzPaymentOption>[card];

  static KeepzPaymentOption? fromKey(String? key) {
    if (key == null || key.isEmpty || key == 'null') {
      return null;
    }

    for (final KeepzPaymentOption option in values) {
      if (option.key == key) {
        return option;
      }
    }

    return null;
  }
}
