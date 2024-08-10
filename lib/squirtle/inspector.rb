module Squirtle
	
	class Inspector
		def initialize(parse_tree)
			@root = parse_tree
		end

		def join_tables
			tables = []
			joins = @root.find(:join)
			return joins.map {|j| j.find(:table_name).first.children.first.value}
		end

		def from_table
		end

		def select_fields
		end

		def where_criteria
		end

	end

end