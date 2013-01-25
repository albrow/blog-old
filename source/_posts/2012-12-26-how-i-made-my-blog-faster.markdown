---
layout: post
title: "How I Made my Blog 2.3x Faster"
date: 2012-12-26 22:22
---

**tl;dr:**
I converted my blog to a
static site using Jekyll/Octopress and am now hosting it on Amazon
CloudFront. It is much faster. There are tons of benchmarks and charts
near the bottom of this post.

Before
------

- Ruby on Rails framework
- Hosted on Heroku (single dyno)
- Unicorn as a server
- Memcached + Dalli (5MB tier Heroku add-on)
- Images hosted on CloudFront
- No image compression or gzipping

Before I made the switch, my blog was a small Ruby on Rails app hosted on
Heroku. I was using [Unicorn](https://github.com/defunkt/unicorn) as
a server, which meant I could run multiple server processes on a single
Heroku dyno. After some tweaking, I determined that 6 running processes
was the sweet spot. I was also using [Memcached](http://memcached.org/)
and the [Dalli gem](https://github.com/mperham/dalli) for in-memory caching.
Because my pockets were (and are) empty, I was on the free 5MB teir add-on
from Heroku. I was also hosting images on CloudFront, but nothing else. This
costed me only pennies a month.

Before I go any further, I want to emphasize that this setup *was
performing great*. I wasn't noticing any serious performance
issues. I was motivated by curiosity and a drive to try and create something
even better, not by any shortcomings in Heroku or the Rails framework.

After
-----

- Jekyll & Octopress as a framework
- Everything is hosted on CloudFront
- Almost everything is gzipped
- Images are compressed with ImageMagick

I wanted to see if I could make my blog as fast as possible for free,
or at least dirt cheap. I decided to give [Jekyll](https://github.com/mojombo/jekyll) 
a try. Jekyll is a static site generator written in Ruby and specifically
designed for blogs. The basic idea is that instead of having a backend
framework and a database, you can convert everything in your blog to
plain old html files (like the olden days). Because Jekyll is so bare bones,
I also used [Octopress](http://octopress.org/), a blogging platform
built on top of Jekyll that powers Github Pages. (I ended up trimming **a lot**
of fat from it, saving only the pieces I needed). I expect that this will
still only cost pennies a month.

To squeeze every last bit of performance out of my blog, I made some other
important changes. First, I gzipped all the html, css, js, and fonts. Next, I
compressed all the images automatically using
[ImageMagick](http://www.imagemagick.org/script/index.php). Finally, I removed
**all** the javascript (except for google analytics). That's right. It turns out
I didn't really need it. If that ever changes I can always add it back.

In case you're curious, I made [a gist which shows my deploy process](https://gist.github.com/4385707).
Everything is automatic. When I run `bundle exec rake deploy`
this is what happens:

1. Re-generate the site using Jekyll.
2. Minify all html, css, and js using [jitify](http://www.jitify.com/). (optional)
3. Gzip everything that should be gzipped.
4. Compress all images using ImageMagick.
5. Sync with Amazon S3 (only upload the files that have changed).
6. Invalidate the objects on CloudFront as needed.

Benchmarks
----------
I used three different tools to test my new blog setup.

- [Apache Benchmark](http://httpd.apache.org/docs/2.2/programs/ab.html)
- [Which Loads Faster](http://whichloadsfaster.com/)
- [Pingdom Full Page Tester](http://tools.pingdom.com/fpt/)

For each tool, I tested three different pages: the homepage, a post with one picture,
and a post with no pictures. I always tested the most direct domain name possible,
i.e. instead of *blog.alexbrowne.info* I used *d1koatif4i39jr.cloudfront.net*.
[All of the data from these benchmarks](https://docs.google.com/spreadsheet/ccc?key=0AsmDpu3Djd_vdFdzNmhoelRCcjFtZlFWYWpoQUZNRHc)
is publicly viewable.

*I also intended to use [Blitz](https://www.blitz.io/dashboard) but a Javascript error
prevented the site from working correctly at the time of this writing. (A shame, because
I've been pretty happy with them in the past). I will try again later and post an update
if it works.*

### Apache Benchmark

Apache Benchmark (ab) gives the tester a lot of control and is able to spawn
multiple user threads that load a web page simultaneously. Each user thread will
wait until a request is completed before it starts the next one, and it will keep
sending requests until the test terminates. Since ab runs on your own computer,
**it can be limited by your hardware and/or internet connection**. Also, it is
my understanding that ab does not load images.

For each of the three pages, I ran 9 different tests with
1,000 requests and different levels of concurrency ranging from 1 to 1,000.
The tenth test (the "stress test") was 10,000 requests at a concurrency level
of 1,000.

<table class="table table-bordered table-hover">
		
		<tr>
			<th colspan="4" style="font-size: 18px">
				Dynamic Site tested by Apache Benchmark
			</th>
		</tr>

		<tr>
	    <th>Concurrency</th>
	    <th>Time (ms)</th>
	    <th>Req/s</th>
	    <th>Transfer Rate (Kb/s)</th>
	  </tr>

	  <tr>
	    <th>1</th>
	    <td>63.67</td>
	    <td>15.89</td>
	    <td>154.76</td>
	  </tr>

	   <tr>
	    <th>5</th>
	    <td>82.67</td>
	    <td>60.87</td>
	    <td>599.67</td>
	  </tr>

	  <tr>
	    <th>10</th>
	    <td>93.33</td>
	    <td>110.35</td>
	    <td>1053.7</td>
	  </tr>

	   <tr>
	    <th>25</th>
	    <td>237.33</td>
	    <td>110.17</td>
	    <td>1034.6</td>
	  </tr>

	  <tr>
	    <th>50</th>
	    <td>433.67</td>
	    <td>118.41</td>
	    <td>1123.9</td>
	  </tr>

	  <tr>
	    <th>100</th>
	    <td>851.67</td>
	    <td>117.64</td>
	    <td>1119.5</td>
	  </tr>

	  <tr>
	    <th>250</th>
	    <td>1880.7</td>
	    <td>119.39</td>
	    <td>1137.3</td>
	  </tr>

	  <tr>
	    <th>500</th>
	    <td>3360.3</td>
	    <td>116.31</td>
	    <td>1107.1</td>
	  </tr>

	  <tr>
	    <th>1000</th>
	    <td>5436.0</td>
	    <td>99.44</td>
	    <td>999.15</td>
	  </tr>

	  <tr>
	    <th>Stress Test</th>
	    <td>10754</td>
	    <td>101.49</td>
	    <td>919.58</td>
	  </tr>

</table>

<table class="table table-bordered table-hover">
		
		<tr>
			<th colspan="4" style="font-size: 18px">
				Static Site tested by Apache Benchmark
			</th>
		</tr>

		<tr>
	    <th>Concurrency</th>
	    <th>Time (ms)</th>
	    <th>Req/s</th>
	    <th>Transfer Rate (Kb/s)</th>
	  </tr>

	  <tr>
	    <th>1</th>
	    <td>39.33</td>
	    <td>25.65</td>
	    <td>122.57</td>
	  </tr>

	   <tr>
	    <th>5</th>
	    <td>58.33</td>
	    <td>86.64</td>
	    <td>441.86</td>
	  </tr>

	  <tr>
	    <th>10</th>
	    <td>87.00</td>
	    <td>114.35</td>
	    <td>561.97</td>
	  </tr>

	   <tr>
	    <th>25</th>
	    <td>82.67</td>
	    <td>295.09</td>
	    <td>1467.3</td>
	  </tr>

	  <tr>
	    <th>50</th>
	    <td>145.00</td>
	    <td>357.13</td>
	    <td>1727.3</td>
	  </tr>

	  <tr>
	    <th>100</th>
	    <td>161.00</td>
	    <td>575.52</td>
	    <td>2859.4</td>
	  </tr>

	  <tr>
	    <th>250</th>
	    <td>478.00</td>
	    <td>367.74</td>
	    <td>1849.3</td>
	  </tr>

	  <tr>
	    <th>500</th>
	    <td>883.67</td>
	    <td>312.38</td>
	    <td>1562.2</td>
	  </tr>

	  <tr>
	    <th>1000</th>
	    <td>1536.0</td>
	    <td>279.37</td>
	    <td>1370.2</td>
	  </tr>

	  <tr>
	    <th>Stress Test</th>
	    <td>5271.7</td>
	    <td>170.14</td>
	    <td>829.15</td>
	  </tr>

</table>

Note the logarithmic scale on the folowing line chart...

{% img /images/digital/ab-benchmark-chart.jpg %}

{% pullquote %}
{" Based on average response time, the static site performed 2.65x (or 62.3%)
better than the dynamic one. "} The static site was also able to sustain a 166%
higher request rate and a 39% higher transfer rate.

The sweet spot for the static site seems to be around a concurrency level
of 100. At that level, the static site was able to serve an impressive
575 req/s at 2,859 Kb/s. All the while maintaining an average response
time of only 161 ms! That's more than 500% better than the dynamic site
performed at the same test.

Another important note is that the dynamic site had an average error rate
of about 19%. The Heroku logs didn't indicate that anything was amiss, so I
don't know exactly what was causing the errors. On the other hand, in all the
trials the static site didn't return a single error! Already we can see
that the new site is performing better and more consistently under heavy
load.
{% endpullquote %}

### Which Loads Faster

Unlike Apache Benchmark, this tool only does one request at a time. I believe
it uses your own hardware and internet connection, and it does load everything
on the page, including images and javascript. Because it loads the whole page,
this tool does a good job of showing more real world results. For each trial,
I pitted the dynamic site and the static site directly against each other and
recorded the average of 100 requests. I did three trials (100 requests each)
for each of the three pages. Below are the averages for each page and the
overall averages.

<table class="table table-bordered table-hover">
		
		<tr>
			<th colspan="3" style="font-size: 18px">
				Which Loads Faster? (all times in ms)
			</th>
		</tr>

		<tr>
	    <th>Page</th>
	    <th>Dynamic</th>
	    <th>Static</th>
	  </tr>

	  <tr>
	    <th>Homepage</th>
	    <td>276.67</td>
	    <td>121.67</td>
	  </tr>

	   <tr>
	    <th>Post w/ 1 Picture</th>
	    <td>262.33</td>
	    <td>119.00</td>
	  </tr>

	  <tr>
	    <th>w/ no Pictures</th>
	    <td>219.67</td>
	    <td>102.33</td>
	  </tr>

	  <tr>
			<th>Avg. of All Pages</th>
			<th>252.89</th>
			<th>114.33</th>
	  </tr>

</table>

{% pullquote %}

{" The results show that the static site is performing 2.21x (or 54.8%) better than the dynamic one. "}
It also shows that the entire page is loading on average in a mere 114 ms on my laptop, which
is insanely fast! Of course, as we'll see in the next benchmark tool, this has a lot to
do with my location and internet speed, and you can't necessarily get the same results
everywhere.

It's also worth noting that the server will only respond this fast if you limit it to one
request at a time. And the results might have been affected by the fact that I performed
these tests in the late hours of the night when Amazon wasn't seeing much
traffic on their U.S. servers.

{% endpullquote %}

### Pingdom Full Page Tester

Unlike the previous tools, this one uses servers in three locations around the
world to and does not depend on your own hardware or internet connection. The three
locations are New York, Dallas, and Amsterdam. It also tests only a single request at a 
time, so the results won't reflect what happens when the server is experiencing heavy load. 
I performed a single page load test five times for each of the three pages (homepage, a post
with one picture, and a post with no pictures). Below is the matrix of averages. On one
axis is the average for each location, and on the other axis is the average for each page.
In the bottom right corner is the overall average for all locations and all pages.

<table class="table table-bordered table-hover">
		
		<tr>
			<th colspan="5" style="font-size: 18px">
				Dynamic Site tested by Pingdom Tools (ms)
			</th>
		</tr>

		<tr>
			<td></td>
	    <th>Homepage</th>
	    <th>Post w/ 1 Picture</th>
	    <th>w/ no Pictures</th>
	    <th>Avg.</th>
	  </tr>

	  <tr>
	    <th>New York</th>
	    <td>806</td>
	    <td>832</td>
	    <td>462</td>
	    <td>735</td>
	  </tr>

	   <tr>
	    <th>Dallas</th>
	    <td>1298</td>
	    <td>950</td>
	    <td>634</td>
	    <td>961</td>
	  </tr>

	  <tr>
	    <th>Amsterdam</th>
	    <td>1192</td>
	    <td>1126</td>
	    <td>1338</td>
	    <td>1219</td>
	  </tr>

	  <tr>
			<th>Avg.</th>
			<td>1134</td>
			<td>969</td>
			<td>811</td>
			<th>972</th>
	  </tr>

</table>

<table class="table table-bordered table-hover">
		
		<tr>
			<th colspan="5" style="font-size: 18px">
				Static Site tested by Pingdom Tools (ms)
			</th>
		</tr>

		<tr>
			<td></td>
	    <th>Homepage</th>
	    <th>Post w/ 1 Picture</th>
	    <th>w/ no Pictures</th>
	    <th>Avg.</th>
	  </tr>

	  <tr>
	    <th>New York</th>
	    <td>806</td>
	    <td>508</td>
	    <td>380</td>
	    <td>565</td>
	  </tr>

	   <tr>
	    <th>Dallas</th>
	    <td>801</td>
	    <td>643</td>
	    <td>439</td>
	    <td>628</td>
	  </tr>

	  <tr>
	    <th>Amsterdam</th>
	    <td>154</td>
	    <td>245</td>
	    <td>201</td>
	    <td>200</td>
	  </tr>

	  <tr>
			<th>Avg.</th>
			<td>587</td>
			<td>465</td>
			<td>340</td>
			<th>464</th>
	  </tr>

</table>

{% pullquote %}
{" Based on the average of all three locations and all three pages,
the static site performed 2.09x (or 52.25%) better than the dynamic one. "}
What might be more interesting, though, is that this tool showed something 
that the others didn't: the static site has ***much better*** global performance.
This is particularly noticeable in Amsterdam, where the average load time
was only 200 ms, 6 times faster than the dynamic site performed at that location.
(Funny, because you might expect everything to run a little lazier there).

The Pingdom full page tester also reports how your website compares to all
other tested websites in their database. While the dynamic site performed around
85-90% better than all other websites, the static one performed upwards of 95%
better. In Amsterdam, my blog performed 98-100% better than all
other tested sites!

{% endpullquote %}

Conclusions
-----------

{% img /images/digital/all-benchmarks-chart.jpg %}

If you combine the load time averages from each of the three benchmark tools,
you'll find that the changes I made **increased my blog performance by around
56.4%**. It is now **2.3x faster**, and it shows. The exact performance depends on 
your internet speed, of course, but in my experience I don't notice any lag as
I navigate between pages. None.

I also learned that **my blog will now perform much better under a heavy load**.
Apache Benchmark showed that at even at 500 requests per second, it can consistently
serve up pages in less than one second. Actual performance might even exceed those
numbers since ab could have been limited by my hardware and internet
speed and it was only hitting one of CloudFront's distribution centers.

The performance benefits are particularly noticeable if you're outside of the States.
With the old site, you might have been waiting 1-2 seconds. The new site should be able
to consistently serve you in under a second no matter where you're located.

Don't forget– if you want to see the
[entire data set from all three benchmark tools](https://docs.google.com/spreadsheet/ccc?key=0AsmDpu3Djd_vdFdzNmhoelRCcjFtZlFWYWpoQUZNRHc),
I have made it publicly viewable. I will also be open-sourcing all the
code behind my blog once I get all the kinks worked out and clean it up
a bit. I will update this post when that happens.

As for the price? Well over the course of testing I probably sent more than
one million requests to the CloudFront servers and transferred around a gigabyte
of data. According to the pricing charts, this will cost me a measly single
dollar. Not bad at all, especially considering that's far more traffic than
I expect to get in a typical month.

If you're running your own blog and have some programming experience, 
I would strongly recommend you give Jekyll/Octopress a try. You will be
pleased with the performance, and writing in markdown with liquid tags
can be quite a pleasure. In no particular order, here's some resources
that I found helpful:

- [Jekyll Repository](https://github.com/mojombo/jekyll)
- [Jekyll Homepage](http://jekyllrb.com/)
- [The Ultimate Guide to Getting Started with Jekyll](http://danielmcgraw.com/2011/04/14/The-Ultimate-Guide-To-Getting-Started-With-Jekyll-Part-1/)
- [Building Static Sites with Jekyll](http://net.tutsplus.com/tutorials/other/building-static-sites-with-jekyll/)
- [Static Websites with Jekyll (a video)](http://mijingo.com/products/screencasts/static-websites-with-jekyll/)
- [Octopress Homepage](http://octopress.org/)
- [Blogging Basics with Octopress](http://octopress.org/docs/blogging/)
- [List of Jekyll Plugins (including one of my own creation)](https://github.com/mojombo/jekyll/wiki/Plugins)

If you have any other tips on how I 
can make my blog even faster, or any suggestions for other benchmarks
I could try, I'd love to hear it!





