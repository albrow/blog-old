---
layout: post
title: "Setting Up a Killer Go Development Environment"
date: 2013-07-25 19:49
---

While there are some great resources out there for learning Go, I found that there are not a lot
of resources on what to do next. In this post, I'll share some tips and tricks you can use to set
up a powerful development environment. Next week I'll talk about how to deploy Go to a production
server using git post-recieve hooks.

## What's Go?

Go (sometimes called "golang") is a programming language created by Google engineers in 2009.
It features an intuitive concurrency model, fast compile times, static-typing, and full garbage collection.
It's a general-purpose systems programming language with some of the syntax and convenience of modern scripting
languages.

Go is young. It's different. And it's awesome!


## Learning Go

If you haven't learned Go yet, there are two resources I've found incredibly helpful...
   
- [The Official Interactive Tutorial](http://tour.golang.org/#1)
- [Go By Example](https://gobyexample.com/)

Go has a pretty small standard library, and you'll be surprised how fast you can pick up the basics.

{% img /images/digital/gopher.jpg %}

## Step 1: The Go Workspace

For the Go build tools to work best, it is expected that you follow the conventional directory
structure. You'll need to create a workspace somewhere (I put mine in `~/Documents/programming/go`) with the
following three subdirectories...

1. `src` contains Go source files organized into packages (one package per directory),
2. `pkg` contains package objects, and
3. `bin` contains executable commands.

*(Straight from the [official website](http://golang.org/doc/code.html))*

**Note that your Go workspace cannot be the same as your install directory.**

Once you've done that, you need to let the Go build tools know where your workspace is. If you're on Mac OS or
Linux, this means adding the GOPATH environment variable to your .bash_profile or .bashrc. Something like:

    export GOPATH=path/to/your/go/workspace

It's also a good idea to add the bin directory to your PATH variable. This way you can run compiled Go programs
from any directory. (Again, this would be for Mac OS or Linux.)

    export PATH=$PATH:$GOPATH/bin

All the code you write should reside in the `src` directory. Since all Go packages must have unique path names,
it's a good idea to use either your website name or your github profile as a prefix. For example, all my code resides
in `$GOPATH/src/github.com/stephenalexbrowne/`.


## Step 2: The Editor

As far as I know, there is not a full-fledged IDE for Go yet. My editor of choice is
[Sublime Text](http://www.sublimetext.com/). I use it with some fantastic plugins that make
it feel a lot like an IDE.

{% img /images/digital/gosublime.jpg %}

Here's what you do:

1. Install [Sublime Text](http://www.sublimetext.com/2)
2. Set up the command line tool for [Linux](http://docs.sublimetext.info/en/latest/getting_started/install.html#linux), [Mac OS](http://www.sublimetext.com/docs/2/osx_command_line.html), or [Windows](http://stackoverflow.com/questions/9440639/sublime-text-from-command-line-win7)
3. Install [Sublime Package Control](http://wbond.net/sublime_packages/package_control)
4. Install the [SublimeLinter](https://github.com/SublimeLinter/SublimeLinter) package
5. Install the [GoSublime](https://github.com/DisposaBoy/GoSublime) package

If you follow the steps above, here's all the cool features you get:

- **Open a file or folder from the command line** using `subl filename` or `subl .` If you open a folder, you'll see all the files in the folder on the lefthand side of the editor
- **Intelligent linting** Your editor can detect syntax errors before you even compile
- **Automatic code formatting** Every time you save a file, it will automatically be formatted
  according to convention using gofmt
- **Context aware code completion** Scans the current file and all imported packages for
  relevant methods and fields
- Use `ctrl` + `.`, `ctrl` + `P` to quickly add/remove packages
- Instant documentation with `ctrl` + `shift` + `click`
- Jump to definition with `ctrl` + `shift` + `right click`
- Run all tests or a single test function with `ctrl` + `.`, `ctrl` + `T`
- And [much, much more](https://github.com/DisposaBoy/GoSublime/blob/master/USAGE.md)

*Note: if you're on Mac OS, just replace* `ctrl` *with* `cmd`*.*

## Conclusion

That's it! I hope that this helps you crank out some powerful Go applications. Next time I'll show you how I 
set up and easily deploy to a production server on Amazon EC2.

Are you a fan of Go? Show your support with a [laptop sticker](https://golangstickers.herokuapp.com/)
featuring the gopher mascot.

<a href="https://golangstickers.herokuapp.com/" class="btn btn-blue btn-large center">Get Yours!</a>

<br/>
<br/>

<span class="small">The gopher mascot was designed by [Renée French](http://reneefrench.blogspot.com/)
and is licensed under the [Creative Commons Attribution 3.0](http://creativecommons.org/licenses/by/3.0/) license.
</span>


