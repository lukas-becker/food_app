
# Snack Hunter  
  
Search recipes by ingredients, or by name, store your favorites and manage a shopping list.
  
## Usage Notes  
  
This application was developed in flutter. To build it you need to have flutter installed and in your path variable.
If these prerequisites are met you can clone the repo and run: 
```
flutter build apk
```
inside the cloned folder.

We tested the application on devices and emulators running API level 28, 29 and  30. 
On level 28 and 29 the debug console will print an error message related to firebase. This is an issue in the Android Source that we cannot fix. Apparently it's fixed in API level 30.

We tested the application with flutter 1.22.3, 1.22.5 and 1.23.0.