import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/business/business_details.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/business/business_details_small_screen.dart';
import 'package:melegna_customer/presentation/ui/shared/responsive_wrapper.dart';

class BusinessDetailsPage extends StatefulWidget {
  static const routeName = '/business/:id';
  static const idQueryParameter = 'id';
  BusinessDetailsViewModel? businessViewmodel;
  final String businessId;
  final String? businessName;
  BusinessDetailsPage({super.key, required this.businessId, this.businessName, this.businessViewmodel}){
    businessViewmodel ??= Get.put(getIt<BusinessDetailsViewModel>());
  }

  @override 
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      widget.businessViewmodel!.initViewmodel(); 
    });
  }

  @override 
  void initState() {
    // TODO: implement initState
    super.initState();
    print("viewmodel init state");
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      smallScreen: BusinessDetailsSmallScreen(
        businessDetailsViewmodel: widget.businessViewmodel!,
        businessName: widget.businessName,
      ),
    );
  }
}
