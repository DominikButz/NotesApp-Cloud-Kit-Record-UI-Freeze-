# Notes App

## Minimum Reproducible Example for the MacOS 14 / iOS 17 Cloud Kit UI freeze bug

### Bug Description

Calling record(for: ..) on the core data NSPersistentCloudKitContainer instance makes the app unresponsive under certain circumstances.

Apparently, this bug only appeared with iOS 17 / MacOS 14


### Prerequisites

- active Apple developer account
- signed in iCloud on Simulator / real device
- XCode 15.1 or later
- MacOS 14.0 or later / iOS 17.0 or later


### Project setup

- In the target "Notes App" under "General" / "Identity" fill in your own bundle identifier
- Under "Signing & Capabilities":
	- make sure remote notifications are switched on
	- under iCloud, activate "Key Value Storage" and "CloudKit"
	- Add your own cloudKit identifier (e.g. iCloud.com.SwiftyNotes)

### Reproducing the bug: MacOS

- Select the MacOS as target device
- Launch the app from Xcode
- Click on the +Button to add a note. 
- Fill in a title and a text
- Right-click on the new note in the side bar list. 
- In the context-menu click "Add to favorites"

Result: the UI freezes, you should see the "beach ball of terror" spin forever... 
Next, click the **pause** button  (not the stop button!) in Xcode to interrupt the app.  

In the process view on the left side, you will see that the culprit is this line in the favoriteButton action closure (ContentView):

       if let recordName = persistence.container.record(for: note.objectID)?.recordID.recordName {
       ...
      }
       
 The app actually doesn't crash - it just becomes unresponsive. There seems to be no way to revive it other than killing the process by pressing the stop button in Xcode. 
 

### Reproducing the bug: iOS

In iOS, the bug cannot be reproduced in the same way. 

... 
 
 
 
       