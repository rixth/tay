# Tay

Tay is designed to help you swiftly write Google Chrome extensions using your favourite languages and tools.

## Installation

    $ gem install tay

## Usage

Tay helps create, bootstrap, develop and publish Chrome extentions. It all works through the `tay` command.

### Creating

To start work on a new extension, run `tay new [name]`. This will create a new directory, `[name]`, containing a predefined directory structure and files.

### Developing

Tay helps you use languages and techniques like CoffeeScript, CommonJS, SCSS and HAML. As mentioned above, tay generates a basic extension for you, here is an explanation of each item.

The heart any tay project is the `Tayfile`. It defines metadata  about your project and is also used to generate the `manifest.json` that Chrome requires. Some of the basic values will be pre-populated for you. For a full rundown of the Tayfile format, see the docs.

#### Building

To build your extension, run `tay build`. Your files will all be compiled and written in to the `build` subdirectory. At this point, you can load your unpacked extension by following the relevant section in Chrome's [getting started](http://code.google.com/chrome/extensions/getstarted.html) tutorial.

If you run `tay watch` in the top level directory, tay will automatically build whenever a change is detected in the `src` directory *(you still need to go and reload the unpacked extension in Chrome)*.

To use `tay watch` you'll need to add the `[guard-tay](http://github.com/rixth/guard-tay` gem to your Gemfile and run `bundle install`. If you want to customize the directories that are watched for changes, you can generate a [Guardfile](http://github.com/guard/guard) by running `guard init tay`.

### Packaging

When it comes time to publish your extension, Tay can create both .zip files (default, for submission to the Chrome Web Store) and .crx files (for self-hosting) via the `tay package [zip or crx]` command.

There are [certain requirements](http://code.google.com/chrome/extensions/packaging.html) with regards to private keys to allow updates to your extension without changing its ID. Tay will generate a key and place it in the project root. It's up to you whether this gets checked in to version control (not recommended for public GitHub projects). If a key is already present when the packager is run, it will be used.

The filename of the key can be specified using by setting `key_path` in the Tayfile.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
