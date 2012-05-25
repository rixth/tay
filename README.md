# Tay

Tay is designed to help you swiftly write Google Chrome extensions using your favourite languages and tools.

## Quickstart

    $ gem install tay
    $ tay new my_extension
    $ cd my_extension
    $ tay generate browser_action
    $ tay build

Now go and load your extension in Chrome and look in the top right for the puzzle piece!

## Installation

    $ gem install tay

## Usage

Tay helps create, bootstrap, develop and publish Chrome extentions. It all works through the `tay` command. Running `tay` alone will show you a list of commands.

### Creating

To start work on a new extension, run `tay new [name]`. This will create a new directory, `[name]`, containing a predefined directory structure and files.

Take particular note of the Gemfile, it contains several commented out gems which can unlock extra abilities for Tay. Just be sure to run `bundle install` after changes there.

    Usage:
      tay new NAME

    Options:
      [--no-gitignore=Don't create a .gitignore file]
      [--no-gemfile=Don't create a Gemfile file]
      [--use-coffeescript=Use CoffeeScript gem]
      [--use-haml=Use haml gem]

    Create a new extension

### Developing

Tay helps you use languages and techniques like CoffeeScript, CommonJS, SCSS and HAML. As mentioned above, tay generates a basic extension for you, from that point you can use generators to create various code skeletons.

The heart any tay project is the `Tayfile`. It defines metadata  about your project and is also used to generate the `manifest.json` that Chrome requires. Some of the basic values will be pre-populated for you. For a full rundown of the Tayfile format, see the docs.

If you install one of the JavaScript templating gems that Sprockets supports, you can require them like any other file and they'll be included in the `window.JST` object.

#### Generators

Tay ships with a handful of code skeleton generators, documented below. Running `tay generate` will show a list of generators; `tay generate help *generator_name*` will show information specific to that generator.

Currently available generators: page_action, browser_action, content_script.

#### Validating

Tay can validate extensions. By running `tay validate` it will check for mutually-exclusive features and missing fields in specifications as well as ensure that referenced files actually exist.

    Usage:
      tay validate

    Options:
          [--tayfile=Use the specified tayfile instead of Tayfile]
      -b, [--build-directory=The directory containing the built extension]
          # Default: build

    Validate the current extension

#### Building

To build the extension, run `tay build`. Source files will be compiled and written in to the build subdirectory by default. At this point, the unpacked extension can be loaded in to the browser by following the relevant section in Chrome's [getting started](http://code.google.com/chrome/extensions/getstarted.html) tutorial.

    Usage:
      tay build

    Options:
          [--tayfile=Use the specified tayfile instead of Tayfile]
      -b, [--build-directory=The directory to build in]
          # Default: build

    Build the current extension

If you run `tay watch` in the top level directory, tay will automatically build whenever a change is detected in the `src` directory *(you still need to go and reload the unpacked extension in Chrome)*.

To use `tay watch` you'll need to add the `[guard-tay](http://github.com/rixth/guard-tay` gem to your Gemfile and run `bundle install`. If you want to customize the directories that are watched for changes, you can generate a [Guardfile](http://github.com/guard/guard) by running `guard init tay`.

    Usage:
      tay watch

    Options:
          [--tayfile=Use the specified tayfile instead of Tayfile]
      -b, [--build-directory=The directory to build in]
          # Default: build

    Watch the current extension and recompile on file change

### Minifying

If you have the `[uglifier](https://github.com/lautis/uglifier)` and/or `[yui-compressor](https://github.com/sstephenson/ruby-yui-compressor)` gems in your Gemfile, you will be able to minify the JS and CSS in a built extension.

    Usage:
      tay minify

    Options:
          [--tayfile=Use the specified tayfile instead of Tayfile]
      -b, [--build-directory=The directory containing the built extension]
          # Default: build
          [--skip-js=Don't minify *.js files]
          [--skip-css=Don't minify *.css files]

    Minify the CSS and JS of the currently built extension

### Packaging

When it comes time to publish your extension, Tay can create both .zip files (default, for submission to the Chrome Web Store) and .crx files (for self-hosting) via the `tay package` command.

There are [certain requirements](http://code.google.com/chrome/extensions/packaging.html) with regards to private keys to allow updates to your extension without changing its ID. Tay will generate a key and place it in the project root. It's up to you whether this gets checked in to version control (not recommended for public GitHub projects). If a key is already present when the packager is run, it will be used.

The filename of the key can be specified using by setting `key_path` in the Tayfile.

    Usage:
      tay package

    Options:
          [--tayfile=Use the specified tayfile instead of Tayfile]
      -b, [--build-directory=The directory containing the built extension]
          # Default: build
      -t, [--type=The file type to build, zip or crx]
          # Default: zip

    Package the current extension


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

* Generators that can also make haml/coffeescript
* Localization of extensions
* Generator for extension option pages