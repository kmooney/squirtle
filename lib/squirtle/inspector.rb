module Squirtle
	
	class Inspector
		def initialize(parse_tree)
			@root = parse_tree
		end

		def join_tables
			joins = @root.find(:join)
			return joins.map {|j| j.find(:table_name).first.children.first.value}
		end

		def from_table
			from_tree = @root.find(:from).first
			return from_tree.find(:table_name).first.children.first.value
		end

		def select_fields
			select_tree = @root.find(:select_fields).first
			field_values = select_tree.find(:field_val)
			return field_values.map {|child| child.children.first.value}
		end

		def query_type
			return @root.children.first.sequence_name
		end



		def where_has?(name)
			where = @root.find(:where).first
			c_arry = where.conditions.find(:condition)
			exprs = c_arry.map do |tree|
				values = tree.find(:value)
				op = tree.operator
				Expression.new(values[0], op, values[1])
			end

			return exprs.find{|e| e.ls == name}
		end

	end

	class Expression
		attr_reader :ls, :op, :rs
		def initialize(ls, op, rs)
			@ls = ls.find(:field_val).first.children.first.value
			@op = op.children.first.sequence_name
			@rs = rs.literal.children.first.children.first.value
		end
	end

end