module Jekyll
  class Command
    def self.globs(source, destination)
      # by 'globbing' files you can use regular expression-like-pattern
      # to select the files you want
      Dir.chdir(source) do
        dirs = Dir['*'].select { |x| File.directory?(x) }
        # this Dir['*'] is a 'globbing' technique
        # in this case it selects all directories
        dirs -= [destination, File.expand_path(destination), File.basename(destination)]
        # -= subtracts elements from original array
        dirs = dirs.map { |x| "#{x}/**/*" }
        # * matches any single file or folder
        # ** matches any string of folders
        # **/* matches files in an entire folder tree
        dirs += ['*']
      end
    end
  end
end
