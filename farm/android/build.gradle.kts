import org.gradle.api.tasks.Delete
import org.gradle.api.Project
import org.gradle.api.file.Directory

// Correct plugin configuration
buildscript {
    ext.kotlin_version = '1.8.22'  // Flutter-compatible version
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms.google-services:4.3.15'
    }
}

//  Repositories
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Custom build output directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// ✅ Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}