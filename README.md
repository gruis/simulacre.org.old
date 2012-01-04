
## Deployment

- Setup the repo on the server

      bash < <(curl -s https://raw.github.com/simulacre/simulacre.org/master/setup.sh)

- Create mail.yml

- Configure Apache 

      a2enmod proxy
      a2enmod proxy_http
      /etc/init.d/apache2 restart

- Keep backwards Compatibility
      
      ln -s /var/www/simulacre.org/ee _site/ee
      ln -s /var/www/simulacre.org/wordpress _site/wordpress

- Start the Backend

      touch /etc/production
      gem install bundler
      bundle install
      ./config.ru & 
      disown
