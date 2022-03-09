# SQL.jl

Easy Notebook julia SQL

install with:

```julia
Pkg.add(url="https://github.com/arabidopsis/SQL.jl")
```

Use like:

```julia
import SQL: @sql, @sql_cmd, sql_connect

sql_connect("mysql://username:$(password)@localhost/database")
N = 5
@sql "select * from table limit $(N)"
```

Currently I can't find a way to do string interpolation
for a custom command:

```julia
# this works
df = sql`select * from table limit 5`

N = 5
# interpolation *does not* work
df = sql`select * from table limit $(N)`

# but this does!
df = @sql_cmd "select * from table limit $(N)"
```

# Using more than one database

Keep the connection objects around:

```julia
conn1 = sql_connect("sqlite:///my.db")
conn2 = sql_connect("mysql://localhost/db")

@sql conn1 "select * from table"
@sql conn2 "select * from table2"
# last connect is "default" so this works on mysql database
@sql "select * from table2"
# set sqlite database as default
SQL.sql_set_default(conn1)
```

----

## TODO

* add postgresql too
