# frozen_string_literal: true

require 'optparse'

class Options
  def initialize(arguments)
    opts = OptionParser.new
    opts.on('-l') { |v| @long_format = v }
    opts.on('-r') { |v| @reverse = v }
    opts.on('-a') { |v| @dot_match = v }
    opts.parse!(arguments)
  end

  def long_format?
    @long_format
  end

  def reverse?
    @reverse
  end

  def dot_match?
    @dot_match
  end
end