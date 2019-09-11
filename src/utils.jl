import Base.Libc: strerror

mean(x::Number, y::Number) = (x + y) / 2

const ESC = '\x1B'

# Encoded terminal modes from SSH.jl
const NCCS = Sys.islinux() ? 32 : 20
const tcflag_t = Sys.islinux() ? Cuint : Culong
const speed_t = tcflag_t

mutable struct termios
    c_iflag::tcflag_t
    c_oflag::tcflag_t
    c_cflag::tcflag_t
    c_lflag::tcflag_t
    @static if Sys.islinux()
        c_line::UInt8
    end
    c_cc::NTuple{NCCS, UInt8}
    c_uispeed::speed_t
    c_ospeed::speed_t
end
TERM = Ref{termios}(
                    @static if Sys.islinux() termios(
                            0,
                            0,
                            0,
                            0,
                            0,
                            (Tuple([0 for _ in 1:20])),
                            0,
                            0
                           )
                    else
                                             termios(
                            0,
                            0,
                            0,
                            0,
                            (Tuple([0 for _ in 1:20])),
                            0,
                            0
                           )
                    end
                   );
RESTORE = deepcopy(TERM);

const ICANON = Sys.islinux() ? 0o0000002 : 0x00000100
const ECHO = Sys.islinux()   ? 0o0000010 : 0x00000008
const TCSANOW = 0
const O_RDWR = Base.Filesystem.JL_O_RDWR
const O_NOCTTY = Base.Filesystem.JL_O_NOCTTY
const OS_HANDLE = Base.OS_HANDLE

function getColor(t::Terminals.TTYTerminal)
    fd = ccall(:jl_uv_file_handle, Base.OS_HANDLE, (Ptr{Cvoid},), stdin.handle)
    systemerror("tcgetattr",
                ccall(:tcgetattr, Cint, (Cint, Ptr{Cvoid}), fd, TERM) == -1)
    systemerror("tcgetattr",
                ccall(:tcgetattr, Cint, (Cint, Ptr{Cvoid}), fd, RESTORE) == -1)
    TERM[].c_lflag &= ~(ICANON|ECHO)
    systemerror("tcsetattr",
                ccall(:tcsetattr, Cint, (Cint, Cint, Ptr{Cvoid}), fd, TCSANOW, TERM) == -1
               )
    write(stdout, "\e]11;?\a")
    buf = UInt8[]
    while true
        ch = read(stdin, 1)[1]
        if Char(ch) == ';'
            break
        end
    end
    @assert Char(read(stdin, 1)[1]) == 'r'
    @assert Char(read(stdin, 1)[1]) == 'g'
    @assert Char(read(stdin, 1)[1]) == 'b'
    @assert Char(read(stdin, 1)[1]) == ':'
    r = parse(UInt8, "0x$(String(read(stdin, 2)))")
    @assert Char(read(stdin, 1)[1]) == '/'
    g = parse(UInt8, "0x$(String(read(stdin, 2)))")
    @assert Char(read(stdin, 1)[1]) == '/'
    b = parse(UInt8, "0x$(String(read(stdin, 2)))")
    systemerror("tcsetattr",
                ccall(:tcsetattr, Cint, (Cint, Cint, Ptr{Cvoid}), fd, TCSANOW, RESTORE) == -1
               )

    return r, g, b
end

function getXY(t::Terminals.TTYTerminal)
    fd = ccall(:jl_uv_file_handle, Base.OS_HANDLE, (Ptr{Cvoid},), stdin.handle)
    systemerror("tcgetattr",
                ccall(:tcgetattr, Cint, (Cint, Ptr{Cvoid}), fd, TERM) == -1)
    systemerror("tcgetattr",
                ccall(:tcgetattr, Cint, (Cint, Ptr{Cvoid}), fd, RESTORE) == -1)
    TERM[].c_lflag &= ~(ICANON|ECHO)
    systemerror("tcsetattr",
                ccall(:tcsetattr, Cint, (Cint, Cint, Ptr{Cvoid}), fd, TCSANOW, TERM) == -1
               )
    write(stdout, "$(Terminals.CSI)6n")
    buf = UInt8[]
    while true
        ch = read(stdin, 1)[1]
        if Char(ch) == 'R'
            break
        end
        push!(buf, ch)
    end
    systemerror("tcsetattr",
                ccall(:tcsetattr, Cint, (Cint, Cint, Ptr{Cvoid}), fd, TCSANOW, RESTORE) == -1
               )

    r, c = split(String(buf[3:end]), ";")
    return parse(Int, c), parse(Int, r)
end

abstract type Terminal end
abstract type JPEG end

size(::Type{Terminal}) = Base.displaysize(stdout) |> reverse

function size(::Type{JPEG}, filename)
    fhandle = open(filename)
    seek(fhandle, 0) # Read 0xff next
    size = 2
    ftype = 0
    while ! ( 0xc0 <= ftype <= 0xcf )
        read(fhandle, size)
        byte = read(fhandle, 1)
        while byte[1] == 0xff
            byte = read(fhandle, 1)
        end
        ftype = byte[1]
        size = read(fhandle, 2)[2] - 2
    end
    read(fhandle, 1)
    h1, h2, w1, w2 = read(fhandle, 4)
    return Int(UInt16(w1)<<8 + w2), Int(UInt16(h1)<<8 + h2)
end


canvassize() = size(Terminal)
pos() = pos(TERMINAL)
getXY() = getXY(TERMINAL)
getColor() = getColor(TERMINAL)
getX() = getX(TERMINAL)
getY() = getY(TERMINAL)
getW() = canvassize()[1]
getH() = canvassize()[2]
cmove(x, y) = cmove(TERMINAL, x, y)
clear() = clear(TERMINAL)
cmove_bottom() = cmove(1, getH() - 2)

pos(t::Terminals.TTYTerminal) = (getX(t), getY(t))

function getX(t::Terminals.TTYTerminal)
    x, y = getXY(t)
    return x
end

function getY(t::Terminals.TTYTerminal)
    x, y = getXY(t)
    return y
end

@eval cmove(t::Terminals.TTYTerminal, x::Int, y::Int) = print("$(Terminals.CSI)$(y);$(x)H")
@eval function clear(t::Terminals.TTYTerminal)
    r = getH()
    print("$(Terminals.CSI)$(r);1H")
    print("$(Terminals.CSI)2J")
end

wrap(s) = wrap(s, round(Int, getW() * 3 / 4))

function wrap(s, w::Int)
    length(s) < w && return String[s]
    i = findprev(" ", s, w)
    i = (i == nothing) ? w : i[1]
    first, remaining = s[1:i], s[i+1:end]
    first = first
    remaining = remaining
    return vcat(String[first], wrap(remaining, w))
end


