$:.unshift File.dirname(__FILE__)
require 'github/command'
require 'github/helper'

##
# Starting simple.
#
# $ github <command> <args>
#
#   GitHub.register <command> do |*args|
#     whatever 
#   end
#
# We'll probably want to use the `choice` gem for concise, tasty DSL
# arg parsing action.
#

module GitHub
  extend self

  def register(command, &block)
    debug "Registered `#{command}`"
    commands[command.to_s] = Command.new(block)
  end

  def describe(hash)
    descriptions.update hash
  end

  def helper(command, &block)
    debug "Helper'd `#{command}`"
    Helper.send :define_method, command, &block
  end

  def activate(args)
    @debug = args.delete('--debug')
    load 'commands.rb'
    invoke(args.shift, *args)
  end

  def invoke(command, *args)
    block = commands[command] || commands['default']
    debug "Invoking `#{command}`"
    block.call(*args)
  end

  def commands
    @commands ||= {}
  end

  def descriptions
    @descriptions ||= {}
  end

  def debug(*messages)
    puts *messages.map { |m| "== #{m}" } if debug?
  end

  def debug?
    !!@debug
  end
end

GitHub.register :default do
  puts "Usage: github command <space separated arguments>", ''
  puts "Available commands:", ''
  GitHub.descriptions.each do |command, desc|
    puts "  #{command} => #{desc}"
  end
  puts
end

GitHub.activate ARGV
