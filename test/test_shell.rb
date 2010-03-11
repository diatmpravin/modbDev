# This is the Rails Test Shell.
ENV['RAILS_ENV'] = 'test'

# Make it clear that the user isn't at a NORMAL irb prompt.
require 'irb'
module IRB
  class << self
    alias test_shell_setup setup
    def setup(ap_path)
      test_shell_setup(ap_path)
      
      @CONF[:PROMPT_MODE] = :TEST
      @CONF[:PROMPT][:TEST] = {
        :PROMPT_I => 'test> ',
        :PROMPT_N => 'test> ',
        :PROMPT_S => 'test: ',
        :PROMPT_C => 'test* ',
        :RETURN => "%s\n\n"
      }
    end
  end
end

# Forward requests intended for the Test Shell off to our own module.
# We need this so our dangerous method names (like "all" and
# "method_missing") don't contaminate Object.
# 
# Actually, I got rid of all those methods, but this way is better.
require 'irb/workspace'
module IRB
  class WorkSpace
    alias test_shell_evaluate evaluate
    def evaluate(context, statements, file = __FILE__, line = __LINE__)
      if statements =~ /^\s*(#{TestShell::KEYS.join('|')})/
        TestShell::run_tests_for(statements)
      else
        test_shell_evaluate(context, statements, file, line)
      end
    end
  end
end

# Named tests aren't useful unless they auto-complete, right?
require 'readline'
Readline.completion_proc = proc {|input|
  candidates = Dir.glob("{unit,functional,integration}/**/*test.rb").map {|test|
    test.gsub(/\.(.*)$/,'').split('/').join(':')
  }.sort {|a,b| a.length <=> b.length} + ['units', 'functionals', 'integration', 'all']

  # The sort reference was SUPPOSED to help prioritize "device_test" over "device_tag_test".
  # However, it doesn't matter since (1) readline overrides it and (2) there's no tab cycling anyway.
  
  candidates.grep(/^#{Regexp.escape(input)}/)
}

# Load up /lib and /test.
['/.', '/../lib'].each do |path|
  $LOAD_PATH << File.expand_path(File.dirname(__FILE__) + path)
end

# Move into the test directory, if we aren't there already.
while Dir.pwd =~ /test/
  Dir.chdir '..'
end
Dir.chdir 'test'

puts "Loading Rails environment..."

require 'test_helper'
require 'test/unit/ui/console/testrunner'

# I want reloads!
#ActiveSupport::Dependencies.mechanism = :load
#ActiveSupport::Dependencies.mechanism = :require

module TestShell
  KEYS = [
    'all',
    'units',
    'functionals',
    'integration',
    'unit:',
    'functional:',
    'integration:'
  ]
  
  class << self
    # Do a "basic" reload
    def reload!
      Dispatcher.cleanup_application
      Dispatcher.reload_application
      Test::Spec::CONTEXTS.clear
      $LOAD_FAIL_TABLE = {}
    end

    # VERY EXPERIMENTAL. This is an attempt to handle migrated tables/models
    # without having to exit the test shell. Will be improved as more opportunities
    # to test it arise.
    def models!
      # load '../db/schema.rb'
      
      models = Object.constants.map {|c| Object.const_get(c)}.select {|c| c.is_a?(Class) && c.superclass == ActiveRecord::Base}
      models = models.map(&:to_s)
      
      # This erases the class definitions, as long as nothing ELSE is holding onto a ref -- possibly controllers?
      models.each do |c|
        Object.instance_eval {remove_const c}
      end
      
      # Allow Kernel.require to re-load these models when references to them crop up
      # "tableize.singularize" is effective, but not airtight
      models.each do |c|
        $".reject! {|x| x =~ /app\/models\/#{c.tableize.singularize}/}
      end
      
      # Hopefully the auto-loader can do the rest of the work for us
      
      # TODO: What about those pesky namespaced models and controllers?
    end
    
    # These are the guts. Reload, load the desired tests, run them, and return.
    #
    # Approach #1:
    #   run_tests_for(:alert_recipient_test)
    #
    # Approach #2:
    #   run_tests_for('*', [list of directories], 'Suite Title')
    #
    def run_tests_for(test_pattern)
      reload!
      
      test_pattern.chomp!
      case test_pattern
      when 'all'
        title = 'All Tests'
        pattern = '{unit,functional,integration}/**/*'
      when 'units'
        title = 'Unit Tests'
        pattern = 'unit/**/*'
      when 'functionals'
        title = 'Functional Tests'
        pattern = 'functional/**/*'
      when 'integration'
        title = 'Integration Tests'
        pattern = 'integration/**/*'
      else
        title = nil
        pattern = test_pattern.gsub(':', '/')
      end
      
      files = Dir.glob("#{pattern}.rb")
      files.each {|file| load file}
      
      if !title
        if Test::Spec::CONTEXTS.any?
          title = Test::Spec::CONTEXTS.keys.sort.first
        else
          title = 'unknown'
        end
      end
      
      title += " (#{files.length} files)"
      
      suite = Test::Unit::TestSuite.new(title)
      Test::Spec::CONTEXTS.each do |title, container|
        suite << container.testcase.suite
      end
      
      Test::Unit::UI::Console::TestRunner.run(suite).passed?
    end
    
    
      
      # Dir.glob("{#{dirs.join(',')}}/**/#{symbol}.rb").each do |file|
        # # Now we're living dangerously. Here's some damage control for problems that
        # # arise when loading namespaced models and controllers.
        # begin
          # load file
        # rescue LoadError => e
          # if e.message =~ /Expected (.*) to define (.*)/
            # if $LOAD_FAIL_TABLE[$1]
              # raise e
            # end
            # puts "#{$1} -> #{$2}"
            # $LOAD_FAIL_TABLE[$1] = true
            
            # load $1
            # retry
          # else
            # raise e
          # end
        # end
      # end
      
      
  end
end


# Done!

puts <<-END_HELP
Rails Test Shell

Type one of the following keywords to start a test suite:
  * all
  * units
  * functionals
  * integration

Run any individual test by typing its filename, without the extension:
  * my_unit_test
  * my_controller_test

Lazy? Use tab auto-completion for fewer keystrokes.

END_HELP

IRB.start
