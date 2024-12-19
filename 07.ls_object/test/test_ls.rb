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
      app_1.rb     file_1.txt   sticky_bit_B
      app_2.js     file_2.txt   suid_A
      dir_1        sgid_A       suid_B
      dir_2        sgid_B
      dir_3        sticky_bit_A
    TEXT

    @options = Options.new([])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end

  def test_run_with_reverse
    expected = <<~TEXT
      suid_B       sgid_A       dir_1
      suid_A       file_2.txt   app_2.js
      sticky_bit_B file_1.txt   app_1.rb
      sticky_bit_A dir_3
      sgid_B       dir_2
    TEXT

    @options = Options.new(['-r'])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end

  def test_run_with_dot_match
    expected = <<~TEXT
      .              dir_2          sticky_bit_A
      .secret_file_1 dir_3          sticky_bit_B
      .secret_file_2 file_1.txt     suid_A
      app_1.rb       file_2.txt     suid_B
      app_2.js       sgid_A
      dir_1          sgid_B
    TEXT

    @options = Options.new(['-a'])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end

  def test_run_with_long_option
    expected = <<~TEXT
      total: 40
      prw-r--r-- 1 miya staff 4489 12 19 14:10 app_1.rb
      prw-r--r-- 1 miya staff 1497 12 19 14:11 app_2.js
      drwxr-xr-x 2 miya staff   64 12 19 14: 9 dir_1
      drwxr-xr-x 2 miya staff   64 12 19 14: 9 dir_2
      drwxr-xr-x 2 miya staff   64 12 19 14: 9 dir_3
      prw-r--r-- 1 miya staff  589 12 19 14:11 file_1.txt
      prw-r--r-- 1 miya staff 1061 12 19 14:11 file_2.txt
      prwsrwsrws 1 miya staff    0 12 19 14: 4 sgid_A
      prwsrwSrws 1 miya staff    0 12 19 14: 4 sgid_B
      drwtrwtrwt 2 miya staff   64 12 19 14: 5 sticky_bit_A
      drwtrwtrwT 2 miya staff   64 12 19 14: 5 sticky_bit_B
      prwSrwsrws 1 miya staff    0 12 19 14: 5 suid_A
      prw-r--r-- 1 miya staff    0 12 19 14: 5 suid_B
    TEXT

    @options = Options.new(['-l'])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end

  def test_run_with_all_options
    expected = <<~TEXT
      total: 40
      prw-r--r--  1 miya staff    0 12 19 14: 5 suid_B
      prwSrwsrws  1 miya staff    0 12 19 14: 5 suid_A
      drwtrwtrwT  2 miya staff   64 12 19 14: 5 sticky_bit_B
      drwtrwtrwt  2 miya staff   64 12 19 14: 5 sticky_bit_A
      prwsrwSrws  1 miya staff    0 12 19 14: 4 sgid_B
      prwsrwsrws  1 miya staff    0 12 19 14: 4 sgid_A
      prw-r--r--  1 miya staff 1061 12 19 14:11 file_2.txt
      prw-r--r--  1 miya staff  589 12 19 14:11 file_1.txt
      drwxr-xr-x  2 miya staff   64 12 19 14: 9 dir_3
      drwxr-xr-x  2 miya staff   64 12 19 14: 9 dir_2
      drwxr-xr-x  2 miya staff   64 12 19 14: 9 dir_1
      prw-r--r--  1 miya staff 1497 12 19 14:11 app_2.js
      prw-r--r--  1 miya staff 4489 12 19 14:10 app_1.rb
      prw-r--r--  1 miya staff    0 12 19 18:30 .secret_file_2
      prw-r--r--  1 miya staff    0 12 19 18:29 .secret_file_1
      drwxr-xr-x 17 miya staff  544 12 19 18:30 .
    TEXT

    @options = Options.new(['-arl'])
    @ls = Ls.new(@fixture_path.join('*'), @options)
    assert_equal expected, @ls.run
  end
end
