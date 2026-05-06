import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category.dart';
import '../models/home_appliance_details.dart';
import '../models/pickup_catalog_item.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(DioClient());
});

class CategoryRepository {
  final DioClient _dioClient;

  CategoryRepository(this._dioClient);
  Future<ApiResponse<List<Category>>> fetchCategories() async {
    return _dioClient.get<List<Category>>(
      ApiEndpoints.categories,
      parser: (data) {
        final dynamic payload = data['data'];
        final List<dynamic> list;
        if (payload is List<dynamic>) {
          list = payload;
        } else if (payload is Map<String, dynamic>) {
          list =
              payload['data'] as List<dynamic>? ??
              payload['items'] as List<dynamic>? ??
              const <dynamic>[];
        } else {
          list = const <dynamic>[];
        }
        return list
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<Category>> fetchCategoryById(int id) async {
    return _dioClient.get<Category>(
      ApiEndpoints.categoryById(id),
      parser: (data) => Category.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<Category>>> fetchSubCategories(int parentId) async {
    return _dioClient.get<List<Category>>(
      ApiEndpoints.subcategories,
      queryParameters: {'category_id': parentId},
      parser: (data) {
        final dynamic payload = data['data'];
        final List<dynamic> list;
        if (payload is List<dynamic>) {
          list = payload;
        } else if (payload is Map<String, dynamic>) {
          list =
              payload['data'] as List<dynamic>? ??
              payload['items'] as List<dynamic>? ??
              const <dynamic>[];
        } else {
          list = const <dynamic>[];
        }
        return list
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<List<PickupCatalogItem>>> fetchItems(
    int subcategoryId,
  ) async {
    return _dioClient.get<List<PickupCatalogItem>>(
      ApiEndpoints.items,
      queryParameters: {'subcategory_id': subcategoryId},
      parser: (data) {
        final dynamic payload = data['data'];
        final List<dynamic> list;
        if (payload is List<dynamic>) {
          list = payload;
        } else if (payload is Map<String, dynamic>) {
          list =
              payload['data'] as List<dynamic>? ??
              payload['items'] as List<dynamic>? ??
              const <dynamic>[];
        } else {
          list = const <dynamic>[];
        }
        return list
            .map(
              (json) =>
                  PickupCatalogItem.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<ApiResponse<HomeApplianceDetails>> fetchHomeApplianceDetails(
    int categoryId,
  ) async {
    return _dioClient.get<HomeApplianceDetails>(
      ApiEndpoints.homeApplianceDetails,
      queryParameters: {'category_id': categoryId},
      parser: (data) =>
          HomeApplianceDetails.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<double>> estimateHomeAppliancePrice({
    required int categoryId,
    required List<Map<String, dynamic>> attributes,
  }) async {
    return _dioClient.post<double>(
      ApiEndpoints.homeApplianceEstimate,
      data: {'category_id': categoryId, 'attributes': attributes},
      parser: (data) {
        final payload = (data['data'] as Map<String, dynamic>?) ?? {};
        final price = payload['estimated_price'] ?? payload['price'] ?? 0;
        if (price is num) {
          return price.toDouble();
        }
        return double.tryParse(price.toString()) ?? 0;
      },
    );
  }
}
