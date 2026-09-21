# Keep AndroidX WorkManager internal classes and database from being obfuscated by R8
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.background.systemalarm.RescheduleReceiver { *; }
-keep class androidx.work.impl.background.systemalarm.ConstraintProxy$* { *; }

# Keep Room Database classes (used by WorkManager under the hood)
-keep class * extends androidx.room.RoomDatabase
-dontwarn androidx.work.impl.**