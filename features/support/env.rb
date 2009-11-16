require 'spec/expectations'
require 'net/http'
require File.expand_path(File.dirname(__FILE__)) + '/../../riak/client_lib/jiak'

RIAK_PATH = File.expand_path(File.dirname(__FILE__)) + '/../../riak'
TMP_PATH = File.expand_path(File.dirname(__FILE__)) + '/../../tmp'
COOKIE = 'test_cookie'

def stop_node(nodename)
  name = "#{nodename}@127.0.0.1"
  config = consult_file(TMP_PATH + '/' + nodename + '/config.erlenv')
  port = config['riak_web_port']
  dest = "http://localhost:#{port}/jiak"
  uri = URI.parse(dest)
  begin
    while true
      %x{erl -noshell \
      -name node_stop@127.0.0.1 \
      -setcookie #{COOKIE} \
      -eval "net_adm:ping('#{name}'), rpc:cast('#{name}', init, stop, [])" \
      -run init stop}
      response = Net::HTTP.get_response(uri)
      sleep(0.25)
    end
  rescue Errno::ECONNREFUSED
  end
end

def consult_file(filename)
  values =  %x{erl -noshell -eval "error_logger:tty(false), {ok, Options}=file:consult(\\\"#{filename}\\\"), [case Value of V when is_number(V) -> io:format(\\\"\'~s\'=>~p,\\\",[Key, V]); V -> io:format(\\\"\'~s\'=>\'~s\',\\\",[Key, V]) end || {Key, Value} <- Options]" -run init stop}
  return eval("{#{values}}")
end

def random_string
  Array.new(20) { rand(256) }.pack('C*').unpack('H*').first
end

After do
  Dir.entries(TMP_PATH).each do |path|
    next if path == '.' or path == '..'
    stop_node(path)
  end
  FileUtils.rm_r(TMP_PATH)
end