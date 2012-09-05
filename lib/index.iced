fs = require "fs"
path = require "path"
colors = require "colors"
xml2js = new (require "xml2js").Parser()

module.exports = ( options, cb ) ->

	throw "filename is required" if not options?.filename?
	throw "ouput (folder) is required" if not options?.output?

	await fs.stat options.output, defer err, output
	throw "invalid output folder" if err

	await xml2js.parseString fs.readFileSync(options.filename, 'utf8'), defer err, input
	throw "unable to parse file" if err
	options.replace = options?.replace or []

	blog  = input?.channel?.link
	posts = input?.channel?.item

	if not posts
		throw "there are no posts in this input file"

	console.log "about to import #{posts.length} posts into #{options.output} folder"
	
	for post in posts
		#get the target folder
		name = post["wp:post_name"]
		postDir = path.join options.output, name

		console.log "exporting #{name}"
		
		#post folder
		try
			fs.statSync postDir
		catch err
			if err.errno is 34 #dir not found.
				fs.mkdirSync postDir
			else
				console.log "unable to export post #{name} to #{postDir}".red
				console.log JSON.stringify(err).red
				continue

		#import html file.
		htmlFile = path.join postDir, 'index.html'
		try
			fs.stat htmlFile
		catch err
			if err.errno isnt 34
				console.log "removing html file for #{name}"
				fs.unlinkSync htmlFile
			else
				console.log "unable to get html file info for #{name}"
				continue

		data = post["content:encoded"]
		
		#curate content from non-html tags.
		data = data?.replace /\[caption.*?\]/g, ""
		data = data?.replace /\[\/caption\]/g, ""
		#curate from old urls
		for replace in options.replace
			data = data?.replace replace.value, replace.with

		console.log "saving #{name} to #{htmlFile} size: #{data.length}"
		fs.writeFileSync htmlFile, data, 'utf8'
		console.log "#{name} html file imported".green

		#import meta file.
		###
		{
			"layout": false,
			"title": "Goodbye Wordpress, Hello Jekyll!",
			"date": "Mon, 23 Jul 2012 17:39:46 GMT",
			"tags": ["test", "tost"],
			"author": {
				"name": "Gustavo",
				"url": "http://machadogj.com"
			}
		}
		###
		metaFile = path.join postDir, 'meta.json'
		tags = (tag["#"].toLowerCase() for tag in post.category when tag["#"]?)
		meta = 
			title : post.title
			date : post.pubDate
			author : 
				name : post["dc:creator"]
			tags : tags

		fs.writeFileSync metaFile, JSON.stringify(meta, 0, 2), 'utf8'
		console.log "saved meta file for #{name}".green
	cb?()