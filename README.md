# SQL.jl
Easy Notebook julia SQL


install with

```julia
Pkg.add(url="https://github.com/arabidopsis/SQL.jl")
```

Use like:

```julia
import SQL: @sql_df, mysql_connect

mysql_connect("mysql://username:$(password)@localhost/database")
N = 5
@sql_df "select * from table limit $(N)"
```
