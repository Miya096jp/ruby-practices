# frozen_string_literal: true

require 'etc'

class Entry
  def initialize(path, stat)
    @path = path
    @stat = stat
  end

  def name
    File.basename(@path)
  end

  def type
    format_type(@stat)
  end

  def mode
    format_mode(@stat)
  end

  def setuid?
    @stat.setuid?
  end

  def setgid?
    @stat.setgid?
  end

  def sticky?
    @stat.sticky?
  end

  def nlink
    @stat.nlink
  end

  def username
    Etc.getpwuid(@stat.uid).name
  end

  def groupname
    Etc.getgrgid(@stat.gid).name
  end

  def bytesize
    @stat.size
  end

  def mtime
    @stat.mtime
  end

  def blocks
    @stat.blocks
  end

  def owner
    format_mode(@stat).slice(0)
  end

  def group
    format_mode(@stat).slice(1)
  end

  def others
    format_mode(@stat).slice(2)
  end

  private

  def format_type(stat)
    stat.mode.to_s(8)[..-5]
  end

  def format_mode(stat)
    stat.mode.to_s(8)[-3..]
  end
end
