# الحفاظ على مكتبة الاتصال بالإنترنت ومكتبة جوجل
-keep class com.google.generativeai.** { *; }
-keep class io.grpc.** { *; }
-keep class com.squareup.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
