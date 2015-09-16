var webpack = require('webpack');
var path = require('path');
var CommonsChunkPlugin = require("webpack/lib/optimize/CommonsChunkPlugin");

var resolvePath = function(componentPath) {
    return path.join(__dirname + '/' + componentPath);
};

module.exports = {
    entry: {
        'gas_station.list': ['./static/js/gas_station/list/app.js'],
        'gas_station.object': ['./static/js/gas_station/object/app.js'],
        'advertisement.object': ['./static/js/advertisement/object/app.js'],
        'plant.object': ['./static/js/plant/object/app.js'],
        'dashboard': ['./static/js/dashboard/app.js'],
        'comment.list': ['./static/js/comment/list/app.js'],
        'data_source.list': ['./static/js/data_source/list/app.js'],
        'data_source.object': ['./static/js/data_source/object/app.js'],
        'feature.list': ['./static/js/feature/list/app.js'],
        'feature.object': ['./static/js/feature/object/app.js'],
        'gas_station_report.list': ['./static/js/gas_station_report/list/app.js'],
        'gas-station-canonize': ['./static/js/utilities/gas-station-canonize/app.js'],
        'profane-word': ['./static/js/profane-word.js'],
    },
    output: {
        path: __dirname + '/static/js/bundle/',
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
