# Stripe (flutter_stripe): push provisioning classes are optional.
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.pushprovisioning.**
-keep class com.stripe.android.** { *; }

# Flutter deferred components reference Play Core, which this app does not use.
-dontwarn com.google.android.play.core.**
