require 'thread'

module Archivededup

  class QueueAppender
    def initialize(queue)
      @queue = queue
    end

    def enq d
      # Fill the queue and feed the threads.
      while @queue.length > 100
        sleep 1
      end
      @queue.enq d
    end

    alias :<< :enq
  end

  class ParallelTask
    def initialize
      @task
    end

    def start(threads=16)

      @queue = Queue.new
      
      #Start the threads.
      @threads = threads.times.map do 
        Thread.new(@queue) do |queue|
          run = true

          while run
            d = queue.deq

            if d.nil?
              run = false
            else
              yield d
            end
          end
        end
      end

    end

    def scatter
      yield QueueAppender.new(@queue)

      @queue.close

      # Join the threads before exiting.
      @threads.each do |t|
        t.join
      end
    end

  end
end