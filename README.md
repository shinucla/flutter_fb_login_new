# flutter_fb_login_new

A new flutter project for using flutter_facebook_login dependency

## Getting Started

Step 1: Started from scratch:
  generate a default project
  >flutter create flutter_fb_login_new

Step 2: Adding dependencies in pubspec.yaml
  date_format
  flutter_facebook_login
  flutter_secure_storage
  http

Step 3: Prepare for environment
  - run "flutter packages get" on both anroid and ios environments
  - a Podfile will be generated if running on mac for ios environment

Step 3: Configure for dependencies
  - flutter_secure_storage:
    - Android: android/app/build.gradle > increase minSdkVersion from 16 to 18
    - ios:     none
      
  - flutter_facebook_login
    - Android: https://developers.facebook.com/docs/facebook-login/android
               create new strings.xml (android/app/src/main/values/strings.xml)
	       modified AndroidManifest.xml
	       
    