class Glean::Experiment

  attr_accessor :name
  attr_reader :options

  def initialize(options)
    # options = Hash[options.map{|(k,v)| [k.to_sym,v]}]
    options = HashWithIndifferentAccess.new(options)
    # self.name = options.delete('name')
    self.name = options[:name]
    @options = options
  end

  def self.get(experiment_name)
    self.new Glean.backend.get_experiment(experiment_name)
  end

  def save
    Glean.backend.set_experiment(self.name, options)
  end

  def preconditions
    @options[:preconditions] || []
  end

  def bucket_names
    ["control", "a", "b", "c"]
  end


  def trebuchet=(t)
    @trebuchet = t
  end

  def trebuchet
    @trebuchet ||= Trebuchet.current
  end

end