#!/usr/bin/env bash
# bash < <(curl -s # https://raw.github.com/simulacre/simulacre.org/master/setup.sh)

set -e 

git clone git://github.com/simulacre/simulacre.org.git
cd simulacre.org
git config receive.denyCurrentBranch ignore
cat > .git/hooks/post-receive <<EOR
#!/usr/bin/env bash
cd ..
git reset --hard
curl http://localhost:4242/reindex/`cat ~/.ssh/id_rsa.pub  | awk '{print $2}' | ruby -r uri -ne 'print URI.escape($_.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))'`/
echo -e "\ndone"
EOR
chmod ug+x .git/hooks/post-receive
