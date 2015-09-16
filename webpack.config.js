var webpack = require('webpack');
var path = require('path');
var CommonsChunkPlugin = require("webpack/lib/optimize/CommonsChunkPlugin");

var resolvePath = function(componentPath) {
    return path.join(__dirname + '/' + componentPath);
};

module.exports = {
    entry: {
        'main': ['./js/main.js'],
    },
    output: {
        path: __dirname + '/js/bundle/',
        filename: "[name].js",
    },
    resolve: {
        alias: {
            'jquery$': resolvePath('static/bower_components/jquery/dist/jquery.js'),
            'semantic-ui$': resolvePath('static/bower_components/semantic-ui/dist/semantic.min.js'),
            'styles': resolvePath('static/css'),
            'toastr': resolvePath('static/bower_components/toastr'),
            'sweetalert': resolvePath('static/bower_components/sweetalert/lib'),
            'underscore': resolvePath('static/bower_components/underscore/underscore-min.js'),
            'underscore.string': resolvePath('static/bower_components/underscore.string/dist/underscore.string.min.js'),
            'moment': resolvePath('static/bower_components/moment/min/moment.min.js'),
        },
        root: '.',
    },
    plugins: [
        new webpack.ProvidePlugin({
           $: "jquery",
           _: "underscore",
           jQuery: "jquery",
           'window.jQuery': 'jquery',
        }),
        new CommonsChunkPlugin("commons.chunk.js"),
    ],
    module: {
        preLoaders: [
            { test: /\.tag$/, exclude: /node_modules/, loader: 'riotjs-loader', query: { type: 'none' } }
        ],
        loaders: [
            { test: /\.css$/, loader: "style!css" },
            { test: /\.(png|gif)$/, loader: "url-loader?limit=100000" },
        ]
    },
};
