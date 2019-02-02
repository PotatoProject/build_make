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

$(LOCAL_PACKAGE_NAME)_is_flutter_source := $(LOCAL_FLUTTER_SOURCE)
$(LOCAL_PACKAGE_NAME)_gradle_package_name := $(LOCAL_PACKAGE_NAME)
$(LOCAL_PACKAGE_NAME)_gradle_fake_root := $(intermediates)
$(LOCAL_PACKAGE_NAME)_gradle_buildfile := $(intermediates)/build.gradle
$(LOCAL_PACKAGE_NAME)_gradle_settingsfile := $(intermediates)/settings.gradle
$(LOCAL_PACKAGE_NAME)_gradle_project_root := $(PWD)/$(LOCAL_PATH)

ifeq ($($(LOCAL_PACKAGE_NAME)_is_flutter_source), true)
$(LOCAL_PACKAGE_NAME)_gradle_module_path := $($(LOCAL_PACKAGE_NAME)_gradle_project_root)/android/app
else
$(LOCAL_PACKAGE_NAME)_gradle_module_path := $($(LOCAL_PACKAGE_NAME)_gradle_project_root)/app
endif

GRADLE_EXEC := prebuilts/gradle/bin/gradle
LOCAL_PREBUILT_MODULE_FILE := $($(LOCAL_PACKAGE_NAME)_gradle_fake_root)/gen/$($(LOCAL_PACKAGE_NAME)_gradle_package_name)/outputs/apk/release/$($(LOCAL_PACKAGE_NAME)_gradle_package_name)-release.apk

$(LOCAL_PREBUILT_MODULE_FILE): $(LOCAL_PACKAGE_NAME)_gradle_build

$(LOCAL_PACKAGE_NAME)_write_gradle_root:
	mkdir -p $($(LOCAL_PACKAGE_NAME)_gradle_fake_root)/gen
	echo "HAHA YES $($(LOCAL_PACKAGE_NAME)_gradle_fake_root)"
	echo "android.dir=$(PWD)" > $($(LOCAL_PACKAGE_NAME)_gradle_fake_root)/local.properties
ifeq ($($(LOCAL_PACKAGE_NAME)_is_flutter_source), true)
	echo "flutter.sdk=$(PWD)/external/flutter" >> $($(LOCAL_PACKAGE_NAME)_gradle_fake_root)/local.properties
	echo "flutter.versionName=1.0.0" >> $($(LOCAL_PACKAGE_NAME)_gradle_fake_root)/local.properties
	echo "flutter.versionCode=1" >> $($(LOCAL_PACKAGE_NAME)_gradle_fake_root)/local.properties
	echo "flutter.buildMode=debug" >> $($(LOCAL_PACKAGE_NAME)_gradle_fake_root)/local.properties
endif
	echo "buildscript {" > $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    repositories {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        maven {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "            url 'https://raw.github.com/PotatoProject/external_android-gradle/studio-master-dev'" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        google()" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        jcenter()" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    dependencies {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        classpath 'com.android.tools.build:gradle:3.3.0-dev'" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "}" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "allprojects {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    repositories {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        maven {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "            url 'https://raw.github.com/PotatoProject/external_android-gradle/studio-master-dev'" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        google()" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        jcenter()" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "}" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "rootProject.buildDir = '$($(LOCAL_PACKAGE_NAME)_gradle_fake_root)/gen'" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "subprojects {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    project.buildDir = \"\$${rootProject.buildDir}/\$${project.name}\"" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "}" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "subprojects {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    afterEvaluate {project ->" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        if (project.hasProperty('android')) {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "          android {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "              buildTypes {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "                  release {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "                      signingConfig signingConfigs.debug" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "                  }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "              }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "          }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "        }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    }" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    project.evaluationDependsOn(':$($(LOCAL_PACKAGE_NAME)_gradle_package_name)')" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "}" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "task clean(type: Delete) {" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "    delete rootProject.buildDir" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "}" >> $($(LOCAL_PACKAGE_NAME)_gradle_buildfile)
	echo "include ':$($(LOCAL_PACKAGE_NAME)_gradle_package_name)'" > $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "project(':$($(LOCAL_PACKAGE_NAME)_gradle_package_name)').projectDir = new File('$($(LOCAL_PACKAGE_NAME)_gradle_module_path)')" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
ifeq ($($(LOCAL_PACKAGE_NAME)_is_flutter_source), true)
	echo "" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "def flutterProjectRoot = (new File('$($(LOCAL_PACKAGE_NAME)_gradle_project_root)')).toPath()" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "def plugins = new Properties()" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "def pluginsFile = new File(flutterProjectRoot.toFile(), '.flutter-plugins')" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "if (pluginsFile.exists()) {" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "    pluginsFile.withReader('UTF-8') { reader -> plugins.load(reader) }" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "}" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "plugins.each { name, path ->" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "    def pluginDirectory = flutterProjectRoot.resolve(path).resolve('android').toFile()" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "    include \":\$$name\"" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "    project(\":\$$name\").projectDir = pluginDirectory" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
	echo "}" >> $($(LOCAL_PACKAGE_NAME)_gradle_settingsfile)
endif

$(LOCAL_PACKAGE_NAME)_gradle_build: $(LOCAL_PACKAGE_NAME)_write_gradle_root
	$(GRADLE_EXEC) -b $($(LOCAL_PACKAGE_NAME)_gradle_buildfile) assembleRelease

$(LOCAL_PACKAGE_NAME)_is_flutter_source :=
$(LOCAL_PACKAGE_NAME)_gradle_package_name :=
$(LOCAL_PACKAGE_NAME)_gradle_fake_root :=
$(LOCAL_PACKAGE_NAME)_gradle_buildfile :=
$(LOCAL_PACKAGE_NAME)_gradle_settingsfile :=
$(LOCAL_PACKAGE_NAME)_gradle_project_root :=
$(LOCAL_PACKAGE_NAME)_gradle_module_path :=

include $(BUILD_PREBUILT)
