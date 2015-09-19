var q = require('q');

module.exports = function (shipit) {
    shipit.initConfig({
        default: {
            workspace: '/tmp/github-monitor',
            deployTo: '/home/xiechao/ppp-lite-frontend',
            repositoryUrl: 'git@github.com:PuZheng/ppp-lite-frontend.git',
            ignores: ['.git', 'node_modules'],
            keepReleases: 2,
            deleteOnRollback: false,
            shallowClone: true,
            branch: 'master',
        },
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
