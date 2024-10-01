test -f secrets/certificate.crt || echo "please generate a certificate and put it in secrets/certificate.crt"
test -f secrets/key.key || echo "please generate a certificate and put its key in secrets/key.key"
test -f redis/redis.conf || touch redis/redis.conf
test -f secrets/certificate.crt && test -f secrets/key.key > /dev/null && pushd redis && (redis-server redis.conf&) && popd && gleam run 2> err.log

