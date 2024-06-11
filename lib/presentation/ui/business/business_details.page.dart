import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/business/business.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/icon_btn.dart';
import 'package:melegna_customer/presentation/utils/button_style.dart';

class BusinessDetailsPage extends StatelessWidget {
  BusinessDetailsViewModel? businessViewmodel;
  BusinessDetailsPage({super.key, this.businessViewmodel}) {
    businessViewmodel ??= Get.put(getIt<BusinessDetailsViewModel>());
    businessViewmodel!.init();
  }

  var customOptions = <String, Widget>{
    "First option 1" : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.ac_unit),
        const SizedBox(
          width: 32,
        ),
        Text("option number 1"),
      ],
    ),
    "Another options 2" : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.ac_unit),
        const SizedBox(
          width: 32,
        ),
        Text("options nujber 2"),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    var appWidgetFactory = WidgetFactory(TargetPlatform.iOS);
    return Scaffold(
      appBar: AppBar(
        title: Text("Business Details"),
      ),
      body: Obx(
        () => Column(
          children: [
            Text(
              "Text is added to the body ${businessViewmodel!.businessDetails.value?.business.toString()}",
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
            // AppButton(buttonType: ButtonType.FILLED, icon: Icon(Icons.favorite), text: "Button", onPressed: () {

            // }),
            appWidgetFactory.createButton(context: context, content: Text("New Button"), icon: Icon(Icons.abc),onPressed: (){}),
            appWidgetFactory.createDropDown(context: context, options: customOptions,value: businessViewmodel?.dropdownValue.value ?? customOptions.keys.last, onChanged: (value){
              businessViewmodel?.dropdownValue.value = value;
            }),

            appWidgetFactory.createSwitch(true, (val){

            })


          ],
        ),
      ),
    );
  }
}
