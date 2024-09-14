import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/customization.model.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';
import 'package:imela_core/subscription/model/subscription_renewal.model.dart';

class NumberResources {
  static const EXPANDED_APPBAR_HEIGHT = 225.0;
  static const COLLAPSED_APPBAR_HEIGHT = 60.0;

  static const double DEFAULT_PADDING = 16.0;
  static const double DEFAULT_MARGIN = 16.0;

  static const double DEFAULT_ICON_SIZE = 24.0;

  static const double PRODUCT_BOTTOM_NAVIGATION_HEIGHT = 75.0;
}

class ErrorResourceValues {
  static const String ERROR_MESSAGE = 'An error occurred';
  static const String NO_INTERNET_CONNECTION = 'No internet connection';
  static const String NO_DATA_FOUND = 'No data found';
  static const String UnAUTHORIZED_EXCEPTION_CODE = '401';
}

class CurrencyResources {
  static const String CURRENCY_SYMBOL = '₦';
  static const AMOUNT_ZERO = 0.0;
}

const categories = ['All', 'Food', 'Drinks', 'Groceries', 'Electronics', 'Fashion', 'Health & Beauty', 'Home & Office', 'Sports & Fitness', 'Automobile', 'Books & Stationery', 'Kids & Baby', 'Others'];

var  mockPlatformServiceList = <PlatformService>[
  PlatformService(
    id: '1',
    name: [
      LocalizedField(key: 'ENGLISH', value: 'Membership / Subscription'),
    ],
    type: 'Basic',
    description: [
      // long description
      LocalizedField(key: 'ENGLISH', value: 'This is a basic membership plan that allows you to access all the basic features of the platform.'),
    ],
    basePrice: 500,
    image: 'assets/images/subscription.png',
    features: [
      LocalizedField(key: 'ENGLISH', value: 'Access to all basic features'),
      LocalizedField(key: 'ENGLISH', value: 'Chat room and forum access'),
      LocalizedField(key: 'ENGLISH', value: 'Basic support'),
    ],
    subscriptionRenewalInfo: [
      SubscriptionRenewal(
        id: '1',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Monthly'),
        ],
        duration: 30,
        trialPeriod: 0,
        discountAmount: 0,
      ),
      SubscriptionRenewal(
        id: '2',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Yearly'),
        ],
        duration: 365,
        trialPeriod: 0,
        discountAmount: 0,
      ),
    ],
    customizationCategories: [
      CustomizationCategory(
        id: '1',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Customization Category 1'),
        ],
        description: [
          LocalizedField(key: 'ENGLISH', value: 'This is a description for customization category 1'),
        ],
        selectionType: CustomizationSelectionType.SINGLE_SELECTION.name,
        selectionRequired: true,
        customizations: [
          Customization(
            id: '1',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 1'),
            ],
            actionIdentifier: 'action1',
            value: 'value1',
            defaultValue: true,
          ),
          Customization(
            id: '2',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 2'),
            ],
            actionIdentifier: 'action2',
            value: 'value2',
            defaultValue: false,
          ),
        ],
      ),
      CustomizationCategory(
        id: '2',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Customization Category 2'),
        ],
        description: [
          LocalizedField(key: 'ENGLISH', value: 'This is a description for customization category 2'),
        ],
        selectionType: CustomizationSelectionType.SINGLE_SELECTION.name,
        selectionRequired: false,
        customizations: [
          Customization(
            id: '3',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 3'),
            ],
            actionIdentifier: 'action3',
            value: 'value3',
            defaultValue: false,
          ),
          Customization(
            id: '4',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 4'),
            ],
            actionIdentifier: 'action4',
            value: 'value4',
            defaultValue: false,
          ),
        ],
      ),
    ],
  ),
  
  PlatformService(
    id: '2',
    name: [
      LocalizedField(key: 'ENGLISH', value: 'Point of Sale'),
    ],
    type: 'Basic',
    description: [
      // long description
      LocalizedField(key: 'ENGLISH', value: 'This is a basic membership plan that allows you to access all the basic features of the platform.'),
    ],
    basePrice: 500,
    image: 'assets/images/subscription.png',
    features: [
      LocalizedField(key: 'ENGLISH', value: 'Access to all basic features'),
      LocalizedField(key: 'ENGLISH', value: 'Chat room and forum access'),
      LocalizedField(key: 'ENGLISH', value: 'Basic support'),
    ],
    subscriptionRenewalInfo: [
      SubscriptionRenewal(
        id: '1',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Monthly'),
        ],
        duration: 30,
        trialPeriod: 0,
        discountAmount: 0,
      ),
      SubscriptionRenewal(
        id: '2',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Yearly'),
        ],
        duration: 365,
        trialPeriod: 0,
        discountAmount: 0,
      ),
    ],
    customizationCategories: [
      CustomizationCategory(
        id: '1',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Customization Category 1'),
        ],
        description: [
          LocalizedField(key: 'ENGLISH', value: 'This is a description for customization category 1'),
        ],
        selectionType: CustomizationSelectionType.MULTI_SELECTION.name,
        selectionRequired: true,
        customizations: [
          Customization(
            id: '1',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 1'),
            ],
            actionIdentifier: 'action1',
            value: 'value1',
            defaultValue: true,
          ),
          Customization(
            id: '2',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 2'),
            ],
            actionIdentifier: 'action2',
            value: 'value2',
            defaultValue: false,
          ),
        ],
      ),
      CustomizationCategory(
        id: '2',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Customization Category 2'),
        ],
        description: [
          LocalizedField(key: 'ENGLISH', value: 'This is a description for customization category 2'),
        ],
        selectionType: CustomizationSelectionType.SINGLE_SELECTION.name,
        selectionRequired: false,
        customizations: [
          Customization(
            id: '3',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 3'),
            ],
            actionIdentifier: 'action3',
            value: 'value3',
            defaultValue: false,
          ),
          Customization(
            id: '4',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 4'),
            ],
            actionIdentifier: 'action4',
            value: 'value4',
            defaultValue: false,
          ),
        ],
      ),
    ],
  ),

  // based on the above example, create Online store platform service info
  PlatformService(
    id: '3',
    name: [
      LocalizedField(key: 'ENGLISH', value: 'Online Store'),
    ],
    type: 'Basic',
    description: [
      // long description
      LocalizedField(key: 'ENGLISH', value: 'This is a basic membership plan that allows you to access all the basic features of the platform.'),
    ],
    basePrice: 500,
    image: 'assets/images/subscription.png',
    features: [
      LocalizedField(key: 'ENGLISH', value: 'Access to all basic features'),
      LocalizedField(key: 'ENGLISH', value: 'Chat room and forum access'),
      LocalizedField(key: 'ENGLISH', value: 'Basic support'),
    ],
    subscriptionRenewalInfo: [
      SubscriptionRenewal(
        id: '1',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Monthly'),
        ],
        duration: 30,
        trialPeriod: 0,
        discountAmount: 0,
      ),
      SubscriptionRenewal(
        id: '2',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Yearly'),
        ],
        duration: 365,
        trialPeriod: 0,
        discountAmount: 0,
      ),
    ],
    customizationCategories: [
      CustomizationCategory(
        id: '1',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Customization Category 1'),
        ],
        description: [
          LocalizedField(key: 'ENGLISH', value: 'This is a description for customization category 1'),
        ],
        selectionType: CustomizationSelectionType.MULTI_SELECTION.name,
        selectionRequired: true,
        customizations: [
          Customization(
            id: '1',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 1'),
            ],
            actionIdentifier: 'action1',
            value: 'value1',
            defaultValue: true,
          ),
          Customization(
            id: '2',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 2'),
            ],
            actionIdentifier: 'action2',
            value: 'value2',
            defaultValue: false,
          ),
        ],
      ),
      CustomizationCategory(
        id: '2',
        name: [
          LocalizedField(key: 'ENGLISH', value: 'Customization Category 2'),
        ],
        description: [
          LocalizedField(key: 'ENGLISH', value: 'This is a description for customization category 2'),
        ],
        selectionType: CustomizationSelectionType.MULTI_SELECTION.name,
        selectionRequired: false,
        customizations: [
          Customization(
            id: '3',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 3'),
            ],
            actionIdentifier: 'action3',
            value: 'value3',
            defaultValue: false,
          ),
          Customization(
            id: '4',
            name: [
              LocalizedField(key: 'ENGLISH', value: 'Customization 4'),
            ],
            actionIdentifier: 'action4',
            value: 'value4',
            defaultValue: false,
          ),
        ],
      ),
    ],
  ),
];
