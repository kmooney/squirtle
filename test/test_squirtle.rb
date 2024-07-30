require "minitest/autorun"
require "squirtle"

class TestSquirtle < Minitest::Test
    def test_select
        assert(Squirtle.parse("SELECT * FROM table"))
    end

    def test_select_with_agg_fun
        assert(Squirtle.parse("SELECT SUM(salaries) FROM table"))
    end

    def test_select_with_nested_agg_fun
        assert(Squirtle.parse("SELECT COALESCE(MIN(salaries), 0) FROM table"))
    end

    def test_update
        assert(Squirtle.parse("UPDATE table SET field = 1"))
    end

    def test_insert
        assert(Squirtle.parse("INSERT INTO table (field) VALUES (1),(2)"))
    end

    def test_delete
        assert(Squirtle.parse("DELETE FROM table WHERE id IN (1,2,3)"))
    end
end