# Positano
This is a weather APP(ideas and technologies come from Yep).

Both CocoaPods and Carthage are used in Positano for third party frameworks management.

Before build,
1.Make sure both CocoaPods and Carthage are updated to latest version at first(run gem install cocoapods and run brew install carthage).
2.Run pod repo update to make CocoaPods aware of the latest available third party frameworks versions.
3.run carthage bootstrap --platform ios to install third party frameworks.
4.run pod install to install third party frameworks.

## Development

If you like to join us developing Yep, fork this repo and use git flow on `develop` branch to create a new branch for your developing. When you finish, send a pull request.

Please ensure each commit is minimized for code review.

You can track our progress at [Trello](https://trello.com/b/kp3Z0kr0/positano).
