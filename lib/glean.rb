class Glean

  class << self

    attr_reader :backend

    def set_backend(backend_name, *args)
      @backend = Glean::Backend::Redis.new(*args)
    end

    def experiment_names
      @backend.get_experiment_names
    end

  end



end


# require all the files
cwd = File.dirname(__FILE__)
Dir["#{cwd}/**/*.rb"].each do |filename|
  filename.gsub!(/\A#{cwd}\//,'')
  filename.gsub!(/\.rb\Z/,'')
  require filename
end