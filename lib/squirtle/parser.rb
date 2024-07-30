module Squirtle::Parser
    class ParserError < StandardError
        def initialize(str, first_fail)
            @str = str
            @first_fail = first_fail
        end

        def message
            "Failed to parse #{@first_fail.inspect} near #{@str}"
        end
    end

    class OneOf
        attr_reader :options
        def initialize(*options)
            @options = options
        end

    end

    class Optional
        attr_reader :options
        def initialize(*options)
            @options = options
        end
    end

    def self.eval_element(str, element)
        str = str.strip.downcase
        # puts "#{str.gsub(/[\n \t]+/, " ")} - (#{element.inspect})"
        case element
        when Symbol
            m, str = eval_sequence(str, @grammar[element])
            return false, str if !m
        when String
            if str.start_with?(element.downcase)
                str = str[element.length..-1]
            else
                return false, str
            end
        when Regexp
            if m = str.match(element)
                str = str[m[0].length..-1]
            else
                return false, str
            end
        when OneOf
            m = element.options.find do |o| 
                _m, _str = eval_element(str, o)
                str = _str if _m
                _m
            end
            return false, str if m.nil?
        when Optional
            _, str = eval_sequence(str, element.options)
        end
        return true, str
    end

    def self.eval_sequence(str, sequence)
        str = str.strip.downcase
        sequence.each do |element|
            r, str = eval_element(str, element)
            return false, str if !r
        end
        return true, str
    end

    def self.match(str, position = nil)
        str = str.strip.downcase
        position = :statement if position.nil?
        sequence = @grammar[position]
        e, str = eval_sequence(str, sequence)
        # puts "failed on #{str}" if !e
        return e
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
            /^[\w]+[\.\w]*/, Optional.new(:alias)
        ],
        :alias => [
            "AS", /^[\w]+/
        ],
        :aggregate_function => [
            :function_name, "(", :fields,")"
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
            OneOf.new(:field, :literal)
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