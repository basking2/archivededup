
require 'time'


module Archivededup

  module FileNamePickerByDate

    @@times = [
      /(\d\d\d\d)-(\d?\d)-\d?\d/, # eg 2021-09-08
      /(\d\d\d\d)(\d\d)\d\d/,     # eg 20210908
      /(\d\d\d\d)-(\d\d)/,        # eg 2021-09
      /(\d\d\d\d)(\d\d)/,         # eg 202109
      /(\d\d\d\d)/,               # eg 2021
    ]

    def self.goodmatch?(m)
      return false if m.nil?
      year = m.length > 1? m[1].to_i : 0
      month = m.length > 2? m[2].to_i : 0

      return false if year < 1979
      return false if year > 2100
      return false if month < 0
      return false if month > 12

      true
    end
    
    def self.call(a, b)
      last_compare = 0
      @@times.find do |re|
        ma = goodmatch?(re.match(a))
        mb = goodmatch?(re.match(b))

        if ma 
          if mb
            false
          else
            # Pick a as better.
            last_compare = -1
            true
          end
        else
          if mb
            # Pick b as better.
            last_compare = 1
            true
          else
            false
          end
        end
      end

      last_compare
    end
  end

  # From a list of file names, pick the file that provides the most information
  # and so should be kept.
  #
  class FilePicker
    def initialize()
      # A list of ways to compare file names.
      # These are applied in-order until one returns non-zero.
      @comparators = []
      @comparators << FileNamePickerByDate
      @comparators << proc { |a, b| b.length <=> a.length }
    end

    def pick(filelist)

      filelist.sort do |a,b|

        # Default the sort to be equal, no sort.
        last_compare = 0

        # Run comparators until one selcts a better file name.
        @comparators.find do |c|
          last_compare = c.call(a, b)
          last_compare != 0
        end

        # Return the result of the last comparison.
        last_compare
      end.
      first
    end
  end
end