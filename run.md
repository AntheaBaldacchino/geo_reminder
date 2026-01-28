$env:ANDROID_SDK_ROOT="C:\Android\Sdk\sdk"
$env:ANDROID_HOME="C:\Android\Sdk\sdk"
$env:Path="C:\Android\Sdk\sdk\platform-tools;C:\Android\Sdk\sdk\emulator;C:\Android\Sdk\sdk\cmdline-tools\latest\bin;$env:Path"

emulator -list-avds

cd C:\flutter_projects\geo_reminder
flutter run
