import 'dart:math';

import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/membership/dto/membership_response.dart';
import 'package:imela_core/membership/repo/membership_repository.dart';
import 'package:imela_core/product/model/product_response.dart';
import 'package:imela_core/product/repo/product.repository.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_utils/qr_bar_code_service/qr_response.dart';
import 'package:imela_utils/qr_bar_code_service/qrcode_service.dart';
import 'package:imela_utils/storage/storage_usecase.dart';
import 'package:injectable/injectable.dart';

@injectable
class MembershipUseCase {
  final IMembershipRepository _membershipRepository;
  final IProductRepository _productRepository;
  final StorageUseCase _storageUseCase;
  final IQRCodeService _qrCodeService;

  MembershipUseCase(
    @Named(MembershipRepository.injectName) this._membershipRepository,
    @Named(ProductRepository.injectName) this._productRepository,
    @Named(QRCodeService.injectName) this._qrCodeService,
    this._storageUseCase,
  );

  Future<MembershipResponse?> getMembershipDetails(String membershipId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _membershipRepository.getMembershipDetails(membershipId, fetchPolicy: fetchPolicy);
    if (!(result?.success ?? false) && fetchPolicy == ApiDataFetchPolicy.cacheFirst) {
      result = await _membershipRepository.getMembershipDetails(membershipId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }

    return result;
  }

  Future<MembershipResponse?> getMembershipPlansForPos(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _membershipRepository.getBusinessMembershipPlansForPos(businessId, fetchPolicy: fetchPolicy);
    if (!(result?.success ?? false)) {
      result = await _membershipRepository.getBusinessMembershipPlansForPos(businessId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<ProductResponse?> getMembershipProducts(String membershipId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    var products = await _productRepository.getMembershipProducts(membershipId, fetchPolicy: fetchPolicy);
    if (!(products?.success ?? false)) {
      products = await _productRepository.getMembershipProducts(membershipId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return products;
  }

  Future<MembershipResponse?> getBusinessMembershipPlans(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _membershipRepository.getBusinessMembershipPlans(businessId, fetchPolicy: fetchPolicy);
    if (!(result?.success ?? false)) {
      result = await _membershipRepository.getBusinessMembershipPlans(businessId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<MembershipResponse?> requestToJoinMembership(String businessId, String membershipId, {required String membershipName, required SelectedPaymentMethod selectedPaymentMethod, required String memberId}) async {
    final paymentProofImages = {selectedPaymentMethod.id!: selectedPaymentMethod.receiptImages};
    final uploadDirectory = 'business/$businessId/membership/$membershipName/paymentproof/${selectedPaymentMethod.name.localize('ENGLISH')}}';
    final uploadResult = await _storageUseCase.uploadOrderPaymentProof(uploadDirectory, paymentProofImages);
    if (uploadResult.isNotEmpty) {
      selectedPaymentMethod = selectedPaymentMethod.addReceiptImages(uploadResult[selectedPaymentMethod.id]!);
    }
    return _membershipRepository.requestToJoinMembership(membershipId, selectedPaymentMethod);
  }

  Future<MembershipResponse?> getUserMemberships({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _membershipRepository.getUserMemberships(fetchPolicy: fetchPolicy);
    if (!(result?.success ?? false)) {
      result = await _membershipRepository.getUserMemberships(fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<MembershipResponse?> renewMembership({required String businessId, String? branchId, required String membershipId, required String membershipName, required String memberId, SelectedPaymentMethod? selectedPaymentMethod}) async {
      print('payment proof images .... ${selectedPaymentMethod?.toJson()}');
    if (selectedPaymentMethod != null) {
      final paymentProofImages = {selectedPaymentMethod.id!: selectedPaymentMethod.receiptImages};
      final uploadDirectory = 'business/$businessId/membership/$membershipName/paymentproof/${selectedPaymentMethod.name.localize('ENGLISH')}}';
      final uploadResult = await _storageUseCase.uploadOrderPaymentProof(uploadDirectory, paymentProofImages);
      if (uploadResult.isNotEmpty) {
        selectedPaymentMethod = selectedPaymentMethod.addReceiptImages(uploadResult[selectedPaymentMethod.id]!);
      }
    }
    final result = await _membershipRepository.approveMembershipRequest(businessId, membershipId, branchId, [memberId], selectedPaymentMethod: selectedPaymentMethod);
    return result;
  }

  Future<QRCodeResponse> generateUserMembershipQRCode(String membershipId, String userId) async {
    final qrCodeText = '$membershipId-$userId';
    final qrCodeResponse = await _qrCodeService.getQRCodeUI(qrCodeText);
    return qrCodeResponse;
  }
}
