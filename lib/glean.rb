class Glean

  class << self

    attr_reader :backend
    attr_writer :default_launcher

    def set_backend(backend_name, *args)
      @backend = Glean::Backend::Redis.new(*args)
    end

    def experiment_names
      @backend.get_experiment_names
    end

    def default_launcher
      @default_launcher.is_a?(Proc) ? @default_launcher.call : @default_launcher
    end

  end

  def self.[](experiment_name)
    Glean::Experiment.find(experiment_name).event(default_launcher).bucket
  end

  # # ooh what about...
  # Glean['Awesomesauce'] do
  #   bucket 'Aces' { 'red button' }
  #   bucket 'Betamax' { 'blue button' }
  #   control { 'whatever' }
  # end

end



# require all the files
cwd = File.dirname(__FILE__)
Dir["#{cwd}/**/*.rb"].each do |filename|
  filename.gsub!(/\A#{cwd}\//,'')
  filename.gsub!(/\.rb\Z/,'')
  require filename
end