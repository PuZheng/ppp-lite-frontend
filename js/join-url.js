var replace = new RegExp('/{1,}', 'g');

function joinURL(){
    var args = Array.prototype.slice.call(arguments);
    var schema = '';

    if (args[0].startsWith('http://')) {
        args[0] = args[0].replace("http://", '');
        schema = "http://";
    }
    return schema + args.join('/').replace(replace, '/');
}

module.exports = joinURL;

