import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrapify/features/profile/presentation/add_address_screen.dart';
import 'package:scrapify/features/profile/domain/repositories/address_repository.dart';
import 'package:scrapify/features/profile/domain/models/address_model.dart';
import 'package:scrapify/features/profile/providers/address_provider.dart';
import 'package:scrapify/core/network/api_response.dart';

class FakeAddressRepository implements AddressRepository {
  bool addAddressCalled = false;

  @override
  Future<ApiResponse<List<AddressModel>>> getAddresses() async {
    return ApiResponse.success([]);
  }

  @override
  Future<ApiResponse<String>> addAddress(AddressModel address) async {
    addAddressCalled = true;
    return ApiResponse.success('Address added successfully');
  }

  @override
  Future<ApiResponse<String>> updateAddress(
    int id,
    AddressModel address,
  ) async {
    return ApiResponse.success('Address updated successfully');
  }

  @override
  Future<ApiResponse<String>> deleteAddress(int id) async {
    return ApiResponse.success('Address deleted successfully');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('AddAddressScreen allows input and saves address', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeAddressRepository();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) => const AddAddressScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [addressRepositoryProvider.overrideWithValue(fakeRepo)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // Run pending futures (getAddresses) so the provider is no longer loading
    await tester.pumpAndSettle();

    // Navigate to AddAddressScreen
    router.push('/add');
    await tester.pumpAndSettle();

    // Verify screen renders
    expect(find.byType(AddAddressScreen), findsOneWidget);

    // Check for TextFields
    // We expect several text fields (Name, Phone, Address Line 1, Address Line 2, Landmark, Pincode)
    expect(find.byType(TextField), findsWidgets);

    // Check for Save button
    final saveButton = find.byType(ElevatedButton);
    expect(saveButton, findsOneWidget);

    // Tap the save button
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify the repository was called
    expect(fakeRepo.addAddressCalled, isTrue);
  });
}
