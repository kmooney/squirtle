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

	end

end