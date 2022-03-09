module SQL

import MySQL
import DBInterface
import DataFrames: DataFrame
import URIs: URI
import SQLite


export sql_df, set_db, @sql_cmd, @sql_df, @sql_cmd, connect

CC = nothing

function connect(uri::String)
    u = URI(uri)
    if startswith(u.scheme, "mysql")
        return mysql_connect(u)
    end
    if startswith(u.scheme, "sqlite")
        return sqlite_connect(u)
    end
    throw(ArgumentError("not a known schema $(uri)"))
end

function mysql_connect(u::URI)
    user, password = split(u.userinfo, ":")
    # need to be strings not substrings :(
    user = String(user)
    password = String(password)
    host = String(u.host)
    if u.port == ""
        port = 3306
    else
        port = parse(Int, u.port)
    end
    db = String(u.path[2:end])
    query = filter(t -> t[1] == "unix_socket", [split(q, "=") for q in split(u.query, "&")])
    if length(query) >= 1
        unix_socket = String(query[1][2])
    else
        unix_socket = MySQL.API.MYSQL_DEFAULT_SOCKET
    end
    @assert startswith(u.scheme, "mysql")
    global CC
    CC = DBInterface.connect(MySQL.Connection, host, user, password; port = port, db = db, unix_socket = unix_socket)
    CC
end

function sqlite_connect(u::URI)
    @assert startswith(u.scheme, "sqlite") "not an sqlite database"
    db = String(u.path[2:end])
    global CC
    CC = DBInterface.connect(SQLite.DB, db)
    CC
end

"Set default database connection to conn or rest to nothing"
function set_db(conn::Union{DBInterface.Connection,Nothing})::Union{DBInterface.Connection,Nothing}
    global CC
    old = CC
    CC = conn
    old
end
"Execute an SQL query on database conn"
function sql_df(conn, query::String)::DataFrame
    @assert conn !== nothing "no database connection!"
    DataFrame(DBInterface.execute(DBInterface.prepare(conn, query)))
end


function sql_df(conn::String, query::String)::DataFrame
    conn = mysql_connect(conn)
    sql_df(conn, query)
end

function sql_df(query::String)
    sql_df(CC, query)
end

macro sql_cmd(query::String)

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
