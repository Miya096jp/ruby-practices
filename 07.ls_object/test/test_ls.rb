# frozen_string_literal: true

require 'minitest/autorun'
require 'pathname'
require_relative '../ls'
require_relative '../lib/options'

class TestLs < Minitest::Test
  def setup
    @fixture_path = Pathname('test/fixtures/test_ls')
  end

  def test_ls_run
    expected = <<~TEXT
      dir_1        file_3.txt   sticky_bit_B
      dir_2        file_4.txt   suid_A
      dir_3        sgid_A       suid_B
      file_1.txt   sgid_B
      file_2.txt   sticky_bit_A
    TEXT

    @options = Options.new([])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end

  def test_run_with_reverse
    expected = <<~TEXT
      suid_B       sgid_A       dir_3
      suid_A       file_4.txt   dir_2
      sticky_bit_B file_3.txt   dir_1
      sticky_bit_A file_2.txt
      sgid_B       file_1.txt
    TEXT

    @options = Options.new(['-r'])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end

  def test_run_with_dot_match
    expected = <<~TEXT
      .              file_1.txt     sticky_bit_A
      .secret_file_1 file_2.txt     sticky_bit_B
      .secret_file_2 file_3.txt     suid_A
      dir_1          file_4.txt     suid_B
      dir_2          sgid_A
      dir_3          sgid_B
    TEXT

    @options = Options.new(['-a'])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end

  def test_run_with_long_option
    expected = <<~TEXT
      total: 40
      drwxr-xr-x 2 miya staff   64 12 19 14: 9 dir_1
      drwxr-xr-x 2 miya staff   64 12 19 14: 9 dir_2
      drwxr-xr-x 2 miya staff   64 12 19 14: 9 dir_3
      -rw-r--r-- 1 miya staff 2135 12 19 20:50 file_1.txt
      -rw-r--r-- 1 miya staff 1044 12 19 20:51 file_2.txt
      -rw-r--r-- 1 miya staff 2332 12 19 20:49 file_3.txt
      -rw-r--r-- 1 miya staff 4439 12 19 20:50 file_4.txt
      -rwsrwsrws 1 miya staff    0 12 19 14: 4 sgid_A
      -rwsrwSrws 1 miya staff    0 12 19 14: 4 sgid_B
      drwtrwtrwt 2 miya staff   64 12 19 14: 5 sticky_bit_A
      drwtrwtrwT 2 miya staff   64 12 19 14: 5 sticky_bit_B
      -rwSrwsrws 1 miya staff    0 12 19 14: 5 suid_A
      -rw-r--r-- 1 miya staff    0 12 19 14: 5 suid_B
    TEXT

    @options = Options.new(['-l'])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end

  def test_run_with_all_options
    expected = <<~TEXT
      total: 40
      -rw-r--r--  1 miya staff    0 12 19 14: 5 suid_B
      -rwSrwsrws  1 miya staff    0 12 19 14: 5 suid_A
      drwtrwtrwT  2 miya staff   64 12 19 14: 5 sticky_bit_B
      drwtrwtrwt  2 miya staff   64 12 19 14: 5 sticky_bit_A
      -rwsrwSrws  1 miya staff    0 12 19 14: 4 sgid_B
      -rwsrwsrws  1 miya staff    0 12 19 14: 4 sgid_A
      -rw-r--r--  1 miya staff 4439 12 19 20:50 file_4.txt
      -rw-r--r--  1 miya staff 2332 12 19 20:49 file_3.txt
      -rw-r--r--  1 miya staff 1044 12 19 20:51 file_2.txt
      -rw-r--r--  1 miya staff 2135 12 19 20:50 file_1.txt
      drwxr-xr-x  2 miya staff   64 12 19 14: 9 dir_3
      drwxr-xr-x  2 miya staff   64 12 19 14: 9 dir_2
      drwxr-xr-x  2 miya staff   64 12 19 14: 9 dir_1
      -rw-r--r--  1 miya staff    0 12 19 18:30 .secret_file_2
      -rw-r--r--  1 miya staff    0 12 19 18:29 .secret_file_1
      drwxr-xr-x 17 miya staff  544 12 19 20:50 .
    TEXT

    @options = Options.new(['-arl'])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end
end
