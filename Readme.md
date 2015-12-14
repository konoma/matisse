# Matisse

Matisse is an image retrieval and caching library for iOS inspired by
[Picasso](https://github.com/square/picasso).


## Examples

With Matisse you can download and display an image in an image view with
a single line:

    Matisse.load(imageURL).showIn(imageView)

Or in Objective-C:

    [MTSMatisse load:imageURL].showIn(imageView);

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

TBD (Cocoapods)