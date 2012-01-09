#!/usr/bin/env bash
# bash < <(curl -s # https://raw.github.com/simulacre/simulacre.org/master/setup.sh)

set -e 

git clone git://github.com/simulacre/simulacre.org.git
cd simulacre.org
git config receive.denyCurrentBranch ignore
cat > .git/hooks/post-receive <<-EOR
#!/usr/bin/env bash
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
cd ..
env -i git reset --hard
if [ -f tmp/restart ]; then
  if [ ! -f tmp/last_restart ]; then 
    echo "$PWD/tmp/last_restart not found; restarting service"
    bundle install && ./stop && sleep 2 && ./start && touch tmp/last_restart
  else
    if [ $(stat -c %Y tmp/restart) > $(stat -c %Y tmp/last_restart) ]; then
      echo "$PWD/tmp/restart has been updated; restarting service"
      bundle install && ./stop && sleep 2 && ./start && touch tmp/last_restart
    fi
  fi
fi
# @todo restart if config.ru or sinatra/app.rb have been updated
# ln -f -s /var/www/simulacre.org/html/ee ../_site/ee
[[ -e tmp/pids/thin.pid ]] || (./start && sleep 5)
curl http://localhost:4242/reindex/`cat ~/.ssh/id_rsa.pub  | awk '{print $2}' | ruby -r uri -ne 'print URI.escape($_.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))'`/
echo -e "\ndone"
EOR
chmod ug+x .git/hooks/post-receive
