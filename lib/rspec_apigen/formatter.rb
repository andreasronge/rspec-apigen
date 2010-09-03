module RSpec::ApiGen
  class Formatter
    def method_missing(m, *a, &b)
      puts "CALLED #{m}"
    end

    def initialize(output )
    end

    def start(example_count)
      puts "start #{example_count}"
      @current_method = nil
    end

    def example_group_started(example_group)
      # is it a new class ?
      if @current_class != example_group.describes
        @current_class = example_group.describes
        @current_method = nil
        puts "#{@current_class.class} #{example_group.describes}"
      elsif example_group.description == "Public Static Methods"
        puts "  Static Static Methods"
      elsif example_group.description == "Public Instance Methods"
        puts "  Static Instance Methods"
      elsif @current_method
        puts "      #{example_group.description}"
      else
        puts "     Method #{example_group.description}"
        @current_method = example_group.description
      end
#      puts "example_groupstarted #{example_group.describes.class} #{example_group.describes.object_id} #{example_group.description}"
    end

    def start_dump
      puts "start dump"
    end

    def example_started(example)
    end

    def example_passed(example)
      puts "         #{example.metadata[:description]}"
      #puts "         #{example.pretty_inspect}"
    end

    def example_failed(example)
      puts "failed"
    end

    def example_pending(example)
      puts "pending"
    end


  end
end