module Jekyll
  module Commands
    class Build < Command
      def self.process(options)
        site = Jekyll::Site.new(options)

        if options['watch']
          self.watch(site, options)
        else
          self.build(site, options)
        end
      end

      # Private: Build the site from source into destination.
      #
      # site - A Jekyll::Site instance
      # options - A Hash of options passed to the command
      #
      # Returns nothing.
      def self.build(site, options)
        source = options['source'] # default ./ (current dir)
        destination = options['destination'] # default ./_site
        puts  "            Source: #{source}"
        puts  "       Destination: #{destination}"
        print "      Generating... "
        begin
          site.process
        rescue Jekyll::FatalException => e
          puts
          puts "ERROR: YOUR SITE COULD NOT BE BUILT:"
          puts "------------------------------------"
          puts e.message
          exit(1)
        end
        puts "done."
      end

      # Private: Watch for file changes and rebuild the site.
      #
      # site - A Jekyll::Site instance
      # options - A Hash of options passed to the command
      #
      # Returns nothing.
      def self.watch(site, options)
        require 'directory_watcher'

        source = options['source']
        destination = options['destination']

        puts "            Source: #{source}"
        puts "       Destination: #{destination}"
        puts " Auto-regeneration: enabled"

        # Private: Instanciates new DirectoryWatcher object
        #
        # interval - scanning interval (in seconds)
        # glob - files/dirs you wish to monitor
        # add_observer - recieves file events when they are generated
        #              - passed in block is executed with the file events passed as arguments
        # start - starts the DW scanning thread
        dw = DirectoryWatcher.new(source)
        dw.interval = 1
        dw.glob = self.globs(source, destination)

        dw.add_observer do |*args|
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          print "      Regenerating: #{args.size} files at #{t} "
          begin
            site.process
          rescue Jekyll::FatalException => e
            puts
            puts "ERROR: YOUR SITE COULD NOT BE BUILT:"
            puts "------------------------------------"
            puts e.message
            exit(1) # exits with code of 1 -> 1 is convention that it exited because smth went wrong
          end
          puts  "...done."
        end

        dw.start

        # Graceful handling of forced stop process given by pressing Ctrl+C
        unless options['serving']
          trap("INT") do # trap("INT") activates when you press 'interrupt' signal, such as Ctrl+C
            puts "     Halting auto-regeneration."
            exit 0 # exits with code of 0 -> 0 is convention that it exited properly
          end

          loop { sleep 1000 }
        end
      end
    end
  end
end
