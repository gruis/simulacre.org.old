#!/usr/bin/env bash
# bash < <(curl -s # https://raw.github.com/simulacre/simulacre.org/master/setup.sh)

set -e 

git clone git://github.com/simulacre/simulacre.org.git
cd simulacre.org
git config receive.denyCurrentBranch ignore
cat > .git/hooks/post-receive << "EOR"
#!/usr/bin/env bash
function build_and_run {
    [[ -z "$1" ]] || echo -e $1
    gtd=$GIT_DIR
    unset GIT_DIR
    bundle install --path .bundle/gems
    ./backend restart && touch tmp/last_restart
    GIT_DIR=$gtd
}

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
cd ..
env -i git reset --hard
if [ -f tmp/restart ]; then
  if [ ! -f tmp/last_restart ]; then
    build_and_run "$PWD/tmp/last_restart not found; restarting service"
  else
    if test tmp/restart -nt tmp/last_restart; then
      build_and_run "$PWD/tmp/restart has been updated; restarting service"
    fi
  fi
else
  [[ -e sinatra/log/backend_monitor.pid ]] || ./backend start
fi

echo -e "\ndone"
EOR
chmod ug+x .git/hooks/post-receive
mkdir _site
ln -s /var/www/simulacre.org/html/ee _site/ee
