class ProjectConfiguration {
  //TODO: set your logo path
  static final String logo = "images/logo.png";

  static final bool useCloudFunctions = false;
  //TODO: if useCloudFunctions==false add your notificationsApi and stripePaymentApi
  //Add your add notifications api
  static final notificationsApi = "";

  ///Add your Stripe Api
  static final stripePaymentApi = "";

  //TODO: Put your Strip publishable key and merchant id
  static final String stripePublishableKey = "";
  static final String stripeMerchantId = "Test";

  static final List<String> pngImages = [
    "images/logo.png",
    "images/settings/profile.png",
    "images/categories/vegetables.png",
  ];

  static final List<String> svgImages = [
    "images/sign_in/facebook.svg",
    "images/sign_in/google.svg",
    "images/sign_in/twitter.svg",
    "images/state_images/empty_cart.svg",
    "images/state_images/error.svg",
    "images/state_images/nothing_found.svg",
    "images/reminder.svg",
    "images/success.svg",
    "images/on_boarding/1.svg",
    "images/on_boarding/2.svg",
    "images/on_boarding/3.svg",
  ];
}
