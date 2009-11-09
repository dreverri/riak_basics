RIAK_PATH = File.dirname(__FILE__) + '/riak'
CLUSTER_NAME = "my_cluster"
RING_SIZE = 64 # Good for a six node cluster, I think
COOKIE = "riak_demo_cookie"

namespace :riak do
  desc "Clone Riak from bitbucket"
  task :clone do
    if File.directory? "riak"
      abort "The directory 'riak' already exists, try riak:update"
    end
    
    sh "hg clone http://hg.basho.com/riak/"
  end

  desc "Update Riak"
  task :update do
    unless File.directory? "riak"
      abort "Please run riak:clone before running riak:update"
    end
    
    sh "cd riak && hg pull && hg update"
  end
  
  desc "Compile Riak"
  task :compile do
    unless File.directory? "riak"
      abort "Please run riak:clone before running riak:compile"
    end
    
    sh "cd riak && make"
  end
  
  desc "Setup a new node"
  task :new, :name, :port do |t, args|
    unless args[:port] and args[:port] and /^(.+)@(.+)$/.match(args[:name])
      abort <<-eos
Command requires a name and port.
  name - should be formatted as node@host
  port - should be unique per node per host; you can't have two nodes running on the same port on the same machine

Usage:
  rake riak:new[node1@127.0.0.1,8098]

eos
    end
    
    if File.directory? "nodes/#{args[:name]}"
      abort "Looks like a node is already setup at 'nodes/#{args[:name]}'"
    end
    
    FileUtils.mkdir_p "nodes/#{args[:name]}"
    write_config(args[:name], args[:port])
  end
  
  desc "Start node"
  task :start, :name do |t, args|
    path = "nodes/#{args[:name]}"
    unless File.directory? path
      abort "Could not find a node definition for #{args[:name]}, try rake riak:new[#{args[:name]},8098]"
    end
    
    cmd = gen_cmd(args[:name], "-detached")
    sh cmd
  end
  
  desc "Debug node"
  task :debug, :name do |t, args|
    path = "nodes/#{args[:name]}"
    unless File.directory? path
      abort "Could not find a node definition for #{args[:name]}, try rake riak:new[#{args[:name]},8098]"
    end
    
    cmd = gen_cmd(args[:name])
    sh cmd
  end
  
  desc "Stop node"
  task :stop, :name do |t, args|
    unless args[:name]
      abort "Please provide a name: rake riak:stop[node1@127.0.0.1]"
    end
    
    name, node, host = /^(.+)@(.+)$/.match(args[:name]).to_a
    cmd = "erl -noshell -name #{node}_stop@#{host} -setcookie #{COOKIE} -eval \"net_adm:ping('#{name}'), rpc:cast('#{name}', init, stop, [])\" -run init stop"
    sh cmd
  end
  
  desc "Join node1 to node2"
  task :join, :node1, :node2 do |t, args|
    unless args[:node1] and args[:node2]
      abort "Please provide two nodes; both nodes should be running"
    end
    
    name1, node1, host1 = /^(.+)@(.+)$/.match(args[:node1]).to_a
    name2, node2, host2 = /^(.+)@(.+)$/.match(args[:node2]).to_a
    cmd = "erl -noshell -name #{node1}_join@#{host1} -setcookie #{COOKIE} -eval \"net_adm:ping('#{name1}'), rpc:cast('#{name1}', riak_startup, join_cluster, ['#{name2}'])\" -run init stop"
    sh cmd
  end
  
  desc "Rejoin node (restore ringstate if it exists)"
  task :rejoin, :node do |t, args|
    unless args[:node]
      abort "Please provide a node"
    end
    
    name, node, host = /^(.+)@(.+)$/.match(args[:node]).to_a
    cmd = "erl -noshell -name #{node}_rejoin@#{host} -setcookie #{COOKIE} -eval \"net_adm:ping('#{name}'), rpc:cast('#{name}', riak_startup, rejoin, [])\" -run init stop"
    sh cmd
  end
end

def write_config(name, port)
  path = "nodes/#{name}"
  file = "#{path}/config.erlenv"
  _, node, host = /^(.+)@(.+)$/.match(name).to_a
  config = <<eos
{cluster_name, "#{CLUSTER_NAME}"}.
{ring_state_dir, "priv/ringstate"}.
{ring_creation_size, #{RING_SIZE}}.
{gossip_interval, 60000}.
{storage_backend, riak_ets_backend}.
{riak_cookie, #{COOKIE}}.
{riak_nodename, #{node}}.
{riak_hostname, "#{host}"}.
{riak_web_ip, "127.0.0.1"}.
{riak_web_port, #{port}}.
{jiak_name, "jiak"}.
eos
  File.open(file, 'w') { |f| f.write(config) }
end

def gen_cmd(name, flags="")
  path = "nodes/#{name}"
  cmd = "cd #{path} && erl -connect_all false -pa #{RIAK_PATH}/deps/*/ebin -pa #{RIAK_PATH}/ebin -name #{name} -setcookie #{COOKIE} -run riak start config.erlenv #{flags}"
end