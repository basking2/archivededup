
require 'dbm'
require 'digest'
require 'thread'
require 'yaml'

module Archivededup
  class Db
    def initialize(dbfile)
      @db = DBM.new(dbfile, 0755, DBM::WRCREAT)
    end

    def each_hash
      @db.select do |k, v|
        k.start_with? 'hash - '
      end.map do |k, v|
        [k, YAML::load(v)]
      end.each do |k, r|
        yield k, r
      end
    end

    def each_dup
      @db.select do |k, v|
        k.start_with? 'hash - '
      end.map do |k, v|
        [k, YAML::load(v)]
      end.select do |k, r|
        r['files'].length > 1
      end.each do |k, r|
        yield k, r
      end
    end

    def add_directory(dir, &blk)
      Dir.new(dir).each do |dent|
        d = File.join(dir, dent)
    
        next if dent == '.'
        next if dent == '..'
        next if dent.start_with? '.'
    
        if File.directory? d
          add_directory(d, &blk)
        else
          yield d if block_given?
        end
      end
    end

    def add_file(d)
      # puts "Got #{d}"
      s = File.stat(d)
      # noimplemented - s.birthtime
      s.mtime
      s.ctime
      # unused - s.atime
      # puts d, s
      hash = Digest::MD5.new
      outbuf = ''

      File.open(d) do |io|
        while io.read(4096, outbuf) do
          hash.update outbuf
        end
      end
      
      unless @db.has_key? "name - #{d}"

        hash = hash.hexdigest

        @db["name - #{d}"] = YAML::dump({
          dir: d,
          hash: hash,
        })

        if @db.has_key?('hash - '+hash)
          o = YAML::load(@db['hash - '+hash])
          buf1 = ''
          buf2 = ''
          File.open(d) do |io1|
            File.open(o['files'][0]) do |io2|
              v1 = ''
              v2 = ''
              while v1 && v2 && v1 == v2 do
                v1 = io1.read(4096, buf1)
                v2 = io2.read(4096, buf2)
              end

              if v1 == v2
                o['files'] << d
                puts "Dups found: #{o}"
                @db['hash - '+hash] = YAML::dump(o)
              end
            end
          end
        else
          puts "Storing #{d}."
          @db['hash - '+hash] = YAML::dump({
            'files' => [ d ],
            'hash' => hash,
          })
        end
      else
        puts "Had #{d}."
      end
    end

    def close()
      @db.close()
    end
  end
end
