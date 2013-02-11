## What's This?
This is the code that powers my blog. It's based on Jekyll and Octopress. It's designed to be blazing fast
and cheap to maintain. You can see it at http://blog.alexbrowne.info.

I've decided to open-source it so that interested people can take a gander at the code. However, I haven't
really designed this blog with modification and extension in mind. It's *not* a full-fledged blogging framework.
I don't expect you to fork it or use it as is (but you are free to do so if you want to). Instead, I invite you
to look at the interesting parts, learn from it, copy/modify parts of it, and give me some feedback if you want.

If you're into this sort of thing, there are tons of [other open-source Jekyll blogs](https://github.com/mojombo/jekyll/wiki/Sites) out there.

## How it works
* Posts are written in markdown and compiled to html. (a standard Jekyll feature)
* Stylesheets are written in sass and compiled down to a single css file. (a standard Octopress feature)
* Syntax highlighting and other useful plugins are provided by Octopress.
* Images are automatically compressed on deploy using ImageMagick.
* Html, css, and javascript are automatically minified on deploy using jitify (optional).
* All applicable content (fonts, css, html javascript, etc) is gzipped on deploy.
* Files are stored/hosted on Amazon S3.
* Files are cached on and distributed through Amazon Cloudfront.

## The Interesting Parts
If you're interested in the deploy process, look at plugins/aws_deploy_tools.rb, plugins/red_dragonfly.rb and Rakefile.

If you want to see the styles, look in the /sass directory.

## Acknowledgements
This blog uses all or parts of the following (sometimes with modification): 
* [Octopress by Brandon Mathis](http://octopress.org/) – [(License)](https://github.com/imathis/octopress#license)
* [Jekyll by Tom Preston-Werner & Nick Quaranto](https://github.com/mojombo/jekyll) – [(License)](https://github.com/mojombo/jekyll/blob/master/LICENSE)
* [Bootstrap by Twitter](http://twitter.github.com/bootstrap/) – [(License)](https://github.com/twitter/bootstrap/blob/master/LICENSE)
* [bootstrap-sass by Thomas McDonald](https://github.com/thomas-mcdonald/bootstrap-sass) – [(License)](https://github.com/thomas-mcdonald/bootstrap-sass/blob/master/LICENSE)
* [Font Awesome by Dave Gandy](http://fortawesome.github.com/Font-Awesome) – [(License)](http://fortawesome.github.com/Font-Awesome/#license)

Much thanks to everyone who contributed to the above projects, and to any other projects, frameworks,
or snippets of code that I've incorporated.


## LICENSE
(The MIT License)

Copyright (C) 2012, Alex Browne

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
