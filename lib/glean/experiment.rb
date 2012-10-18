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

  def self.find(experiment_name)
    data = Glean.backend.get_experiment_data(experiment_name)
    Glean::Experiment.new(data)
  end

  def valid?
    errors.empty?
  end

  def errors
    [].tap do |errors|
      errors << "Missing experiment name" unless name.present?
      errors << "Missing bucket names" if bucket_names.empty?
      errors << "Missing bucket percent" unless bucket_percent.present?
      errors << "Non-integer bucket percent" unless bucket_percent.is_a?(Integer)
      errors << "Subject must be 'user', 'visitor', or 'hosting'" unless subject_valid?
      errors << "Bucket percent too large" unless bucket_count.to_i * bucket_percent.to_i < 100
      valid_bucket_percents = [1, 5, 10, 20, 25, 50]
      unless valid_bucket_percents.include?(bucket_percent)
        errors << "Invalid bucket percent. Try: #{valid_bucket_percents.map(&:to_s).join(', ')}"
      end
      # errors << "'Control' bucket should not be specified" if bucket_names.include?("control")
    end
  end

  def save
    raise errors.join(" ") unless valid?
    Glean.backend.set_experiment_data(self.name, options)
  end

  def event(launcher = nil)
    launcher ||= Glean.default_launcher
    raise "No launcher specified" unless launcher
    Glean::Event.new(self, launcher)
  end

  def preconditions
    @options[:preconditions] || []
  end

  def bucket_count
    bucket_names.size + 1
  end

  def bucket_names
    @options[:bucket_names] || []
  end

  def bucket_percent
    @options[:bucket_percent]
  end

  def subject
    @options[:subject]
  end

  def subject_valid?
    ['user', 'visitor', 'hosting'].include?(self.subject)
  end

  # hardcoded
  def strategy_arguments(bucket_name)
    position = bucket_names.index(bucket_name)
    strategy_name = case subject
    when 'user'
      :experiment
    when 'visitor'
      :visitor_experiment
    else
      raise "Hosting subject not yet implemented"
    end
    total_buckets = 100 / bucket_percent
    [strategy_name, {:name => name, :total_buckets => (100 / bucket_percent), :bucket => position}]
  end


  def configure
    bucket_names.each do |bucket_name|
      feature_name = bucket_feature_name(bucket_name)
      # raise "Feature name already used by Trebuchet: #{feature_name}" if Trebuchet::Feature.exist?(feature_name)
      Trebuchet.aim(feature_name, *strategy_arguments(bucket_name))
    end
  end

  def bucket_feature_name(bucket_name)
    "Glean | #{self.name} | #{bucket_name}"
  end


  # def trebuchet=(t)
  #   @trebuchet = t
  # end

  # def trebuchet
  #   @trebuchet ||= Trebuchet.current
  # end

end