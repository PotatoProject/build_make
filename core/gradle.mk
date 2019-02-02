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

.PHONY: $(LOCAL_PACKAGE_NAME)_gradle_package_name

ifeq ($($(LOCAL_PACKAGE_NAME)_is_flutter_source), true)
$(LOCAL_PACKAGE_NAME)_gradle_module_path := $($(LOCAL_PACKAGE_NAME)_gradle_project_root)/android/app
else
$(LOCAL_PACKAGE_NAME)_gradle_module_path := $($(LOCAL_PACKAGE_NAME)_gradle_project_root)/app
endif

GRADLE_EXEC := $(PWD)/prebuilts/gradle/bin/gradle
FLUTTER_EXEC := $(PWD)/external/flutter/bin/flutter

LOCAL_PREBUILT_MODULE_FILE := \
  $($(LOCAL_PACKAGE_NAME)_gradle_fake_root)/gen/$($(LOCAL_PACKAGE_NAME)_gradle_package_name)/outputs/apk/release/$($(LOCAL_PACKAGE_NAME)_gradle_package_name)-release.apk

$(LOCAL_PREBUILT_MODULE_FILE): $(LOCAL_PACKAGE_NAME)_gradle_package_name $(GRADLE_EXEC) $(FLUTTER_EXEC)
	$(call write_gradle_root, $@)
	$(call gradle_build, $@)

define write_gradle_root
rm -rf $($($<)_gradle_fake_root)
mkdir -p $($($<)_gradle_fake_root)/gen;
echo "android.dir=$(PWD)" > $($($<)_gradle_fake_root)/local.properties
if [[ "$($($<)_is_flutter_source)" = "true" ]]; then \
	echo "flutter.sdk=$(PWD)/external/flutter" >> $($($<)_gradle_fake_root)/local.properties; \
	echo "flutter.versionName=1.0.0" >> $($($<)_gradle_fake_root)/local.properties; \
	echo "flutter.versionCode=1" >> $($($<)_gradle_fake_root)/local.properties; \
	echo "flutter.buildMode=debug" >> $($($<)_gradle_fake_root)/local.properties; \
fi
echo "buildscript {" > $($($<)_gradle_buildfile)
echo "    repositories {" >> $($($<)_gradle_buildfile)
echo "        maven {" >> $($($<)_gradle_buildfile)
echo "            url 'https://raw.github.com/PotatoProject/external_android-gradle/studio-master-dev'" >> $($($<)_gradle_buildfile)
echo "        }" >> $($($<)_gradle_buildfile)
echo "        google()" >> $($($<)_gradle_buildfile)
echo "        jcenter()" >> $($($<)_gradle_buildfile)
echo "    }" >> $($($<)_gradle_buildfile)
echo "" >> $($($<)_gradle_buildfile)
echo "    dependencies {" >> $($($<)_gradle_buildfile)
echo "        classpath 'com.android.tools.build:gradle:3.3.0-dev'" >> $($($<)_gradle_buildfile)
echo "    }" >> $($($<)_gradle_buildfile)
echo "}" >> $($($<)_gradle_buildfile)
echo "" >> $($($<)_gradle_buildfile)
echo "allprojects {" >> $($($<)_gradle_buildfile)
echo "    repositories {" >> $($($<)_gradle_buildfile)
echo "        maven {" >> $($($<)_gradle_buildfile)
echo "            url 'https://raw.github.com/PotatoProject/external_android-gradle/studio-master-dev'" >> $($($<)_gradle_buildfile)
echo "        }" >> $($($<)_gradle_buildfile)
echo "        google()" >> $($($<)_gradle_buildfile)
echo "        jcenter()" >> $($($<)_gradle_buildfile)
echo "    }" >> $($($<)_gradle_buildfile)
echo "}" >> $($($<)_gradle_buildfile)
echo "" >> $($($<)_gradle_buildfile)
echo "rootProject.buildDir = '$($($<)_gradle_fake_root)/gen'" >> $($($<)_gradle_buildfile)
echo "subprojects {" >> $($($<)_gradle_buildfile)
echo "    project.buildDir = \"\$${rootProject.buildDir}/\$${project.name}\"" >> $($($<)_gradle_buildfile)
echo "}" >> $($($<)_gradle_buildfile)
echo "subprojects {" >> $($($<)_gradle_buildfile)
echo "    afterEvaluate {project ->" >> $($($<)_gradle_buildfile)
echo "        if (project.hasProperty('android')) {" >> $($($<)_gradle_buildfile)
echo "          android {" >> $($($<)_gradle_buildfile)
echo "              buildTypes {" >> $($($<)_gradle_buildfile)
echo "                  release {" >> $($($<)_gradle_buildfile)
echo "                      signingConfig signingConfigs.debug" >> $($($<)_gradle_buildfile)
echo "                  }" >> $($($<)_gradle_buildfile)
echo "              }" >> $($($<)_gradle_buildfile)
echo "          }" >> $($($<)_gradle_buildfile)
echo "        }" >> $($($<)_gradle_buildfile)
echo "    }" >> $($($<)_gradle_buildfile)
echo "    project.evaluationDependsOn(':$($($<)_gradle_package_name)')" >> $($($<)_gradle_buildfile)
echo "}" >> $($($<)_gradle_buildfile)
echo "" >> $($($<)_gradle_buildfile)
echo "task clean(type: Delete) {" >> $($($<)_gradle_buildfile)
echo "    delete rootProject.buildDir" >> $($($<)_gradle_buildfile)
echo "}" >> $($($<)_gradle_buildfile)
echo "include ':$($($<)_gradle_package_name)'" > $($($<)_gradle_settingsfile)
echo "project(':$($($<)_gradle_package_name)').projectDir = new File('$($($<)_gradle_module_path)')" >> $($($<)_gradle_settingsfile)
if [[ "$($($<)_is_flutter_source)" = "true" ]]; then \
	echo "" >> $($($<)_gradle_settingsfile); \
	echo "def flutterProjectRoot = (new File('$($($<)_gradle_project_root)')).toPath()" >> $($($<)_gradle_settingsfile); \
	echo "" >> $($($<)_gradle_settingsfile); \
	echo "def plugins = new Properties()" >> $($($<)_gradle_settingsfile); \
	echo "def pluginsFile = new File(flutterProjectRoot.toFile(), '.flutter-plugins')" >> $($($<)_gradle_settingsfile); \
	echo "if (pluginsFile.exists()) {" >> $($($<)_gradle_settingsfile); \
	echo "    pluginsFile.withReader('UTF-8') { reader -> plugins.load(reader) }" >> $($($<)_gradle_settingsfile); \
	echo "}" >> $($($<)_gradle_settingsfile); \
	echo "" >> $($($<)_gradle_settingsfile); \
	echo "plugins.each { name, path ->" >> $($($<)_gradle_settingsfile); \
	echo "    def pluginDirectory = flutterProjectRoot.resolve(path).resolve('android').toFile()" >> $($($<)_gradle_settingsfile); \
	echo "    include \":\$$name\"" >> $($($<)_gradle_settingsfile); \
	echo "    project(\":\$$name\").projectDir = pluginDirectory" >> $($($<)_gradle_settingsfile); \
	echo "}" >> $($($<)_gradle_settingsfile); \
fi
endef

define gradle_build
if [[ "$($($<)_is_flutter_source)" = "true" ]]; then \
	WD=$(pwd); \
	cd $($($<)_gradle_project_root); \
	$(FLUTTER_EXEC) packages get; \
	cd ${WD}; \
fi
$(GRADLE_EXEC) -b $($($<)_gradle_buildfile) assembleRelease
endef

include $(BUILD_PREBUILT)
