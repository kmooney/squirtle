module Squirtle; end
require ("./parser")


sql = "
    SELECT 
        e.first_name AS first, 
        e.last_name AS last, 
        e.department_id AS dept_id, 
        s.amount AS salary 
    FROM employees AS e 
    JOIN salaries AS s ON e.id = s.employee_id 
    LEFT JOIN privleges AS p ON e.id = p.employee_id
    LEFT JOIN privleges AS p2 ON e.id = p.employee_id
    GROUP BY dept_id"
#puts Squirtle::Parser.match(sql)

sql = "INSERT INTO employees 
        (first_name, last_name, department_id)
       VALUES 
        ('Kevin', 'Mooney', 1), ('John', 'Doe', 2)
    "
#puts Squirtle::Parser.match(sql)

sql = "DELETE FROM employees WHERE employee_id = 1"
#puts Squirtle::Parser.match(sql)

sql = "SELECT SUM(salaries) FROM table"
puts Squirtle::Parser.match(sql)


