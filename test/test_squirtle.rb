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
        assert(Squirtle.parse("SELECT COALESCE(MIN(salaries), 0) FROM employees"))
    end

    def test_update
        assert(Squirtle.parse("UPDATE table SET field = 1"))
    end

    def test_insert
        assert(Squirtle.parse("INSERT INTO employees (name, salary) VALUES ('kevin', 40000),('bob', 90000)"))
    end

    def test_delete
        assert(Squirtle.parse("DELETE FROM table WHERE id IN (1,2,3)"))
    end
    def test_select_join
        assert(Squirtle.parse("SELECT author.name, book.title FROM books AS book JOIN authors AS author ON book.author_id = author.id WHERE book.id = 123"))
    end
    def test_invalid_fails
        assert(!Squirtle.parse("SELECT uhh"))
    end

    def test_invalid_two
        assert(!Squirtle.parse("SELECT $ FROM 098 WHERE xyz = SELECT"))
    end

end