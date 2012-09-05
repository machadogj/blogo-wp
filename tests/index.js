var blogoWp = require('../'),
	file = 'gustavomachado.wordpress.2012-08-23.xml',
	path = require('path'),
	assert = require('assert');

describe('import', function () {

	it('should require the filename', function ()  {
		try
		{
			blogoWp({});
		}
		catch(err) {
			assert.ok(true);
			return;
		}
		assert.ok(false);
	});

	it('should import meta files', function ( done ) {
		var posts = blogoWp({
			filename: path.join(__dirname, file),
			output: path.join(__dirname, 'output'), //../../blogo/articles/'),
			replace:[
				{value: /http:\/\/machadogj.com\/wp-content\/uploads/g, "with":"http://cdn.machadogj.com/uploads"},
				{value: /http:\/\/thegsharp.wordpress.com/g, "with":"" },
				{value: /display: inline?/g, "with":"" },
				{value: /\<pre.*?\>/g, "with":"<pre><code>"},
				{value: /\<\/pre\>/g, "with":"</code></pre>"}
			]
		}, function ( ) {
			done();
		});
	});


});