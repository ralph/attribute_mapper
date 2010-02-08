require 'digest/sha1'

# DO NOT MODIFY THIS FILE
module Bundler
  FINGERPRINT = "2d296ffa941ae094fa98c1e1a99f7c97ff2f068b"
  LOAD_PATHS = ["/Users/ralph.heyden/.bundle/gems/json_pure-1.2.0/lib", "/Users/ralph.heyden/.bundle/gems/rubyforge-2.0.3/lib", "/Users/ralph.heyden/.bundle/gems/git-1.2.5/lib", "/Users/ralph.heyden/.rvm/gems/ruby-1.9.1-p376/gems/activesupport-2.3.5/lib", "/Users/ralph.heyden/.bundle/gems/sqlite3-ruby-1.2.5/lib", "/Users/ralph.heyden/.bundle/gems/sqlite3-ruby-1.2.5/ext", "/Users/ralph.heyden/.bundle/gems/rcov-0.9.7.1/lib", "/Users/ralph.heyden/.bundle/gems/shoulda-2.10.3/lib", "/Users/ralph.heyden/.bundle/gems/gemcutter-0.3.0/lib", "/Users/ralph.heyden/.bundle/gems/yard-0.5.3/lib", "/Users/ralph.heyden/.bundle/gems/jeweler-1.4.0/lib", "/Users/ralph.heyden/.bundle/gems/activerecord-2.3.5/lib"]
  AUTOREQUIRES = {:default=>["activerecord", "yard"], :test=>["shoulda", "rcov", "jeweler", "sqlite3-ruby"]}

  def self.match_fingerprint
    print = Digest::SHA1.hexdigest(File.read(File.expand_path('../../Gemfile', __FILE__)))
    unless print == FINGERPRINT
      abort 'Gemfile changed since you last locked. Please `bundle lock` to relock.'
    end
  end

  def self.setup(*groups)
    match_fingerprint
    LOAD_PATHS.each { |path| $LOAD_PATH.unshift path }
  end

  def self.require(*groups)
    groups = [:default] if groups.empty?
    groups.each do |group|
      (AUTOREQUIRES[group] || []).each { |file| Kernel.require file }
    end
  end

  # Setup bundle when it's required.
  setup
end
