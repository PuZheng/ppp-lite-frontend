var convict = require('convict');

// Define a schema
var conf = convict({
    env: {
        doc: "The applicaton environment.",
        format: ["production", "development", "staging"],
        default: "development",
        env: "NODE_ENV"
    },
    backend: {
        doc: "backend url",
        format: "url",
        default: "http://127.0.0.1:8081",
        env: "BACKEND"
    },
    assetsBackend: {
        doc: "assets backend url",
        format: "url",
        default: "http://127.0.0.1:8081",
        env: "ASSETS_BACKEND"
    },
    uploadTo: {
        doc: 'url uploads to',
        format: 'url',
        default: 'http://127.0.0.1:8081/assets',
        env: 'UPLOAD_TO'
    }
});

// Load environment dependent configuration
var env = conf.get('env');
env != 'development' && conf.loadFile('./config/' + env + '.json');

// Perform validation
conf.validate({strict: true});

module.exports = conf;
