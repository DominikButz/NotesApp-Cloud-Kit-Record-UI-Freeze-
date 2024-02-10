# Buggy Notes App

## Minimum Reproducible Example for the MacOS 14 / iOS 17 Cloud Kit UI freeze bug


Update (10/2/2024): Apple replied on the Apple developer forum - it seems calls to the CK record or recordID should always be done on a background thread. Moreover, it is better to use a custom id to handle user favorites / bookmarking etc.  I have updated the repo accordingly.

[Original post and answer](https://developer.apple.com/forums/thread/746080)



### Bug Description

Calling record(for: ..) on the core data NSPersistentCloudKitContainer instance makes the app unresponsive under certain circumstances.

Apparently, this bug only appeared with iOS 17.x / MacOS 14.x


### Prerequisites

- active Apple developer account
- signed in iCloud on Simulator / real device
- XCode 15.1 or later (bug is still there with XCode 15.2!)
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

In iOS, the bug cannot be reproduced in the same way and the "UI freeze" isn't permanent like on MacOS

- Select an iOS simulator (or real device) as target device
- Launch the app from Xcode
- Click on the +Button to add a note. 
- Fill in a title and a text
- Right-click on the new note in the side bar list. 
- In the context-menu click "Add to favorites"

Contrary to the MacOS version, there is no UI freeze at this stage. The note should be visible in the "Favorites" section now

- Stop the app in Xcode
- turn off all network connections (wifi on Mac OS if you use an iPhone simulator or wifi and LTE/5G on a real iPhone)
- Launch the app again from Xcode

Result: the UI is frozen. Again if you click on the pause button in Xcode, you will see that the culprit is this line in the .task-modifier block (ContentView)

       if let recordName = persistence.container.record(for: note.objectID)?.recordID.recordName {
       ...
      }

- let the app resume by clicking the play button beside the pause button
- Activate the network connection again and wait a few seconds
- The app should be responsive again. Note that all notes marked as favorites should now move to the favorites section

### Expected Behavior

This UI freeze should not happen. first of all, the record-for function called on the persistent cloud kit container has an optional return type. If the CoreData object has never been synced to CloudKit before, then there simply is no record. 
However, if the app is offline and there is a CK record that was created before the app went offline, it should be no problem to call the function during offline state. 



### FAQs

**1. Why don't you simply add a boolean property called "isFavorite" to the note object? This way you can avoid accessing the CKrecord of a notes object in the first place.**

That is a naive approach. What if I want to extend the app's funcionality by adding cloud kit sharing?  That would mean the current user editing the note can determine the favorite state for all users the note is shared with...  This wouldn't make any sense. 

**2. OK, but instead of creating a boolean, simply create a custom ID that can be used instead of the CK record**

This is a valid point. I might actually do just that as a workaround as long as my actual app is in beta.  

The problem: in the app I'm actually working on for reasons that would lead to far to explain, I have a deduplication logic in place that works separately for each CK zone name. In order to get the zone name of a CK record, you need to get the recordId, just as shown above. 
It turns out that the same problem occurs under MacOS and iOS as shown above.
And I'm sure there are plenty of other reasons to directly access the cloud kit records. 


 
 
 
       