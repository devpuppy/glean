class Glean::Event

  attr_reader :experiment, :launcher

  def initialize(experiment, launcher)
    if launcher.is_a?(Hash)
      hash.define_method(:launch?) {|name| !!self[name] }
      @archived = true
    else
      @archived = false
    end
    @experiment = experiment
    @launcher = launcher
  end

  def archived?
    !!@archived
  end

  def bucket
    return nil if excluded?
    return experiment.bucket_names.find do |name|
      launcher.launch?(name)
    end
  end

  # is this event filtered out by experiments preconditions?
  def excluded?
    return false if archived?
    return false unless experiment.preconditions.any?
    return preconditions.values.include?(false)
  end

  def preconditions
    HashWithIndifferentAccess.new.tap do |p|
      experiment.preconditions.each do |condition, value|
        p[condition] = 
        begin
          case condition
          when :language
            [value].flatten.map(&:to_sym).include?(I18n.language)
          when :locale
            [value].flatten.map(&:to_sym).include?(I18n.locale)
          else
            false
          end
        rescue
          false
        end
      end
    end
  end

end