module.exports = function (shipit) {
  shipit.initConfig({
    staging: {
      servers: [
        {
          host: '104.207.130.164',
          user: 'root'
        }
      ]
    }
  });

  shipit.task('pwd', function () {
    return shipit.remote('pwd');
  });
};
