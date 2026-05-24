import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/category.dart';
import '../domain/models/corporate_booking_option.dart';
import '../domain/models/home_appliance_details.dart';
import '../domain/repositories/category_repository.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final response = await repository.fetchCategories();

  if (response.isSuccess) {
    return response.data ?? [];
  } else {
    throw Exception(response.errorMessage ?? 'Failed to fetch categories');
  }
});

final subCategoriesProvider = FutureProvider.family<List<Category>, int>((
  ref,
  parentId,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final response = await repository.fetchSubCategories(parentId);

  if (response.isSuccess) {
    return response.data ?? [];
  } else {
    throw Exception(response.errorMessage ?? 'Failed to fetch sub-categories');
  }
});

final categoryDetailProvider = FutureProvider.family<Category, int>((
  ref,
  id,
) async {
  // Try to find in cache first
  final categoriesAsync = ref.watch(categoriesProvider);
  if (categoriesAsync.hasValue) {
    final found = _findCategoryRecursive(categoriesAsync.value!, id);
    if (found != null) return found;
  }

  // If not found in main list, fetch explicitly
  final repository = ref.watch(categoryRepositoryProvider);
  final response = await repository.fetchCategoryById(id);

  if (response.isSuccess && response.data != null) {
    return response.data!;
  } else {
    throw Exception(
      response.errorMessage ?? 'Failed to fetch category details',
    );
  }
});

final homeApplianceDetailsProvider =
    FutureProvider.family<HomeApplianceDetails, int>((ref, categoryId) async {
      final repository = ref.watch(categoryRepositoryProvider);
      final response = await repository.fetchHomeApplianceDetails(categoryId);

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw Exception(
          response.errorMessage ?? 'Failed to fetch home appliance details',
        );
      }
    });

final corporateBookingOptionsProvider = FutureProvider<CorporateBookingOption>((
  ref,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final response = await repository.fetchCorporateBookingOptions();

  if (response.isSuccess && response.data != null) {
    return response.data!;
  } else {
    throw Exception(
      response.errorMessage ?? 'Failed to fetch corporate booking options',
    );
  }
});

Category? _findCategoryRecursive(List<Category> categories, int id) {
  for (var cat in categories) {
    if (cat.id == id) return cat;
    final found = _findCategoryRecursive(cat.children, id);
    if (found != null) return found;
  }
  return null;
}
