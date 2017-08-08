require 'json'

def array_of_hash?(list)
  return false unless !list.empty? && list.class == Array
  list.each do |e|
    return false unless e.class == Hash
  end
  true
end

module Puppet::Parser::Functions
 newfunction(:to_array_of_json_strings, :arity =>1, :type => :rvalue, :doc => "Convert
  input array of hashes (can be an array of json encoded objets) to an Array of json encoded objects") do |arg|
    list = arg[0]
    if list.class == String
      begin
        list = JSON.load(arg[0].gsub("'","\""))
      rescue JSON::ParserError
        raise Puppet::ParseError, "Syntax error: #{arg[0]} is not valid"
      end
    end
    unless array_of_hash?(list)
      raise Puppet::ParseError, "Syntax error: #{arg[0]} is not an Array or JSON encoded String"
    end
    rv = []
    list.each do |e|
      rv.push(e.to_json)
    end
    return rv
  end
end
