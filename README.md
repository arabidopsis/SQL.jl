# SQL.jl

Easy Notebook julia SQL

install with:

```julia
Pkg.add(url="https://github.com/arabidopsis/SQL.jl")
```

Use like:

```julia
import SQL: @sql_df, @sql_cmd, mysql_connect

mysql_connect("mysql://username:$(password)@localhost/database")
N = 5
@sql_df "select * from table limit $(N)"
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

----

## TODO

* add postgresql too
