
class Squirtle::Grammar

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

end

class Squirtle::SQLGrammar < Squirtle::Grammar

	def self.grammar
	
		return {
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
            :select_fields,
            :from,
            Optional.new(:joins), 
            Optional.new(:where), 
            Optional.new(:group_by)
        ],
        :select_fields => [
            "SELECT", :fields
        ],
        :from => [
            "FROM", :table_name
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
        :field_val => [
            /^[\w]+/
        ],
        :table_val => [
            /^[\w]+\./
        ],
        :values => [
            :value, Optional.new(",", :values)
        ],
        :table_field => [
            Optional.new(:table_val), :field_val, Optional.new(:alias)
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
            OneOf.new(:eq, :gt, :lt, :gte, :lte, :ne, :like, :in)
        ],
        :eq => [
            "="
        ],
        :gt => [
            ">"
        ],
        :lt => [
            "<"
        ],
        :gte => [
            ">="
        ],
        :lte => [
            "<="
        ],
        :ne => [
            "<>" # BS should be oneof <> or !=
        ],
        :like => [
            "LIKE"
        ],
        :in => [
            "IN"
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
            OneOf.new(:and, :or)
        ],
        :and => [
            "AND"
        ],
        :or => [
            "OR"
        ]
    }

	end


end