module.exports = function (shipit) {
    shipit.initConfig({
        staging: {
            servers: {
                host: '115.29.232.202',
                user: 'xiechao'
            }
        }
    });

    shipit.task('quick-ship', function () {
        var targetPath = '/home/xiechao/work/ppp-lite-frontend';
        shipit.remote([
            'cd ' + targetPath,
            'git pull origin master',
            'cnpm install',
            'NODE_ENV=staging gulp template-compile',
            'gulp webpack:build-dev',
            '(nohup http-server -p 8080 &)'
        ].join(' && '));
    });
};
