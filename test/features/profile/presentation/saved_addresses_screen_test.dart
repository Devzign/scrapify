import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrapify/features/profile/presentation/saved_addresses_screen.dart';
import 'package:scrapify/features/profile/domain/repositories/address_repository.dart';
import 'package:scrapify/features/profile/domain/models/address_model.dart';
import 'package:scrapify/features/profile/providers/address_provider.dart';
import 'package:scrapify/core/network/api_response.dart';

class FakeAddressRepository implements AddressRepository {
  final List<AddressModel> mockAddresses;

  FakeAddressRepository(this.mockAddresses);

  @override
  Future<ApiResponse<List<AddressModel>>> getAddresses() async {
    return ApiResponse.success(mockAddresses);
  }

  @override
  Future<ApiResponse<String>> addAddress(AddressModel address) async {
    mockAddresses.add(address);
    return ApiResponse.success('Address added successfully');
  }

  @override
  Future<ApiResponse<String>> updateAddress(
    int id,
    AddressModel address,
  ) async {
    final index = mockAddresses.indexWhere((a) => a.id == id);
    if (index != -1) {
      mockAddresses[index] = address;
    }
    return ApiResponse.success('Address updated successfully');
  }

  @override
  Future<ApiResponse<String>> deleteAddress(int id) async {
    mockAddresses.removeWhere((a) => a.id == id);
    return ApiResponse.success('Address deleted successfully');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('SavedAddressesScreen renders correctly with addresses', (
    WidgetTester tester,
  ) async {
    final mockAddresses = [
      AddressModel(
        id: 1,
        title: 'Home',
        addressLine1: '123 Main Street',
        cityId: 1,
        state: 'NY',
        pincode: '10001',
        isDefault: true,
      ),
      AddressModel(
        id: 2,
        title: 'Work',
        addressLine1: '456 Work Ave',
        cityId: 2,
        state: 'CA',
        pincode: '90001',
        isDefault: false,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          addressRepositoryProvider.overrideWithValue(
            FakeAddressRepository(mockAddresses),
          ),
        ],
        child: const MaterialApp(home: SavedAddressesScreen()),
      ),
    );

    // Initial load
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump to complete futures
    await tester.pumpAndSettle();

    // Verify screen renders
    expect(find.byType(SavedAddressesScreen), findsOneWidget);

    // Verify addresses are rendered
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.textContaining('123 Main Street'), findsOneWidget);

    // Test delete address action
    final deleteButtons = find.byIcon(Icons.delete_outline);
    expect(deleteButtons, findsNWidgets(2));

    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // The address list should now have 1 item
    expect(find.text('Home'), findsNothing);
    expect(find.text('Work'), findsOneWidget);
  });
}
