using HTTP, MbedTLS, Sockets, HTTP.Servers

const nolimit = typemax(Int)

getinet(host::String, port::Integer) = Sockets.InetAddr(parse(IPAddr, host), port)
getinet(host::IPAddr, port::Integer) = Sockets.InetAddr(host, port)

struct Server{S <: Union{SSLConfig, Nothing}, I <: Base.IOServer}
    ssl::S
    server::I
    hostname::String
    hostport::String
end

Base.isopen(s::Server) = isopen(s.server)
Base.close(s::Server) = close(s.server)

Sockets.accept(s::Server{Nothing}) = accept(s.server)::TCPSocket
Sockets.accept(s::Server{SSLConfig}) = getsslcontext(accept(s.server), s.ssl)

function HTTP.listen(f,
                host::Union{IPAddr, String}=Sockets.localhost,
                port::Integer=8081
                ;
                sslconfig::Union{MbedTLS.SSLConfig, Nothing}=nothing,
                tcpisvalid::Function=tcp->true,
                server::Union{Base.IOServer, Nothing}=nothing,
                reuseaddr::Bool=true,
                connection_count::Ref{Int}=Ref(0),
                rate_limit::Union{Rational{Int}, Nothing}=nothing,
                reuse_limit::Int=nolimit,
                readtimeout::Int=0,
                verbose::Bool=false)

    @info "Utilisation du overwrite de 'HTTP.listen'"

    inet = getinet(host, port)
    if server !== nothing
        tcpserver = server
    elseif reuseaddr
        tcpserver = Sockets.TCPServer(; delay=false)
        if Sys.isunix()
            if Sys.isapple()
                verbose && @warn "note that `reuseaddr=true` allows multiple processes to bind to the same addr/port, but only one process will accept new connections (if that process exits, another process listening will start accepting)"
            end
            @info "Autorisation de la réutilisation du port"
            rc = ccall(:jl_tcp_reuseport, Int32, (Ptr{Cvoid},), tcpserver.handle)
            Sockets.bind(tcpserver, inet.host, inet.port; reuseaddr=true)
        else
            @warn "reuseaddr=true may not be supported on this platform: $(Sys.KERNEL)"
            Sockets.bind(tcpserver, inet.host, inet.port; reuseaddr=true)
        end
        Sockets.listen(tcpserver)
    else
        tcpserver = Sockets.listen(inet)
    end
    verbose && @info "Listening on: $host:$port"

    tcpisvalid = let f=tcpisvalid
        x -> f(x) && HTTP.Servers.check_rate_limit(x, rate_limit)
    end

    s = Server(sslconfig, tcpserver, string(host), string(port))
    return HTTP.Servers.listenloop(f, s, tcpisvalid, connection_count,
                         reuse_limit, readtimeout, verbose)
end
