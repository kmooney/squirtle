module Squirtle::Parser

    class OneOf
        attr_reader :options
        def initialize(*options)
            @options = options
        end

        def inspect()
            return "OneOf(#{options.inspect})"
        end

        def to_s
            return inspect
        end
    end

    class Optional
        attr_reader :options
        def initialize(*options)
            @options = options
        end

        def inspect
            return "Optional(#{options.inspect})"
        end
    end

    def self.debug(str, element, tag, d)
        gd = d
        puts (0...d).map {"    "}.join + "#{tag.inspect} -> #{element.inspect} '#{str[0...20]}'"
    end

    def self.sdebug(str, element)
        printf "%-40s %s\n", element.inspect, str
    end

    def self.eval_element(str, element, sequence_name, d = 0)
        str = str.strip.downcase
        #debug(str,element, sequence_name, d)
        #sdebug(str, element)
        #puts (0...d).map{" "}.join + "i: " + element.class.to_s + " " + element.to_s
        case element
        when String
            if str.start_with?(element.downcase)
                rest = str[element.length..-1]
                return TerminalNode.new(element), rest
            else
                return false, str
            end
        when Regexp
            if m = str.match(element)
                rest = str[m[0].length..-1]
                return TerminalNode.new(m[0]), rest 
            else
                return false, str
            end
        when OneOf
            _m = nil
            node = element.options.find do |o| 
                _m, _str = eval_element(str, o, sequence_name, d)
                str = _str if _m
                _m
            end
            if !node.nil?
                return _m, str
            else 
                return false, str
            end
        when Optional
            node, str = eval_sequence(str, element.options, sequence_name, d + 1)
            if node
                return node, str
            else
                return TerminalNode.new(nil), str
            end
        when Symbol
            return eval_sequence(str, @grammar[element], element, d + 1)
        end
    end

    def self.eval_sequence(str, sequence, sequence_name, d = 0)
        tree = Node.new(sequence_name, d)
        str = str.strip.downcase
        sequence.each do |element|
            r, str = eval_element(str, element, sequence_name, d) 
            if r
                tree.add_child(r) if !r.defunct
            else
                return false, str
            end
        end
        return tree, str
    end

    def self.match(str, sequence_name = nil)
        str = str.strip.downcase
        sequence_name = :statement if sequence_name.nil?
        sequence = @grammar[sequence_name]
        e, str = eval_sequence(str, sequence, sequence_name)
        # puts e
        return e
    end

    class Node

        def initialize(sequence_name, depth)
            @sequence_name = sequence_name
            @children = []
            @depth = depth
        end

        def add_child(node)
            #puts "#{self} <- #{node}"
            @children << node
        end

        def to_s
            return "\n" + (0...@depth).map{" "}.join() + "(:#{@sequence_name} #{@children.join(" ")})"
        end

        def defunct
            false
        end

    end

    class TerminalNode < Node
        def initialize(value)
            @value = value
        end

        def defunct
            return @value.nil?
        end

        def to_s
            return "'#{@value}'"
        end

    end

    @first_fail = nil
    @grammar = {
        :statement => [
           OneOf.new(:select, :insert, :delete, :update)
        ],
        :update => [
            "UPDATE", :table_name, "SET", :fields, Optional.new(:where)
        ],
        :delete => [
            "DELETE", "FROM", :table_name, Optional.new(:where)
        ],
        :insert => [
            "INSERT", "INTO", :table_name, "(", :fields, ")", "VALUES", :val_def
        ],
        :val_def => [
            "(", :values, ")", Optional.new(",", :val_def)
        ],
        :select => [
            "SELECT", 
            :fields, 
            "FROM", 
            :table_name, 
            Optional.new(:joins), 
            Optional.new(:where), 
            Optional.new(:group_by)
        ],
        :fields => [
            OneOf.new("*", :field_def)
        ],
        :field_def => [
            :field, Optional.new(",", :field_def)
        ],
        :field => [
            OneOf.new(:aggregate_function, :table_field)
        ],
        :values => [
            :value, Optional.new(",", :values)
        ],
        :table_field => [
            /[\w]*[\.\w]*/, Optional.new(:alias)
        ],
        :alias => [
            "AS", /^[\w]+/
        ],
        :aggregate_function => [
            :function_name, "(", :values, ")"
        ],
        :function_name => [
            /^[\w]+/
        ],
        :table_name => [
            /^[\w]+/, Optional.new(:alias)
        ],
        :joins => [
            :join, Optional.new(:joins)
        ],
        :join => [
            Optional.new(OneOf.new("INNER", "LEFT", "RIGHT", "OUTER")), "JOIN", :table_name, "ON", :conditions
        ],
        :conditions => [
            :condition, Optional.new(:logical_operator, :conditions)
        ],
        :condition => [
            :value, :operator, :value
        ],
        :operator => [
            OneOf.new("=", ">", "<", ">=", "<=", "<>", "LIKE", "IN")
        ],
        :value => [
            OneOf.new(:literal, :field)
        ],
        :literal => [
            OneOf.new(:dquote_literal, :squote_literal, :number, :list_expr)
        ],
        :list_expr => [
            "(", :values, ")"
        ],
        :dquote_literal => [
            "\"", /^[\w]+/, "\""
        ],
        :squote_literal => [
            "'", /^[\w]+/, "'"
        ],
        :number => [
            /^\d+/
        ],
        :where => [
            "WHERE", :conditions
        ],
        :group_by => [
            "GROUP", "BY", :fields
        ],
        :logical_operator => [
            OneOf.new("AND", "OR")
        ]
    }
end