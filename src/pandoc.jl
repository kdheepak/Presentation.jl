
abstract type Element end

abstract type Inline <: Element end

struct Attributes
    identifier::String
    classes::Vector{String}
    attributes::Vector{Pair}
end

@enum Alignment AlignLeft=1 AlignRight=2 AlignCenter=3 AlignDefault=4
@enum ListNumberStyle DefaultStyle=1 Example=2 Decimal=3 LowerRoman=4 UpperRoman=5 LowerAlpha=6 UpperAlpha=7
@enum ListNumberDelim DefaultDelim=1 Period=2 OneParen=3 TwoParens=4
@enum QuoteType SingleQuote=1 DoubleQuote=2
@enum MathType DisplayMath=1 InlineMath=2
@enum CitationMode AuthorInText=1 SuppressAuthor=2 NormalCitation=3

struct Citation
    mode::CitationMode
    prefix::Vector{Inline}
    hash::Int
    id::String
    suffix::Vector{Inline}
    note_number::Int
end

const Format = String

struct ListAttributes
    number::Int
    style::ListNumberStyle
    delim::ListNumberDelim
end

abstract type Block <: Element end

"""Plain text, not a paragraph"""
struct Plain <: Block
    content:: Vector{Inline}
end

"""Paragraph"""
struct Para <: Block
    content::Vector{Inline}
end

"""Multiple non-breaking lines"""
struct LineBlock <: Block
    content::Vector{Vector{Inline}}
end

"""Code block (literal) with attributes"""
struct CodeBlock <: Block
    attr::Attributes
    content::String
end

"""Raw block"""
struct RawBlock <: Block
    format::Format
    content::String
end

"""Block quote (list of blocks)"""
struct BlockQuote <: Block
    content::Vector{Block}
end

"""Ordered list (attributes and a list of items, each a list of blocks)"""
struct OrderedList <: Block
    attr::ListAttributes
    content::Vector{Vector{Block}}
end

"""Bullet list (list of items, each a list of blocks)"""
struct BulletList <: Block
    content::Vector{Vector{Block}}
end

"""
Definition list Each list item is a pair consisting of a term (a list of inlines) and one or more definitions (each a list of blocks)"""
struct DefinitionList <: Block
    content::Vector{Pair{Vector{Inline}, Vector{Vector{Block}}}}
end

"""Header - level (integer) and text (inlines)"""
struct Header <: Block
    level::Int
    attr::Attributes
    content::Vector{Element}
end

"""Horizontal rule"""
struct HorizontalRule <: Block end

const TableCell = Vector{Block}

"""Table, with caption, column alignments (required), relative column widths (0 = default), column headers (each a list of blocks), and rows (each a list of lists of blocks)"""
struct Table <: Block
    content::Vector{Inline}
    alignments::Vector{Alignment}
    widths::Vector{Float64}
    headers::Vector{TableCell}
    rows::Vector{Vector{TableCell}}
end

"""Generic block container with attributes"""
struct Div <: Block
    attr::Attributes
    content::Vector{Block}
end

struct Null <: Block end

struct Target
    url::String
    title::String
end

"""Text (string)"""
struct Str <: Inline
    content::String
end

"""Emphasized text (list of inlines)"""
struct Emph <: Inline
    content::Vector{Inline}
end

"""Strongly emphasized text (list of inlines)"""
struct Strong <: Inline
    content::Vector{Inline}
end

"""Strikeout text (list of inlines)"""
struct Strikeout <: Inline
    content::Vector{Inline}
end

"""Superscripted text (list of inlines)"""
struct Superscript <: Inline
    content::Vector{Inline}
end

"""Subscripted text (list of inlines)"""
struct Subscript <: Inline
    content::Vector{Inline}
end

"""Small caps text (list of inlines)"""
struct SmallCaps <: Inline
    content::Vector{Inline}
end

"""Quoted text (list of inlines)"""
struct Quoted <: Inline
    quote_type::QuoteType
    content::Vector{Inline}
end

"""Citation (list of inlines)"""
struct Cite <: Inline
    citations::Vector{Citation}
    content::Vector{Inline}
end

"""Inline code (literal)"""
struct Code <: Inline
    attr::Attributes
    content::String
end

"""Inter-word space"""
struct Space <: Inline end
"""Soft line break"""
struct SoftBreak <: Inline end
"""Hard line break"""
struct LineBreak <: Inline end

"""TeX math (literal)"""
struct Math <: Inline
    math_type::MathType
    content::String
end

"""Raw inline"""
struct RawInline <: Inline
    format::Format
    content::String
end

"""Hyperlink: alt text (list of inlines), target"""
struct Link <: Inline
    attr::Attributes
    content::Vector{Inline}
    target::Target
end

"""Image: alt text (list of inlines), target"""
struct Image <: Inline
    attr::Attributes
    content::Vector{Inline}
    target::Target
end

"""Footnote or endnote"""
struct Note <: Inline
    content::Vector{Block}
end

"""Generic inline container with attributes"""
struct Span <: Inline
    attr::Attributes
    content::Vector{Inline}
end


struct Unknown
    e
    t
end

mutable struct Document
    data::Dict{String, Any}
    pandoc_api_version::VersionNumber
    meta::Dict{String, Any}
    blocks::Vector{Element}

    function Document(data)
        pandoc_api_version = VersionNumber(data["pandoc-api-version"][1:end-1]..., (data["pandoc-api-version"][end],))
        meta = data["meta"]
        blocks = get_elements(data["blocks"])
        return new(data, pandoc_api_version, meta, blocks)
    end
end

Base.show(io::IO, e::Element) = print(io, "$(typeof(e))()")
Base.show(io::IO, e::Unknown) = print(io, """$(typeof(e))(
                                        e = $(JSON.json(e.e)),
                                        t = $(e.t),
                                        )""")
Base.show(io::IO, e::Link) = print(io, """Link(
        content = $(e.content),
        target = $(e.target),
    )""")
Base.show(io::IO, e::Header) = print(io, """Header(
        level = $(e.level),
        content = $(e.content),
    )""")
Base.show(io::IO, e::Str) = print(io, """Str("$(e.content)")""")
Base.show(io::IO, e::Emph) = print(io, """Emph($(e.content))""")
Base.show(io::IO, e::Para) = print(io, """Para(
        content = $(e.content),
    )""")
Base.show(io::IO, d::Document) = print(io, """Document(
    version = v$(d.pandoc_api_version),
    blocks = $(d.blocks),
)"""
)

function get_element(e, t)
    u = Unknown(e, t)
    @show u
    return u
end

get_element(e, ::Type{LineBreak}) = LineBreak()
get_element(e, ::Type{HorizontalRule}) = HorizontalRule()
get_element(e, ::Type{Space}) = Space()
get_element(e, ::Type{Str}) = Str(e["c"])

function get_element(e, ::Type{Table})
    c = e["c"]
    println(JSON.json(c, 2))

    content = Inline[get_element(i) for i in c[1]]

    alignments = Alignment[ eval(Symbol(a["t"])) for a in c[2] ]

    widths = Float64[w for w in c[3]]

    headers = TableCell[]
    for blocks in c[4]
        push!(headers, Block[ get_element(b) for b in blocks ])
    end
    rows = Vector{TableCell}[]

    for list_of_blocks in c[5]
        row = TableCell[]
        for blocks in list_of_blocks
            push!(row, Block[ get_element(b) for b in blocks ])
        end
        push!(rows, row)
    end

    return Table(content, alignments, widths, headers, rows)
end

function get_element(e, ::Type{Span})
    return Span(
                Attributes(e["c"][1]...),
                Inline[get_element(i) for i in e["c"][2]]
               )
end

function get_element(e, ::Type{Image})
    attr = Attributes(e["c"][1]...)
    content = Inline[get_element(i) for i in e["c"][2]]
    target = Target(e["c"][3]...)
    return Image(attr, content, target)
end

function get_element(e, ::Type{Strikeout})
    return Strikeout(Inline[get_element(i) for i in e["c"]])
end

function get_element(e, ::Type{SmallCaps})
    return SmallCaps(Inline[get_element(i) for i in e["c"]])
end

function get_element(e, ::Type{Strong})
    return Strong(Inline[get_element(i) for i in e["c"]])
end

function get_element(e, ::Type{DefinitionList})
    c = e["c"]
    dl = Vector{Pair{Vector{Inline}, Vector{Vector{Block}}}}( [] )
    for items in c
        vector_blocks = Vector{Block}[]
        for blocks in items[2]
            push!(Block[get_element(b) for b in blocks])
        end
        inlines = Inline[get_element(i) for i in items[1]]
        push!(dl, (inlines => vector_blocks))
    end
    DefinitionList(dl)
end

function get_element(e, ::Type{BlockQuote})
    blocks = Block[get_element(b) for b in e["c"]]
    return BlockQuote(blocks)
end

function get_element(e, ::Type{ListAttributes})
    number::Int = e[1]
    style::ListNumberStyle = eval(Symbol(e[2]["t"]))
    delim::ListNumberDelim = eval(Symbol(e[3]["t"]))
    return ListAttributes(number, style, delim)
end

function get_element(e, ::Type{OrderedList})
    attr = get_element(e["c"][1], ListAttributes)
    ol = Vector{Block}[]
    for elements in e["c"][2]
        sol = Block[]
        for element in elements
            el = get_element(element)
            push!(sol, el)
        end
        push!(ol, sol)
    end

    return OrderedList(attr, ol)

end

function get_element(e, ::Type{Citation})
    mode = eval(Symbol(e["citationMode"]["t"]))
    prefix = Inline[get_element(i) for i in e["citationPrefix"]]
    hash = e["citationHash"]::Int
    id = e["citationId"]::String
    suffix = Inline[get_element(i) for i in e["citationSuffix"]]
    note_number = e["citationNoteNum"]::Int
    return Citation(mode, prefix, hash, id, suffix, note_number)
end

function get_element(e, ::Type{Cite})
    citations = Citation[get_element(c, Citation) for c in e["c"][1]]
    inlines = Inline[get_element(i) for i in e["c"][2]]
    return Cite(citations, inlines)
end

function get_element(e, ::Type{Code})
    attr = Attributes(e["c"][1]...)
    content = e["c"][2]
    return Code(attr, content)
end

function get_element(e, ::Type{Plain})
    content = Inline[]
    for se in e["c"]
        push!(content, get_element(se))
    end
    return Plain(content)
end

function get_element(e, ::Type{CodeBlock})
    attr = Attributes(e["c"][1]...)
    content = e["c"][2]::String
    return CodeBlock(attr, content)
end

function get_element(e, ::Type{BulletList})
    bl = Vector{Block}[]
    for elements in e["c"]
        sbl = Block[]
        for element in elements
            el = get_element(element)
            push!(sbl, el)
        end
        push!(bl, sbl)
    end
    return BulletList(bl)
end

function get_element(e, t::Type{Emph})
    return Emph(Element[get_element(se) for se in e["c"]])
end

function get_element(e, t::Type{Para})
    return Para(Element[get_element(se) for se in e["c"]])
end

function get_element(e, ::Type{Link})
    c = e["c"]
    identifier = c[1][1]::String
    classes = String[s for s in c[1][2]]
    attributes = Pair[ (String(k) => String(v)) for (k,v) in c[1][3] ]

    content = Element[]
    for se in c[2]
        push!(content, get_element(se))
    end

    target = Target(c[3][1], c[3][2])

    return Link(Attributes(identifier, classes, attributes), content, target)
end

function get_element(e, ::Type{Header})
    c = e["c"]
    level = c[1]::Int
    identifier = c[2][1]::String
    classes = String[s for s in c[2][2]]
    attributes = Pair[ (String(k) => String(v)) for (k,v) in c[2][3] ]

    content = Element[]
    for se in c[3]
        push!(content, get_element(se))
    end

    return Header(level, Attributes(identifier, classes, attributes), content)
end

function get_element(e)
    t = e["t"]
    if t == "Header"
        get_element(e, Header)
    elseif t == "Link"
        get_element(e, Link)
    elseif t == "Space"
        get_element(e, Space)
    elseif t == "Emph"
        get_element(e, Emph)
    elseif t == "Str"
        get_element(e, Str)
    elseif t == "Para"
        get_element(e, Para)
    elseif t == "HorizontalRule"
        get_element(e, HorizontalRule)
    elseif t == "BulletList"
        get_element(e, BulletList)
    elseif t == "Plain"
        get_element(e, Plain)
    elseif t == "Code"
        get_element(e, Code)
    elseif t == "CodeBlock"
        get_element(e, CodeBlock)
    elseif t == "LineBreak"
        get_element(e, LineBreak)
    elseif t == "Cite"
        get_element(e, Cite)
    elseif t == "BlockQuote"
        get_element(e, BlockQuote)
    elseif t == "OrderedList"
        get_element(e, OrderedList)
    elseif t == "DefinitionList"
        get_element(e, DefinitionList)
    elseif t == "Strong"
        get_element(e, Strong)
    elseif t == "SmallCaps"
        get_element(e, SmallCaps)
    elseif t == "Span"
        get_element(e, Span)
    elseif t == "Strikeout"
        get_element(e, Strikeout)
    elseif t == "Image"
        get_element(e, Image)
    elseif t == "Table"
        get_element(e, Table)
    else
        get_element(e, t)
    end
end

function get_elements(blocks)
    elements = Element[]
    for e in blocks
        push!(elements, get_element(e))
    end
    return elements
end

function run_pandoc(filename)
    cmd = `pandoc -t json $filename`
    data = read(cmd, String)
    return Document(JSON.parse(data))
end


