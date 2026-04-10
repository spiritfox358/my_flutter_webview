#### Precompile for ios

`cd ios
rm -rf Pods
rm -rf Podfile.lock
pod install --repo-update
cd ..`

> For new project on iOS, it will crash when second open, the solution is to use release mode

 `flutter run --release`