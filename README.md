[![Travis build status](https://travis-ci.org/nicosmaris/vm.png?branch=master)](https://travis-ci.org/nicosmaris/vm)

1. Creates VM at digitalocean
2. Synchronizes blockchain of the coin

#### Requirements

1. Create account at digitalocean and add a bank account
2. Install ruby locally at your ubuntu 16.04:

  1. gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  2. \curl -sSL https://get.rvm.io | bash -s stable --ruby
  3. echo 'source /usr/share/rvm/scripts/rvm' >> ~/.bashrc
  4. open another terminal and run 'gem install bundler' and 'bundle install'

#### TODO: at create VM call

- [ ] ssh key
- [ ] boot script
- [ ] volume

#### TODO: after create VM call

- [ ] wait until ssh port is listening
