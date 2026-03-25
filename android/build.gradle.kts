allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val subproject = this
    val newSubprojectBuildDir: Directory = newBuildDir.dir(subproject.name)
    subproject.layout.buildDirectory.value(newSubprojectBuildDir)

    subproject.afterEvaluate {
        val androidExt = subproject.extensions.findByName("android")
        if (androidExt != null) {
            try {
                val methods = androidExt.javaClass.methods
                val getNamespace = methods.find { it.name == "getNamespace" }
                val setNamespace = methods.find { it.name == "setNamespace" && it.parameterCount == 1 }
                
                if (getNamespace != null && setNamespace != null) {
                    val currentNamespace = getNamespace.invoke(androidExt)
                    if (currentNamespace == null || (currentNamespace as? String)?.isEmpty() == true) {
                        val pack = "com.pos.madagascar.${subproject.name.replace("-", "_").replace(":", "_")}"
                        setNamespace.invoke(androidExt, pack)
                        println("Injected namespace for ${subproject.name}: $pack")
                    }
                }
            } catch (e: Exception) {
                println("Failed to inject namespace for ${subproject.name}: ${e.message}")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
