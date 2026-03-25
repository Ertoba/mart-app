import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:sixam_mart/features/flash_sale/domain/models/product_flash_sale.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class FlashSaleRepositoryInterface implements RepositoryInterface {
  Future<FlashSaleModel?> getFlashSale({required DataSourceEnum source});
  Future<ProductFlashSale?> getFlashSaleWithId(int id, int offset);
}
