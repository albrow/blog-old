# A set of tools for minifying and compressing content
# 
# Currently supports:
# 		- miniifying js, css, and html
# 		- gzipping any content
#     - compressing and shrinking images
#
# Currently depends on 3 system command line tools:
#			- ImageMagick (http://www.imagemagick.org/script/index.php)
# 		- gzip        (http://www.gzip.org/)
#     - jitify      (http://www.jitify.com/)
#
# These may be swapped out for gem versions in the future,
# but for now you have to manually install command line tools
# above on your system if you don't already have them.
#
# Author: Alex Browne

class RedDragonfly

	def initialize
		# ~~ gzip ~~
		$gzip_options = {
			:output_ext => "gz"
		}

		# ~~ minify (jitify) ~~
		# $minify_options = {
		#
		# }
		

		# ~~ images (ImageMagick) ~~
		# exts          : files extensions which sould be minified during batch operations
		# output_ext    : file extension of the output file ("" means keep the same extension)
		# max_width     : max width for compressed images
		# max_height    : max height for compressed images
		# quality       : image compression quality (1-100, higher is better quality/bigger files)
		# compress_type : type of compression to be used (http://www.imagemagick.org/script/command-line-options.php#compress)
		$img_options = {
			:output_ext => "jpg",
			:max_width => "600",
			:max_height => "1200",
			:quality => "65",
			:compress_type => "JPEG"
		}
	end

	# accepts a single file or an array of files
	# accepts a file object or the path to a file (a string)
	# perserves the original file
	# the output is (e.g.) .html.gz
	def gzip (files = [])

		unless which('gzip')
			puts "WARNING: gzip is not installed on your system. Skipping gzip..."
			return
		end

		unless files.is_a? Array
			files = [files]
		end

		files.each do |file|

			fname = get_filename(file)

		  # invoke system gzip
		  system("gzip -cn9 #{fname} > #{fname + '.' + $gzip_options[:output_ext]}")
		end

	end

	# accepts a single file or an array of files
	# accepts a file object or the path to a file
	# overwrites the original file with the minified version
	# html, css, and js supported only
	def minify (files = [])

		unless which('jitify')
			puts "WARNING: jitify is not installed on your system. Skipping minification..."
			return
		end

		unless files.is_a? Array
			files = [files]
		end

		files.each do |file|

			fname = get_filename(file)

		  # invoke system jitify
		  system("jitify --minify #{fname} > #{fname + '.min'}")
		  # remove the .min extension
		  system("mv #{fname + '.min'} #{fname}")

		end

	end

	# compresses an image file using the options
	# specified at the top
	# accepts either a single file or an array of files
	# accepts either a file object or a path to a file
	def compress_img (files = [])
		
		unless which('convert')
			puts "WARNING: ImageMagick is not installed on your system. Skipping image compression..."
			return
		end
		
		unless files.is_a? Array
			files = [files]
		end

		files.each do |file|

			fname = get_filename(file)

			compress_cmd = 
								"convert -strip " + 
								# uncomment to enable gaussian blur (smaller files but blurry)
								#"-gaussian-blur 0.01 " +
								# uncomment to enable interlacing (progressive compression for jpeg)
								#"-interlace Plane " +
								"#{fname} -resize #{$img_options[:max_width]}x#{$img_options[:max_height]}\\> " + 
		  					"-compress #{$img_options[:compress_type]} -quality #{$img_options[:quality]} " + 
		  					"#{get_raw_filename(fname) + '.' + $img_options[:output_ext]}"
			
		  # invoke system ImageMagick
		  system(compress_cmd)
		  # remove the old file (if applicable)
		  if (get_ext(fname) != ("." + $img_options[:output_ext]))
		  	system("rm #{fname}")
		  end

		end

	end

	# returns the filename (including path and ext) if the input is a file
	# if the input is a string, returns the same string
	def get_filename (file)
		if file.is_a? File
			file = file.path
		end
		return file
	end

	# returns the extension of a file
	# accepts either a file object or a string path
	def get_ext (file)

		if file.is_a? String
			return File.extname(file)
		elsif file.is_a? File
			return File.extname(file.path)
		end

	end

	# returns the raw filename (minus extension) of a file
	# accepts either a file object or a string path
	def get_raw_filename (file)
	
		# convert to string
		file = get_filename(file)
		# remove extension
		file.sub(get_ext(file), "")
		
	end

	##
	# invoke system which to check if a command is supported
	# from http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
	# which('ruby') #=> /usr/bin/ruby
	def which(cmd)
	  system("which #{ cmd} > /dev/null 2>&1")
	end

end









