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
            'page$': resolvePath('node_modules/page/page.js'),
            'riotjs$': resolvePath('node_modules/riot/riot.js'),
            'semantic-ui': resolvePath('semantic/dist'),
            'riot-bus': resolvePath('js/riot-bus.js'),
            'config': resolvePath('js/config.js'),
            'pagination': resolvePath('js/pagination.js'),
            'wurl': resolvePath('node_modules/wurl/wurl.js'),
            'moment': resolvePath('node_modules/moment/moment.js'),
            'sweetalert': resolvePath('node_modules/sweetalert/dist/'),
            'toastr': resolvePath('node_modules/toastr/build/'),
            'lodash': resolvePath('node_modules/lodash/index.js'),
            'MotionCAPTCHA': resolvePath('vendors/MotionCAPTCHA/'),
            'perfect-scrollbar': resolvePath('node_modules/perfect-scrollbar/'),
            'nprogress': resolvePath('node_modules/nprogress'),
            'join-url': resolvePath('js/join-url.js'),
            'superagent': resolvePath('node_modules/superagent/lib/client.js'),
            'superagent-no-cache': resolvePath('node_modules/superagent-no-cache'),
            'request': resolvePath('js/request.js'),
            'make-blur-when-press': resolvePath('js/make-blur-when-press.js'),
        },
        root: '.',
    },
    plugins: [
        new webpack.ProvidePlugin({
           $: "jquery",
           _: "lodash",
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
            { test: /\.json/, loader: "json-loader" },
            { test: /\.(png|gif|jpg)$/, loader: "url-loader?limit=100000" },
            //{ test: /\.(ttf|eot|woff|woff2|svg)$/, loader: "file-loader" },
            { test: /\.(ttf|eot|woff|woff2|svg)$/, loader: "url-loader?limit=100000" },
        ]
    },
};
