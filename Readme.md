[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/Matisse.svg)](https://cocoapods.org/pods/Matisse)
[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/konoma/matisse/blob/master/LICENSE)

# Matisse

Matisse is an image retrieval and caching library for iOS inspired by
[Picasso](https://github.com/square/picasso).


## Usage

With Matisse you can download and display an image in an image view with
a single line:

```swift
Matisse.load(imageURL).showIn(imageView)
```

This automatically takes care of downloading, caching and showing the image
in the view. If you use this code in a `UITableViewDataSource` it also makes
sure that the correct image is shown even in case of a cell reuse.

If you want to resize the image to fit the image view (generally a good idea)
you can do so too:

```swift
Matisse.load(imageURL).resizeTo(size: myImageSize).showIn(imageView)
```

If you just need the image, without loading it into a view, then you can fetch
it like this:

```swift
Matisse.load(imageURL).resizeTo(size: myImageSize).fetch { request, image, error in
    if let fetchedImage = image {
       // do something with the image
    } else {
       // handle the error
    }
}
```


### Configuring Matisse

The shared Matisse instance can be configured with a custom image loader and custom caches (disk and in-memory).
For advanced purposes you can also use a custom request handler that manages image loading as a whole.

You can only configure Matisse before you first use it to load an image. If you need multiple configurations
in your app, see `Creating Multiple Matisse Instances`.


#### Configuring the Image Loader

By default Matisse uses a [`DefaultImageLoader`](Sources/DefaultImageLoader.swift) which loads images using
`URLSession.sharedSession()`.

To customize image loading behavior, you can either provide a different `URLSession` like this:

```swift
Matisse.useImageLoader(DefaultImageLoader(myCustomURLSession))
```

If that does not suit your needs, you can implement a custom [`ImageLoader`](Sources/ImageLoader.swift)
subclass and implement `loadImage(forRequest:completion:)`. There is a `ImageLoaderBase` class intended
to provide common functionality for image loaders.

#### Configuring the Image Caches

Matisse uses two caches to store images. A fast cache and a slow cache.

The fast cache is called synchronously when the context tries to resolve an `ImageRequest`. This
operation is blocking the main thread and should be as fast as possible therefore. Disk access and
other expensive operations should be avoided in the fast cache.

The slow cache is called in an asynchronous fashion from a background thread. Since the main thread
is not blocked this way, the cache is free to use more expensive operations (like disk IO).

Both caches implement the [`ImageCache`](Sources/ImageCache.swift) protocol. By default Matisse
uses an instance of `MemoryImageCache` as the fast cache and `DiskImageCache` for the slow cache.

You can overwrite (or disable) the caches like this:

```swift
// provide a custom ImageCache implementations
Matisse.useFastCache(myFastCache)
Matisse.useSlowCache(mySlowCache)

// disable the caches
Matisse.useFastCache(nil)
Matisse.useSlowCache(nil)
```

#### Providing a Custom Request Handler

To get the most control over the image loading process you can provide your own
[`ImageRequestHandler`](Sources/ImageRequestHandler.swift). This request handler is called when
Matisse cannot resolve a request from the caches (or if they are disabled).

This gives you the most freedom to handle image loading like you whish, but is probably overkill in
most cases.

Provide your own `ImageRequestHandler` like this:

```swift
Matisse.useRequestHandler(myRequestHandler)
```

_Note_: When you provide a custom request handler, the image loader is ignored. Likewise, if you provide
a custom image loader, any custom request handler is replaced by the default handler.


### Creating Multiple Matisse Instances

If you need multiple configurations for Matisse (i.e. different image loaders or caches), then you
can create local instances of the `Matisse` class.

When creating a `Matisse` instance you need to provide a `MatisseContext`. This context provides
the actual image retrieval. To create one you need to provide the caches and a request handler.

```swift
// use defaults or provide custom instances
let fastCache = MemoryImageCache()
let slowCache = DiskImageCache()
let requestHandler = DefaultImageRequestHandler()

// create a local matisse instance
let context = MatisseContext(fastCache: fastCache, slowCache: slowCache, requestHandler: requestHandler)
let matisse = Matisse(context: context)

// then use it like you would use the shared instance
matisse.load(url).showIn(imageView)
```


### Custom Image Transformations

Matisse provides an built-in transformation to resize an image to a target size.

If you would like to have a different image transformation you can implement a custom
[`ImageTransformation`](Sources/ImageTransformation.swift). You need to provide a function
that transforms a `CGImage`, as well as a description that describes your transform exactly.
The description is important because it's used to check if requests are equal when trying
to load an image from the cache.

To use a custom transformation apply it when loading image like this:

```swift
// ColorTransformation would be your custom transformation
let myTransformation = ColorTransformation(type: "BlackAndWhite")

Matisse.load(url)
    .transform(myTransformation) // use the custom transformation
    .showIn(imageView)
```

For convenience consider adding an extension to the `ImageRequestBuilder`:

```swift
extension ImageRequestBuilder {
    
    func colorize(type: String) -> Self {
        return transform(ColorTransformation(type: type))
    }
}
```

Then you can use it like this:

```swift
Matisse.load(url)
    .colorize(type: "BlackAndWhite") // use the custom transformation
    .showIn(imageView)
```


## Installation

### Carthage

To install this library via [Carthage](https://github.com/Carthage/Carthage) add the
following to your `Cartfile`:

```ruby
github "konoma/matisse" ~> 3.0
```

Then run the standard `carthage update` process.


### CocoaPods

To install this library via [CocoaPods](https://cocoapods.org) add the following to
your `Podfile`:

```ruby
pod 'Matisse', '~> 3.0'
```

Then run the standard `pod update` process.


## License

Matisse is released under the [MIT License](LICENSE).
