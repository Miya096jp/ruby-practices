# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../ls'

class TestLs < Minitest::Test
  FIXTURE_PATH = Pathname('test/fixtures/ls')
  def test_run
    expected = <<~TEXT
      app_1.rb     app_2.js     dir_1
      Dir_2        dir_3        file_1.txt
      file_2.txt   sgid_A       sgid_B
      sticky_bit_A sticky_bit_B suid_A
      suid_B       
    TEXT

    assert_equal expected, Ls.run(FIXTURE_PATH)
  end
end
