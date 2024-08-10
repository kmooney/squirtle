module Squirtle
    def self.parse(sql)
        return Parser.match(sql)
    end
end

require "squirtle/inspector"
require "squirtle/grammar"
require "squirtle/parser"
