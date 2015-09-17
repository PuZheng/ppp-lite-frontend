var gulp = require('gulp');
var webpack = require('webpack');
var webpackConfig = require('./webpack.config.js');
var gutil = require('gulp-util');
var WebpackDevServer = require('webpack-dev-server');
var data = require('gulp-data');
var template = require('gulp-template');
var rename = require('gulp-rename');


gulp.task('webpack:build', function(callback) {
	// modify some webpack config options
    var myConfig = Object.create(webpackConfig);
	myConfig.plugins = myConfig.plugins.concat(
		new webpack.DefinePlugin({
			'process.env': {
				// This has effect on the react lib size
				'NODE_ENV': JSON.stringify('production')
			}
		}),
		new webpack.optimize.DedupePlugin(),
		new webpack.optimize.UglifyJsPlugin()
	);

	// run webpack
	webpack(myConfig, function(err, stats) {
		if(err) throw new gutil.PluginError('webpack:build', err);
		gutil.log('[webpack:build]', stats.toString({
			colors: true
		}));
		callback();
	});
});
gulp.task('webpack:build-dev', function(callback) {
    // modify some webpack config options
    var myDevConfig = Object.create(webpackConfig);
    myDevConfig.devtool = 'source-map';
    myDevConfig.debug = true;

    // create a single instance of the compiler to allow caching
    var devCompiler = webpack(myDevConfig);
	// run webpack
	devCompiler.run(function(err, stats) {
		if(err) throw new gutil.PluginError('webpack:build-dev', err);
		gutil.log('[webpack:build-dev]', stats.toString({
			colors: true
		}));
		callback();
	});
});
gulp.task('webpack-dev-server', function(callback) {
    // Start a webpack-dev-server
    var config = Object.create(require('./webpack.hot.config.js'));

    for (var k in config.entry) {
        config.entry[k].unshift('webpack-dev-server/client?http://127.0.0.1:8080');
    }

    var compiler = webpack(config);

    new WebpackDevServer(compiler, {
        publicPath: config.output.publicPath,
       // server and middleware options
    }).listen(8080, 'localhost', function(err) {
        if(err) throw new gutil.PluginError('webpack-dev-server', err);
        // Server listening
        gutil.log('[webpack-dev-server]', 'http://localhost:8080/webpack-dev-server/index.html');

        // keep the server alive or continue?
        // callback();
    });
});
gulp.task('template-compile', function () {
    var config = require('./convict-def.js');
    gulp.src('js/config.js.tmpl').pipe(data(config.getProperties())).pipe(template()).pipe(rename(function (path) {
        path.extname = '';
    })).pipe(gulp.dest('js/'));
});
gulp.task('watch', function () {
    gulp.watch(['js/config.js.tmpl', 'convict-def.js'], ['template-compile']);
});

gulp.task('default', ['template-compile', 'watch', 'webpack-dev-server']);
