module Glean::Backend
  class Redis

    attr_reader :namespace

    def initialize(options)
      # raise "no client given" unless options[:client].is_a?(Redis)
      options = HashWithIndifferentAccess.new(options)
      @redis = options[:client]
      @namespace = options[:namespace] || "glean"
    end

    def get_experiment_names
      @redis.smembers("#{namespace}/experiment-names")
    end

    def get_experiment(experiment_name)
      data = JSON.parse(@redis.get("#{namespace}/experiments/#{experiment_name}/data")) rescue {}
      Glean::Experiment.new(data)
    end

    def set_experiment(experiment_name, data)
      @redis.sadd("#{namespace}/experiment-names", experiment_name)
      @redis.set("#{namespace}/experiments/#{experiment_name}/data", data.to_json)
    end



  end

end