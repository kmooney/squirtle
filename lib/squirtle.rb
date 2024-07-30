module Squirtle
    def self.parse(sql)
        return Parser.match(sql)
    end
end

require "squirtle/parser"