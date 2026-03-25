import 'package:get/get.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class FavouriteRepositoryInterface<T> extends RepositoryInterface<T> {
  @override
  Future<Response> getList({int? offset});

  @override
  Future<ResponseModel> add(dynamic value, {bool isStore = false, int? id});

  @override
  Future<ResponseModel> delete(int? id, {bool isStore = false});
}
