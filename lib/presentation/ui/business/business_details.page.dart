import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/business/business.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/business/business_details_small_screen.dart';
import 'package:melegna_customer/presentation/ui/shared/responsive_wrapper.dart';

class BusinessDetailsPage extends StatefulWidget {
  BusinessDetailsViewModel? businessViewmodel;
  BusinessDetailsPage({super.key, this.businessViewmodel}){
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
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      smallScreen: BusinessDetailsSmallScreen(
        businessDetailsViewmodel: widget.businessViewmodel!,
      ),
    );
  }
}
