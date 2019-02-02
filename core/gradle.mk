ifeq ($(LOCAL_PACKAGE_NAME),)
$(error $(LOCAL_PATH): Package modules must define LOCAL_PACKAGE_NAME)
endif

ifneq ($(strip $(LOCAL_MODULE_SUFFIX)),)
$(error $(LOCAL_PATH): Package modules may not define LOCAL_MODULE_SUFFIX)
endif
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)

ifneq ($(strip $(LOCAL_MODULE)),)
$(error $(LOCAL_PATH): Package modules may not define LOCAL_MODULE)
endif
LOCAL_MODULE := $(LOCAL_PACKAGE_NAME)

ifneq ($(strip $(LOCAL_MODULE_CLASS)),)
$(error $(LOCAL_PATH): Package modules may not set LOCAL_MODULE_CLASS)
endif

LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS

intermediates := $(call local-intermediates-dir)
intermediates.COMMON := $(call local-intermediates-dir,COMMON)

flutter_source := $(LOCAL_FLUTTER_SOURCE)
gradle_package_name := $(LOCAL_PACKAGE_NAME)
gradle_fake_root := $(intermediates)
gradle_buildfile := $(intermediates)/build.gradle
gradle_settingsfile := $(intermediates)/settings.gradle
gradle_project_root := $(PWD)/$(LOCAL_PATH)

ifeq ($(flutter_source), true)
gradle_module_path := $(gradle_project_root)/android/app
else
gradle_module_path := $(gradle_project_root)/app
endif

GRADLE_EXEC := prebuilts/gradle/bin/gradle
LOCAL_PREBUILT_MODULE_FILE := $(gradle_fake_root)/gen/$(gradle_package_name)/outputs/apk/release/$(gradle_package_name)-release.apk

$(LOCAL_PREBUILT_MODULE_FILE): gradle_build

write_gradle_root:
	mkdir -p $(gradle_fake_root)/gen
	echo "HAHA YES $(gradle_fake_root)"
	echo "android.dir=$(PWD)" > $(gradle_fake_root)/local.properties
ifeq ($(flutter_source), true)
	echo "flutter.sdk=$(PWD)/external/flutter" >> $(gradle_fake_root)/local.properties
	echo "flutter.versionName=1.0.0" >> $(gradle_fake_root)/local.properties
	echo "flutter.versionCode=1" >> $(gradle_fake_root)/local.properties
	echo "flutter.buildMode=debug" >> $(gradle_fake_root)/local.properties
endif
	echo "buildscript {" > $(gradle_buildfile)
	echo "    repositories {" >> $(gradle_buildfile)
	echo "        maven {" >> $(gradle_buildfile)
	echo "            url 'https://raw.github.com/PotatoProject/external_android-gradle/studio-master-dev'" >> $(gradle_buildfile)
	echo "        }" >> $(gradle_buildfile)
	echo "        google()" >> $(gradle_buildfile)
	echo "        jcenter()" >> $(gradle_buildfile)
	echo "    }" >> $(gradle_buildfile)
	echo "" >> $(gradle_buildfile)
	echo "    dependencies {" >> $(gradle_buildfile)
	echo "        classpath 'com.android.tools.build:gradle:3.3.0-dev'" >> $(gradle_buildfile)
	echo "    }" >> $(gradle_buildfile)
	echo "}" >> $(gradle_buildfile)
	echo "" >> $(gradle_buildfile)
	echo "allprojects {" >> $(gradle_buildfile)
	echo "    repositories {" >> $(gradle_buildfile)
	echo "        maven {" >> $(gradle_buildfile)
	echo "            url 'https://raw.github.com/PotatoProject/external_android-gradle/studio-master-dev'" >> $(gradle_buildfile)
	echo "        }" >> $(gradle_buildfile)
	echo "        google()" >> $(gradle_buildfile)
	echo "        jcenter()" >> $(gradle_buildfile)
	echo "    }" >> $(gradle_buildfile)
	echo "}" >> $(gradle_buildfile)
	echo "" >> $(gradle_buildfile)
	echo "rootProject.buildDir = '$(gradle_fake_root)/gen'" >> $(gradle_buildfile)
	echo "subprojects {" >> $(gradle_buildfile)
	echo "    project.buildDir = \"\$${rootProject.buildDir}/\$${project.name}\"" >> $(gradle_buildfile)
	echo "}" >> $(gradle_buildfile)
	echo "subprojects {" >> $(gradle_buildfile)
	echo "    afterEvaluate {project ->" >> $(gradle_buildfile)
	echo "        if (project.hasProperty('android')) {" >> $(gradle_buildfile)
	echo "          android {" >> $(gradle_buildfile)
	echo "              buildTypes {" >> $(gradle_buildfile)
	echo "                  release {" >> $(gradle_buildfile)
	echo "                      signingConfig signingConfigs.debug" >> $(gradle_buildfile)
	echo "                  }" >> $(gradle_buildfile)
	echo "              }" >> $(gradle_buildfile)
	echo "          }" >> $(gradle_buildfile)
	echo "        }" >> $(gradle_buildfile)
	echo "    }" >> $(gradle_buildfile)
	echo "    project.evaluationDependsOn(':$(gradle_package_name)')" >> $(gradle_buildfile)
	echo "}" >> $(gradle_buildfile)
	echo "" >> $(gradle_buildfile)
	echo "task clean(type: Delete) {" >> $(gradle_buildfile)
	echo "    delete rootProject.buildDir" >> $(gradle_buildfile)
	echo "}" >> $(gradle_buildfile)
	echo "include ':$(gradle_package_name)'" > $(gradle_settingsfile)
	echo "project(':$(gradle_package_name)').projectDir = new File('$(gradle_module_path)')" >> $(gradle_settingsfile)
ifeq ($(flutter_source), true)
	echo "" >> $(gradle_settingsfile)
	echo "def flutterProjectRoot = (new File('$(gradle_project_root)')).toPath()" >> $(gradle_settingsfile)
	echo "" >> $(gradle_settingsfile)
	echo "def plugins = new Properties()" >> $(gradle_settingsfile)
	echo "def pluginsFile = new File(flutterProjectRoot.toFile(), '.flutter-plugins')" >> $(gradle_settingsfile)
	echo "if (pluginsFile.exists()) {" >> $(gradle_settingsfile)
	echo "    pluginsFile.withReader('UTF-8') { reader -> plugins.load(reader) }" >> $(gradle_settingsfile)
	echo "}" >> $(gradle_settingsfile)
	echo "" >> $(gradle_settingsfile)
	echo "plugins.each { name, path ->" >> $(gradle_settingsfile)
	echo "    def pluginDirectory = flutterProjectRoot.resolve(path).resolve('android').toFile()" >> $(gradle_settingsfile)
	echo "    include \":\$$name\"" >> $(gradle_settingsfile)
	echo "    project(\":\$$name\").projectDir = pluginDirectory" >> $(gradle_settingsfile)
	echo "}" >> $(gradle_settingsfile)
endif

gradle_build: write_gradle_root
	$(GRADLE_EXEC) -b $(gradle_buildfile) assembleRelease

flutter_source :=
gradle_package_name :=
gradle_fake_root :=
gradle_buildfile :=
gradle_settingsfile :=
gradle_project_root :=
gradle_module_path :=

include $(BUILD_PREBUILT)
