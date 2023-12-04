# Timemanager front-end

Make sure npm is installed on your computer.

To start the vue.js application and the front-end of our timemanager

  * Make sure you already started the back-end application
  * Run `npx serve` to start the front-end application
  * Follow the instructions on your terminal

To convert the vue.js in a native android application

  * Make sure you have java jdk-17 and gradle 8.0.2
  * Run `npx cap init` to init your app project
  * Run `npm i @capacitor/android` to create your android project (@capacitor/ios for iOS project)
  * Run `npx cap add android` or ios
  * Run `npx cap sync` to copy your built web application to your project and install the native projects dependencies
  * Once this is done you can test your application by executing `pnpm exec ionic build && pnpm exec cap copy android && [@cwd]pnpm exec cap run android --target=Pixel_7_Pro_API_33  --external --no-build`, replace Pixel_7_Pro_API_33 by the name of your emulator or use vscode tools
  * To build the apk run `ionic capacitor build android` or ios