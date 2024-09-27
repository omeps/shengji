pushd redis;
redis-server&
popd;
echo "" | gleam run
