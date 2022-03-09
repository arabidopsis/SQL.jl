module SQL
import MySQL
import DBInterface
import DataFrames: DataFrame
import URIs: URI


export mysql_connect, to_df, @sql_cmd, @sql_df

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

function sql_df(conn, query::String)::DataFrame
    DataFrame(DBInterface.execute(DBInterface.prepare(conn, query)))
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
