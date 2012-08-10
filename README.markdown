Writing a wrapper for the 500px API in Objective-C to make it easier for developers to write apps against this awesome service.

Stil a work in progress; I'm only working on this in my spare time. It currently supports reading from the 500px API and retrieving photos, users, favourites, followers, etc. Check out the [API Documentation](https://github.com/500px/api-documentation) for more information.

Eventually, I'll be creating a wrapping layer so you don't have to deal with `NSURLRequest` instances at all.

## Requirements

This project requires LLVM 4.0+ and Xcode 4.4+, and is compiled with ARC. 

## How to use:

Go to your Xocde project directory and type the following:

    git submodule init
    git submodule add git://github.com/AshFurrow/500px-iOS-api.git

Once the submodule has finished downloading, drag and drop the new Xcode project into your existing project.

![Drag and drop subproject](http://ashfurrow.com/500px-iOS-api/subproject.png)

Now that the subproject is added, we need to link against it. Expand the subproject's Products folder and drag the `libPXAPI.a` file into your projects "Link Binary With libraries" list in the project details editor.

![Drag and drop the library to be linked against](http://ashfurrow.com/500px-iOS-api/linking.png)

Under "Build Settings", add an additional Linker flag of `-ObjC`.

![Additional linker flag](http://ashfurrow.com/500px-iOS-api/linkerflag.png)

Now that you're linking against the library, you're almost done! Wherever you want to use the 500px API, make sure you import the `PXAPIHelper.h` file:

    #import <PXAPI/PXAPI.h>

There are two ways to use this library. The first is to use the `PXAPIHelper` class methods to generate `NSURLRequest` objects to use directly (either with `NSURLConnection` or [`ASIHTTPRequest`](https://github.com/pokeb/asi-http-request/tree). The other way is to use the built-in `PXRequest` class methods to create requests against the 500px API; they provide a completion block that is executed after the request returns, and they also post notifications to the default `NSNotificationCenter`.
