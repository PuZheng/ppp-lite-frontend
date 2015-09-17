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
            'riotjs$': resolvePath('node_modules/riot/riot.min.js'),
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
