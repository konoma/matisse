[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage) [![CocoaPods](https://img.shields.io/cocoapods/v/Matisse.svg)](https://cocoapods.org/pods/Matisse) [![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/konoma/matisse/blob/master/LICENSE)

# Matisse

Matisse is an image retrieval and caching library for iOS inspired by
[Picasso](https://github.com/square/picasso).


## Usage

With Matisse you can download and display an image in an image view with
a single line:

    Matisse.load(imageURL).showIn(imageView)

This automatically takes care of downloading, caching and showing the image
in the view. If you use this code in a `UITableViewDataSource` it also makes
sure that the correct image is shown even in case of a cell reuse.

If you want to resize the image to fit the image view (generally a good idea)
you can do so too:

    Matisse.load(imageURL).resizeTo(myImageSize).showIn(imageView)

If you just need the image, without loading it into a view, then you can fetch
it like this:

    Matisse.load(imageURL).resizeTo(myImageSize).fetch { request, image, error in
        if let fetchedImage = image {
           // do something with the image
        } else {
           // handle the error
        }
    }


## Installation

### Carthage

To install this library via [Carthage](https://github.com/Carthage/Carthage) add the
following to your `Cartfile`:

    github "konoma/matisse" ~> 1.0

Then run the standard `carthage update` process.


### Cocapods

To install this library via [Cocoapods](https://cocoapods.org) add the following to
your `Podfile`:

    pod 'Matisse', '~> 1.0'

Then run the standard `pod update` process.


## License

Matisse is released under the [MIT License](https://github.com/konoma/matisse/blob/master/LICENSE).