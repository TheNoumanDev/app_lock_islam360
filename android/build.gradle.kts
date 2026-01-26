allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Fix for device_apps package namespace issue
    afterEvaluate {
        if (project.name == "device_apps") {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val androidExtension = android as com.android.build.gradle.BaseExtension
                    if (androidExtension.namespace == null) {
                        androidExtension.namespace = "com.ganeshrashinkar.device_apps"
                    }
                } catch (e: Exception) {
                    // If namespace property doesn't exist, try alternative method
                    try {
                        val namespaceField = android.javaClass.getDeclaredField("namespace")
                        namespaceField.isAccessible = true
                        if (namespaceField.get(android) == null) {
                            namespaceField.set(android, "com.ganeshrashinkar.device_apps")
                        }
                    } catch (e2: Exception) {
                        // Fallback: create build.gradle patch
                    }
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
