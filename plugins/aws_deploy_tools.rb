require 'rubygems'
require 'bundler/setup'
require 'openssl'
require 'digest/sha1'
require 'net/https'
require 'base64'
require 'aws-sdk'
require 'digest/md5'
require 'colored'


# A convenient wrapper around aws-sdk
# Also includes the ability to invalidate cloudfront files
# Used for deploying to s3/cloudfront
class AWSDeployTools
	
	def initialize(config = {})

		@access_key_id = config['access_key_id']
		@secret_access_key = config['secret_access_key']

		# for privacy, allow user to store aws credentials in a shell env variable
		@access_key_id ||= ENV['AWS_ACCESS_KEY_ID']
		@secret_access_key ||= ENV['AWS_SECRET_ACCESS_KEY']

		@bucket = config['bucket']
		@acl = config['acl']
		@cf_distribution_id = config['cf_distribution_id']
		@dirty_keys = Set.new # a set of keys that are dirty (have been pushed but not invalidated)

		if @bucket.nil?
    	raise "ERROR: Must provide bucket name in constructor. (e.g. :bucket => 'bucket_name')" 
	  end

	  if @cf_distribution_id.nil?
	    puts "WARNING: cf_distribution_id is nil. (you can include it with :cf_distribution_id => 'id')\n Skipping cf invalidations..."
	  end


		@s3 = AWS::S3.new(config)

	end

	# checks if a local file is in sync with the s3 bucket
	# file can either be a file object or a string with a
	# valid file path
	def synced?(s3_key, file)

		if file.is_a? String
			file = File.open(file, 'r')
		end

		f_content = file.read
		obj_etag = ""

		begin
	    obj = @s3.buckets[@bucket].objects[s3_key]
	    obj_etag = obj.etag # the etag is the md5 of the remote file
	  rescue
	   return false
	  end

		# the etag is surrounded by quotations. chomp removes them
	  obj_etag = obj_etag.gsub('"', '')

		# compare the etag to the md5 hash of the local file
	  obj_etag == md5(f_content)

	end

	# pushes (writes) the file to the s3 bucket at location
	# indicated by s3_key.
	# file can either be a file object or a string with a
	# valid file path
	# options are any options that can be passed to the
	# write method. 
	# See http://docs.aws.amazon.com/AWSRubySDK/latest/frames.html
	def push(s3_key, file, options = {})

		if file.is_a? String
			file = File.open(file, 'r')
		end
		
		puts "--> pushing #{file.path} to #{s3_key}...".green
    obj = @s3.buckets[@bucket].objects[s3_key]
    obj.write(file, options)

    @dirty_keys << s3_key
    # Special cases for index files.
    # for /index.html we should also invalidate /
    # for /archive/index.html we should also invalidate /archive/
    if (s3_key == "index.html")
			@dirty_keys << "/"
    elsif File.basename(s3_key) == "index.html"
			@dirty_keys << s3_key.chomp(s3_key.split("/").last)
    end
	  
	end

	# batch pushes (writes) the files to the s3 bucket at locations
	# indicated by s3_keys. (more than one file at a time)
	# files can either be a file object or a string with a
	# valid file path
	# options are any options that can be passed to the
	# write method.
	# See http://docs.aws.amazon.com/AWSRubySDK/latest/frames.html
	def batch_push(s3_keys = [], files = [], options = {})
		
		if (s3_keys.size != files.size) 
			raise "ERROR: There must be a 1-to-1 correspondence of keys to files!"
		end

		files.each_with_index do |file, i|

			s3_key = s3_keys[i]
			push(s3_key, file, options)
		  
		end
	end

	# for each file, first checks if the file is synced.
	# If not, it pushes (writes) the file.
	# options are any options that can be passed to the
	# write method.
	# See http://docs.aws.amazon.com/AWSRubySDK/latest/frames.html
	def sync(s3_keys = [], files = [], options = {})
		
		if (s3_keys.size != files.size) 
			raise "ERROR: There must be a 1-to-1 correspondence of keys to files!"
		end

		files.each_with_index do |file, i|

			s3_key = s3_keys[i]
	    unless synced?(s3_key, file)
				push(s3_key, file, options)
	    end
		  
		end

	end


	# a convenience method which simply returns the md5 hash of input
	def md5 (input)
	  Digest::MD5.hexdigest(input)
	end

	# invalidates files (accepts an array of keys or a single key)
	# based heavily on https://gist.github.com/601408
	def invalidate(s3_keys)

		if @cf_distribution_id.nil?
	    puts "WARNING: cf_distribution_id is nil. (you can include it with :cf_distribution_id => 'id')\n--> skipping cf invalidations..."
	    return
	  end

		if s3_keys.nil? || s3_keys.empty?
			puts "nothing to invalidate."
			return
		elsif s3_keys.is_a? String
			puts "--> invalidating #{s3_keys}...".yellow
			# special case for root
			if s3_keys == '/'
				paths = '<Path>/</Path>'
			else
				paths = '<Path>/' + s3_keys + '</Path>'
			end
		elsif s3_keys.length > 0
			puts "--> invalidating #{s3_keys.size} file(s)...".yellow
			paths = '<Path>/' + s3_keys.join('</Path><Path>/') + '</Path>'
			# special case for root
			if s3_keys.include?('/')
				paths.sub!('<Path>//</Path>', '<Path>/</Path>')
			end
		end

		# digest calculation based on http://blog.confabulus.com/2011/05/13/cloudfront-invalidation-from-ruby/
		date = Time.now.strftime("%a, %d %b %Y %H:%M:%S %Z")
		digest = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), @secret_access_key, date)).strip

		uri = URI.parse('https://cloudfront.amazonaws.com/2010-08-01/distribution/' + @cf_distribution_id + '/invalidation')

		if paths != nil
		  req = Net::HTTP::Post.new(uri.path)
		else
		  req = Net::HTTP::Get.new(uri.path)
		end

		req.initialize_http_header({
		  'x-amz-date' => date,
		  'Content-Type' => 'text/xml',
		  'Authorization' => "AWS %s:%s" % [@access_key_id, digest]
		})
		 
		if paths != nil
		  req.body = "<InvalidationBatch>" + paths + "<CallerReference>ref_#{Time.now.utc.to_i}</CallerReference></InvalidationBatch>"
		end
		 
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		res = http.request(req)
		
		if res.code == '201'
			puts "Cloudfront Invalidation Success [201]. It may take a few minutes for the new files to propagate.".green
		else
			puts ("Cloudfront Invalidation Error: \n" + res.body).red
		end

		return res.code

	end

	# invalidates all the dirty keys and marks them as clean
	def invalidate_dirty_keys
		if @cf_distribution_id.nil?
	    puts "WARNING: cf_distribution_id is nil. (you can include it with :cf_distribution_id => 'id')\n--> skipping cf invalidations..."
	    return
	  end

		res_code = invalidate(@dirty_keys.to_a)
		# mark the keys as clean iff the invalidation request went through
		@dirty_keys.clear if res_code == '201'
	end


end