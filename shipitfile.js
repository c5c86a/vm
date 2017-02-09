module.exports = function (shipit) {
  shipit.initConfig({
    default: {
      deployTo: '/tmp/deploy_to',
      key: '/home/travis/build/nicosmaris/vm/key'
    },
    staging: {
      servers: [
        {
          host: '108.61.171.67',
          user: 'root'
        }
      ]
    }
  });

  shipit.task('pwd', function () {
    return shipit.remote('pwd');
  });
};
