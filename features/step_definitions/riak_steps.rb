Given /^I setup and start "([^\"]*)" on port "([^\"]*)"$/ do |nodename, port|
  path = "#{TMP_PATH}/#{nodename}"
  FileUtils.mkdir_p path
  file = "#{path}/config.erlenv"
  config = <<eos
{cluster_name, "test_cluster"}.
{ring_state_dir, "priv/ringstate"}.
{ring_creation_size, 64}.
{gossip_interval, 60000}.
{storage_backend, riak_ets_backend}.
{riak_cookie, #{COOKIE}}.
{riak_nodename, #{nodename}}.
{riak_hostname, "127.0.0.1"}.
{riak_web_ip, "127.0.0.1"}.
{riak_web_port, #{port}}.
{jiak_name, "jiak"}.
eos
  File.open(file, 'w') { |f| f.write(config) }
  
  name = "#{nodename}@127.0.0.1"
  cmd = "cd #{path} && \
  erl -connect_all false \
  +K true \
  -env ERL_MAX_PORTS 4096 \
  -pa #{RIAK_PATH}/deps/*/ebin \
  -pa #{RIAK_PATH}/ebin \
  -name #{name} \
  -setcookie #{COOKIE} \
  -run riak start config.erlenv \
  -detached"
  fork { exec cmd }
  dest = "http://localhost:#{port}/jiak"
  begin
    uri = URI.parse(dest)
    response = Net::HTTP.get_response(uri)
  rescue Errno::ECONNREFUSED
    sleep 0.25
    retry
  end
end

Then /^I should be able to connect to "([^\"]*)"$/ do |dest|
  uri = URI.parse(dest)
  Net::HTTP.get_response(uri)
end

Given /^I stop the node "([^\"]*)"$/ do |nodename|
  stop_node(nodename)
end

Then /^I join "([^\"]*)" to "([^\"]*)"$/ do |node1, node2|
  join_node = random_string()
  name1 = "#{node1}@127.0.0.1"
  name2 = "#{node2}@127.0.0.1"
  %x{erl -noshell \
  -name #{join_node}@127.0.0.1 \
  -setcookie #{COOKIE} \
  -eval "net_adm:ping('#{name1}'), rpc:cast('#{name1}', riak_startup, join_cluster, ['#{name2}'])" \
  -run init stop}
end

Given /^I set bucket schema "([^\"]*)" to '([^\']*)' on "([^\"]*)"$/ do |bucket, schema, jiak|
  uri = URI.parse(jiak)
  jc = JiakClient.new(uri.host, uri.port)
  jc.set_bucket_schema(bucket, JSON.parse(schema))
end

Then /^I put '([^\']*)' in "([^\"]*)"$/ do |object, jiak|
  uri = URI.parse(jiak)
  jc = JiakClient.new(uri.host, uri.port)
  jc.store(JSON.parse(object), '3', '3', '3')
end

Then /^I get the key "([^\"]*)" from the bucket "([^\"]*)" on "([^\"]*)"$/ do |key, bucket, jiak|
  uri = URI.parse(jiak)
  jc = JiakClient.new(uri.host, uri.port)
  jc.fetch(bucket, key)
end

Then /^I wait "([^\"]*)" seconds$/ do |seconds|
  sleep(seconds.to_f)
end