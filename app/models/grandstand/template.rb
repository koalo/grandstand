class Grandstand::Template
  class << self
    def [](name)
      @templates ||= {}
      @templates[name] ||= new(name)
    end

    protected
    def method_missing(*args)
      method = args.shift.to_sym
      self[method].render
    end
  end

  def initialize(name, body = nil)
    @file = Dir[*ApplicationController.view_paths.map {|path| File.join(path.to_s, 'shared', "#{name}.html")}].find {|file| File.file?(file)}
    if body
      @body = body
    elsif @file
      @body = File.read(@file)
    else
      return false
    end
  end

  def path
    @file.freeze
  end

  def render
    @body.freeze
  end
end
