// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:imela_core/branch/branch.usecase.dart' as _i134;
import 'package:imela_core/business/business.usecase.dart' as _i744;
import 'package:imela_core/calendar/usecase/calendar.usecase.dart' as _i428;
import 'package:imela_core/chat/chat.usecase.dart' as _i943;
import 'package:imela_core/customer/customer_usecase.dart' as _i283;
import 'package:imela_core/inventory/inventory.usecase.dart' as _i604;
import 'package:imela_core/loyalty/loyalty_usecase.dart' as _i440;
import 'package:imela_core/membership/membership_usecase.dart' as _i73;
import 'package:imela_core/order/order.usecase.dart' as _i789;
import 'package:imela_core/product/discount.usecase.dart' as _i725;
import 'package:imela_core/product/product.usecase.dart' as _i987;
import 'package:imela_core/product/product_price.usecase.dart' as _i571;
import 'package:imela_core/schedule/schedule.usecase.dart' as _i827;
import 'package:imela_core/settings/setting_usecase.dart' as _i948;
import 'package:imela_core/staff/staff_usecase.dart' as _i61;
import 'package:imela_core/user/auth.usecase.dart' as _i887;
import 'package:imela_pos/app/app_viewmodel.dart' as _i100;
import 'package:imela_pos/app/routing_service.dart' as _i877;
import 'package:imela_pos/ui/authentication/staff_signin.viewmodel.dart'
    as _i792;
import 'package:imela_pos/ui/authentication/workspace_auth/workspace_auth_viewmodel.dart'
    as _i207;
import 'package:imela_pos/ui/calendar/calendar_edit.viewmodel.dart' as _i228;
import 'package:imela_pos/ui/calendar/calendar_list.viewmodel.dart' as _i899;
import 'package:imela_pos/ui/cart/cart.viewmodel.dart' as _i432;
import 'package:imela_pos/ui/chat/chat_viewmodel.dart' as _i452;
import 'package:imela_pos/ui/customer/customer.viewmodel.dart' as _i284;
import 'package:imela_pos/ui/home/branch_selection.viewmodel.dart' as _i780;
import 'package:imela_pos/ui/home/home_page.viewmodel.dart' as _i751;
import 'package:imela_pos/ui/home/splash/splash.viewmodel.dart' as _i137;
import 'package:imela_pos/ui/inventory/inventory.viewmodel.dart' as _i953;
import 'package:imela_pos/ui/membership/create_membership.viewmodel.dart'
    as _i439;
import 'package:imela_pos/ui/membership/pos_membership_list.viewmodel.dart'
    as _i939;
import 'package:imela_pos/ui/order/order.viewmodel.dart' as _i18;
import 'package:imela_pos/ui/order/schedule/create_schedule/create_schedule.viewmodel.dart'
    as _i101;
import 'package:imela_pos/ui/order/schedule/viewmodel.schedule.dart' as _i757;
import 'package:imela_pos/ui/payment/payment_page.viewmodel.dart' as _i153;
import 'package:imela_pos/ui/product/components/addon_viewmodel.dart' as _i268;
import 'package:imela_pos/ui/product/components/location_selector/location.viewmodel.dart'
    as _i190;
import 'package:imela_pos/ui/product/viewmodel.product_list.dart' as _i586;
import 'package:imela_pos/ui/product_price/product_price_list.viewmodel.dart'
    as _i136;
import 'package:imela_pos/ui/search/search.viewmodel.dart' as _i209;
import 'package:imela_pos/ui/section/section.viewmodel.dart' as _i468;
import 'package:imela_pos/ui/staff/create_staff/viewmodel.create_staff.dart'
    as _i660;
import 'package:imela_pos/ui/staff/staff_list/staff.viewmodel.dart' as _i377;
import 'package:imela_utils/exception/app_exception.dart' as _i478;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i586.ProductListViewModel>(() => _i586.ProductListViewModel());
    gh.factory<_i18.OrderViewmodel>(() => _i18.OrderViewmodel(
          orderUsecase: gh<_i789.OrderUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i153.PaymentPageViewmodel>(() => _i153.PaymentPageViewmodel(
          orderUsecase: gh<_i789.OrderUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i207.WorkspaceAuthViewmodel>(() => _i207.WorkspaceAuthViewmodel(
          authUsecase: gh<_i744.BusinessUsecase>(),
          businessUsecase: gh<_i744.BusinessUsecase>(),
          branchUsecase: gh<_i134.BranchUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i751.HomePageViewmodel>(() => _i751.HomePageViewmodel(
          branchUsecase: gh<_i134.BranchUsecase>(),
          loyaltyUsecase: gh<_i440.LoyaltyUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i209.SearchViewmodel>(() => _i209.SearchViewmodel(
          branchUsecase: gh<_i134.BranchUsecase>(),
          loyaltyUsecase: gh<_i440.LoyaltyUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i136.ProductPriceListViewModel>(
        () => _i136.ProductPriceListViewModel(
              productPriceUsecase: gh<_i571.ProductPriceUsecase>(),
              exceptionHandler: gh<_i478.IExceptiionHandler>(
                  instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
            ));
    gh.factory<_i877.IRoutingService>(
      () => _i877.GoRouterService(),
      instanceName: 'GoRouterService',
    );
    gh.factory<_i468.SectionViewModel>(() => _i468.SectionViewModel(
          businessUsecase: gh<_i744.BusinessUsecase>(),
          exceptionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i284.CustomerViewmodel>(() => _i284.CustomerViewmodel(
          orderUsecase: gh<_i789.OrderUsecase>(),
          customerUsecase: gh<_i283.CustomerUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i100.AppViewmodel>(() => _i100.AppViewmodel(
          authUsecase: gh<_i887.AuthUsecase>(),
          customerUsecase: gh<_i283.CustomerUsecase>(),
          membershipUsecase: gh<_i73.MembershipUseCase>(),
          productUsecase: gh<_i987.ProductUsecase>(),
        ));
    gh.factory<_i939.POSMembershipListViewmodel>(
        () => _i939.POSMembershipListViewmodel(
              membershipUseCase: gh<_i73.MembershipUseCase>(),
              exceptiionHandler: gh<_i478.IExceptiionHandler>(
                  instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
            ));
    gh.factory<_i953.InventoryViewModel>(() => _i953.InventoryViewModel(
          inventoryUsecase: gh<_i604.InventoryUsecase>(),
          exceptionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i432.CartViewmodel>(() =>
        _i432.CartViewmodel(discountUseCase: gh<_i725.DiscountUseCase>()));
    gh.factory<_i439.CreateMembershipViewmodel>(
        () => _i439.CreateMembershipViewmodel(
              membershipUseCase: gh<_i73.MembershipUseCase>(),
              customerUseCase: gh<_i283.CustomerUsecase>(),
            ));
    gh.factory<_i660.CreateStaffViewModel>(() =>
        _i660.CreateStaffViewModel(staffUsecase: gh<_i61.StaffUsecase>()));
    gh.factory<_i377.StaffViewmodel>(
        () => _i377.StaffViewmodel(staffUsecase: gh<_i61.StaffUsecase>()));
    gh.factory<_i190.LocationViewmodel>(() => _i190.LocationViewmodel(
          settingUsecase: gh<_i948.SettingUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i899.CalendarListViewModel>(() => _i899.CalendarListViewModel(
          calendarUsecase: gh<_i428.CalendarUsecase>(),
          exceptionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i101.CreateScheduleViewModel>(
        () => _i101.CreateScheduleViewModel(
              gh<_i827.ScheduleUsecase>(),
              gh<_i428.CalendarUsecase>(),
              gh<_i478.IExceptiionHandler>(
                  instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
            ));
    gh.factory<_i228.CalendarEditViewModel>(() => _i228.CalendarEditViewModel(
          calendarUsecase: gh<_i428.CalendarUsecase>(),
          scheduleUsecase: gh<_i827.ScheduleUsecase>(),
          exceptionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i452.ChatViewModel>(() => _i452.ChatViewModel(
          gh<_i943.ChatUsecase>(),
          exceptionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i757.OrderScheduleViewModel>(() => _i757.OrderScheduleViewModel(
          gh<_i789.OrderUsecase>(),
          gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i780.BranchSelectionViewmodel>(
        () => _i780.BranchSelectionViewmodel(
              branchUsecase: gh<_i134.BranchUsecase>(),
              productUsecase: gh<_i987.ProductUsecase>(),
              exceptiionHandler: gh<_i478.IExceptiionHandler>(
                  instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
            ));
    gh.factory<_i268.ProductAddonViewmodel>(() => _i268.ProductAddonViewmodel(
          settingUsecase: gh<_i948.SettingUsecase>(),
          orderUsecase: gh<_i789.OrderUsecase>(),
          scheduleUsecase: gh<_i827.ScheduleUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i792.StaffAuthViewmodel>(() => _i792.StaffAuthViewmodel(
          staffUsecase: gh<_i61.StaffUsecase>(),
          businessUsecase: gh<_i744.BusinessUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    gh.factory<_i137.SplashViewmodel>(() => _i137.SplashViewmodel(
          staffUsecase: gh<_i61.StaffUsecase>(),
          businessUsecase: gh<_i744.BusinessUsecase>(),
          exceptiionHandler: gh<_i478.IExceptiionHandler>(
              instanceName: 'APP_EXCEPTION_HANDLER_INJECTION'),
        ));
    return this;
  }
}
