// Fix for device_apps package namespace issue
allprojects {
    afterEvaluate {
        if (project.name == "device_apps") {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val androidExtension = android as com.android.build.gradle.BaseExtension
                    if (androidExtension.namespace == null || androidExtension.namespace.isEmpty()) {
                        androidExtension.namespace = "com.ganeshrashinkar.device_apps"
                    }
                } catch (e: Exception) {
                    // Try alternative method using reflection
                }
            }
        }
    }
}
