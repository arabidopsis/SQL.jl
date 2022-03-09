module SQL
import MySQL
import DBInterface
import DataFrames: DataFrame
import URIs: URI


export mysql_connect, sql_df, set_db, @sql_cmd, @sql_df, @sql_cmd

CC = nothing

function mysql_connect(uri::String)
    u = URI(uri)
    user, password = split(u.userinfo, ":")
    if u.port == ""
        port = 3306
    else
        port = parse(Int, u.port)
    end
    @assert startswith(u.scheme, "mysql")
    global CC
    CC = DBInterface.connect(MySQL.Connection, string(u.host), string(user), string(password); port = port, db = string(u.path[2:end]))
    CC
end

"Set default database connection to conn"
function set_db(conn)
    global CC
    CC = conn
end
"Execute an SQL query on database conn"
function sql_df(conn, query::String)::DataFrame
    @assert conn != nothing "no database connection!"
    DataFrame(DBInterface.execute(DBInterface.prepare(conn, query)))
end


function sql_df(conn::String, query::String)::DataFrame
    conn = mysql_connect(conn)
    sql_df(conn, query)
end

function sql_df(query::String)::DataFrame
    sql_df(CC, query)
end

macro sql_cmd(query)

    return quote
        local q0 = @eval $query

        sql_df(CC, q0)
    end
end

macro sql_df(conn, query)
    return quote
        local c = @eval $conn
        local q2 = @eval $query
        sql_df(c, q2)
    end
end
macro sql_df(query)
    return quote
        local q = @eval $query
        sql_df(CC, q)
    end
end

end # module
