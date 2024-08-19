module Squirtle

    class Node

        attr_reader :children, :sequence_name

        def initialize(sequence_name, depth)
            @sequence_name = sequence_name
            @children = []
            @depth = depth
        end

        def find(sequence_name)
            result = []
            # examine each child, if the sequence matches, add the node to the list.
            result = @children.select {|c| c.sequence_name == sequence_name}
            result += @children.map {|c| c.find(sequence_name)}.flatten
            return result
        end

        def add_child(node)
            #puts "#{self} <- #{node}"
            @children << node
        end

        def to_s
            return "\n#{@depth}" + (0...@depth).map{" "}.join() + "(:#{@sequence_name} #{@children.join(" ")})"
        end

        def defunct
            false
        end

        def get_child(sequence_name)
        	child = @children.find {|c| c.sequence_name == sequence_name}
        	return child
        end

        # magic to allow chaining thru tree
        def method_missing(name)
        	return get_child(name)
        end

    end

    class TerminalNode < Node

        attr_reader :value

        def initialize(value)
            @value = value
        end

        def sequence_name
            :terminal
        end

        def find(sequence_name)
            # terminal nodes have no children
            return []
        end

        def defunct
            return @value.nil?
        end

        def to_s
            return "'#{@value}'"
        end

    end

end