
## Deployment

- Setup the repo on the server

      bash < <(curl -s https://raw.github.com/simulacre/simulacre.org/master/setup.sh)

- Create mail.yml

- Configure Apache 

- Start the Backend
      touch /etc/production
      gem install bundler
      bundle install
      ./config.ru & 
      disown
