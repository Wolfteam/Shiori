allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File(rootProject.projectDir, "../build")

subprojects {
    buildDir = File(rootProject.buildDir, name)
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
