var config = require('./webpack.config.js');
var webpack = require('webpack');

for (var k in config.entry) {
    config.entry[k].unshift('webpack/hot/dev-server');
}

config.output.publicPath = 'http://127.0.0.1:8080/static/js/bundle';
config.devtool = "source-map";
config.debug = true;
config.plugins = config.plugins || [];

config.plugins.push(new webpack.HotModuleReplacementPlugin());
config.devServer = {
    hot: true,
};
module.exports = config; 
