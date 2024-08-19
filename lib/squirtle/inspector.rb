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

		def where_criteria
			conditions = @root.find(:where)
			puts conditions.join("||")
		end

	end

end