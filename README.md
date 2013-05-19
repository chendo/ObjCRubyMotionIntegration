# Use RubyMotion within an Objective-C project

This repo contains a sample project where an Objective-C project is set up to compile and embed RubyMotion classes. It also demonstrates sharing CocoaPods between the two projects via symlinks until I get around to making `motion-cocoapods` use existing Podfiles.

This was based off [@clayallsopp](http://github.com/clayallsopp)'s article on [Mixing Objective-C and Ruby](http://clayallsopp.com/posts/mixing-objective-c-and-ruby/). Please read the article for more information.

## What it does

On the Ruby side, `CDORubyLand` defines a `run` method which uses `RACSignal` to log the current time to console every second.

`CDOAppDelegate` instantiates an instance of `CDORubyLand` and calls `run` method. The window is purely for show.

![Screenshot of output](http://f.cl.ly/items/410G393a3T330R2N1N1U/Screen%20Shot%202013-05-19%20at%202.02.41%20PM.png)

## Build configuration

This project adds a build script that automatically runs `rake static` to create the static library to be included into the Objective-C part of the project. It's important to note that I had to set the `GEM_ROOT` and `GEM_PATH` environment variables for it to pick up my `motion-cocoapods` install. You'll need to change this path to suit yours if you're using `rbenv` or similar.

You must also set the input files to the Ruby files, and the output file of the build script to have the static library, otherwise Xcode won't run this at the right part of the build.

![Screenshot of build configuration](http://cl.ly/image/0F3u3b2J2W2T/Screen%20Shot%202013-05-19%20at%201.59.58%20PM.png)

## Linking

You must add the following files to the Linked Frameworks and Libraries section:

* libstdc++.dylib
* libc++.dylib
* libicucore.dylib
* libc++abi.dylib
* [your app]-universal.a

## Header files

RubyMotion does not generate header files so you'll need to do it yourself. I've found that you can't use `(void)` for method return values as all Ruby methods implicitly return an object.

## Caveats

I couldn't seem to use `RACSignal#take` due to this error:

```
Objective-C stub for message `take:' type `@@:Q' not precompiled. Make sure you properly link with the framework or library that defines this message.
```

If you know how to fix this issue, please let me know!

## Future improvements

* Automatically generate header files from Ruby classes
* Remove the need to symlink `vendor/Pods` etc via patching `motion-cocoapods`
* Automatically set up the build phase to compile the Ruby static lib

Pull requests and comments welcome!
