# Display title:

CAT, Chain the Activities with Timers

# Short Description:

CAT allows you to Chain the Activities with Timers and Images (form local or a http url), and play it.

These chain of activities are termed as Chains.
CAT comes with sample chains for you to start with, and also let you to create your own Chains, or edit the existing.
CAT provides a simple UI to play these chains interactively or in backgroud.
You can also share and receive the chains in the form of a file (\*.json).

# Long Description:

    CAT comes with sample chain of Timers which can be added to the app with just a tap.
    Home screen of the CAT App shows the buttons to create Chain, add sample, help etc. when No chains are present.
    Home screen of the CAT App shows the list of all Chains, with other friendly options like Create chain, upload chain and search chains.

    Show Chain:
        We can see the details of chain by tapping on it.
        Details will show the sequence of activities in chain from top to bottom with options to Play it, Edit it, Favorite it, Check execution history of chain, delete chain etc.

    Play Chain:
        Chains can be played by tapping the 'Play' Button on respective chain tile, or Chain's own screen.
        Playing chain plays the activites in the chain in a predefined sequence of chain.
        All activities of the chain are associated with Timer Duration.
        Activities auto complete after completion of associated timer duration.
        Activities with Zero timer duration, are kept open until user inputs for its completion.
        Activities can be force completed by presssin the timer running over each activity.
        Activities can be paused and resumed on respective screen.
        Going back from Activity screen will pause the chain and take you to screen where you can see the Chain Execution Status, along with relevant options to take actions on the chain.
        1. Play the current chain activity in Background, and get notified on its compeltion.
        2. If the chain is running in background, then this screen gives you the option to refresh the page for latest status to reflect. Basically the correct time left in activity completion.
        3. If Current activity is not timer activity, then you get a simple option to go forward and continue the chain execution interactively.

        If you choose to back from this screen, then you will land up on the Home screen where List of chains will have the active instance of this chain.
        Chain Tiles on home screen either shows the play button if the chain is paused or stop button if the chain is running in background. As soon as we leave the Play chain screen, chain gets paused.
        Tapping the Chain tile on home screen will take you to Chain Execution screen instead of Chain Details screen, when chain is in Executing state.
        On completion execution of the chain, its execution will start reflecting under the Chain Execution History.
        On chain executoin completion, user get the option to either restart the chain or mark it complete and exit.

    Remove Chain:
        We can swipe the chain right on Home screen to remove the chain from CAT App.
        We can also go the Chain details, where we have delete icon to remove the chain.

    Create Chain of Timers:
        Chat Messenger like UI is used for adding the activities to the chains.
        First you need to give a unique name to chain, and then you can add activities to it.
        Name of Chain is they key field, and it cannot be empty.
        Add timer activity to chain, like we add message to our chat.  We can add Timer Activity with its Name and associated duration using bottom text area (as in general chat window). It gets added to the end of chain the moment we submit the name of Timer. Not specifying any value in duration is Zero duration case, where activity will not auto complete, but it will wait for user input for completion.
        We can drag to rearrange the Timer at it correct place in the Chain.
        We can remove the Timer Activities from the Chain by tapping the delete icon on the activity.
        We can add wait duration between the two timer-activities by tapping between the two Timer Activities.
        We can edit the Timer Activity already present in Chain, by tapping over it. Similarly, we can edit the wait/rest duration between two timer-activities.
        We can select image from Local file system or internet in most common formats including gif.
        Sample workout chain that comes with CAT App has gif images from internet for each timer activity in Chain sequence. Default image is the Logo of CAT App.

    App Settings:
        App Settings allows us to:
        1.Trun on/off App Sound.
        2. App Theme: Dark or Colored.

# Product Feautures Bullets:

    1. Create your own Schedule with the help of Chains of Activities (with Timers) i.e. CAT.
    2. App Comes with Sample Chains to start with.
    3. Share the Chains in simple file format (*.json).
    4. Receive Chains:
        4.1 Simply share the *.json file with CAT App in CAT specific format.
        4.2 Upload *.json file (in CAT specific format) using the Upload Button on home screen of app.
    5. Interactively execute the Chain with Voice Enabled directions.
    6. Pause the chain and continue later, or the paused chain activity in background.
    7. Force complete the activities in the chain.
    8. Check chain's execution history.
    9. Delete the chain.
    10. Dark Theme is also possible.
    11. Disable app sound if you need.
    12. Help instructions (What is CAT?).

# Keywords:

Add, Chain, Execute, Custom, Run, Sequence, Clock, Timer, Schedule, Activities, Activity, stopwatch

# Release Notes:

1. In an attempt to resolve the crash detected in pre launch details, we have updated to the Latest version of all the dependencies along with latest version of Flutter, changed the jdk to version 17 and Kotlin version is changed from 1.7 to 1.9.
2. Stopped the usage of USE_EXACT_ALARM.
3. Target SDK Version is set to 34.
4. Action to 'Refresh home' is added to App Icon on App Header of Home screen.
   Tutorial is updated for this.
