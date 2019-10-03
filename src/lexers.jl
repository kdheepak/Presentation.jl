
using Highlights.Tokens
using Highlights.Lexers

abstract type PythonLexer <: AbstractLexer end

@lexer PythonLexer let
    Dict(
        :name => "Python",
        :description => "A lexer for Python source code.",
        :aliases => ["python", "py"],
        :filenames => ["*.py"],
        :mimetypes => ["text/x-python", "application/x-python"],
        :tokens => Dict(
            :root => [
                (r"\n"m, TEXT),
                (r"[^\S\n]+"m, TEXT),
                (r"#.*$"m, COMMENT_SINGLE),
                (r"[\[\](),;]", PUNCTUATION),
                # (python_is_symbol, STRING_CHAR),
                (r"\b(?<![_.])in\b", KEYWORD_PSEUDO),
                # (r"\b(?<![_.])end\b", KEYWORD),
                (r"\b(?<![_.])(True|False)\b", KEYWORD_CONSTANT),
                (r"\b(?<![_.])(nonlocal|global)\b", KEYWORD_DECLARATION),
                # (words(keywords, prefix = "\\b(?<![_.])", suffix = "\\b"), KEYWORD),

                # (Regex(join(char_regex)), STRING_CHAR),

                (r"\"\"\"", STRING, :triple_strings),
                (r"\"", STRING, :strings),

                (r"'''", STRING, :triple_strings),
                (r"'", STRING, :strings),

                # (python_is_method_call, NAME_FUNCTION),
                # (python_is_identifier, NAME),
                # (python_is_macro_identifier, NAME_DECORATOR),

                (r"(\d+(_\d+)+\.\d*|\d*\.\d+(_\d+)+)([eEf][+-]?[0-9]+)?", NUMBER_FLOAT),
                (r"(\d+\.\d*|\d*\.\d+)([eEf][+-]?[0-9]+)?", NUMBER_FLOAT),
                (r"\d+(_\d+)+[eEf][+-]?[0-9]+", NUMBER_FLOAT),
                (r"\d+[eEf][+-]?[0-9]+", NUMBER_FLOAT),
                (r"0b[01]+(_[01]+)+", NUMBER_BIN),
                (r"0b[01]+", NUMBER_BIN),
                (r"0o[0-7]+(_[0-7]+)+", NUMBER_OCT),
                (r"0o[0-7]+", NUMBER_OCT),
                (r"0x[a-fA-F0-9]+(_[a-fA-F0-9]+)+", NUMBER_HEX),
                (r"0x[a-fA-F0-9]+", NUMBER_HEX),
                (r"\d+(_\d+)+", NUMBER_INTEGER),
                (r"\d+", NUMBER_INTEGER),

                # (python_is_operator, OPERATOR),

                (r"."ms, TEXT),
            ],
            :strings => [
                (r"\"", STRING, :__pop__),
                (r"\\([\"\\'\$nrbtfav]|(x|u|U)[a-fA-F0-9]+|\d+)", STRING_ESCAPE),
                # (python_is_iterp_identifier, STRING_INTERPOL),
                # (r"(\$)(\()", (STRING_INTERPOL, PUNCTUATION), :in_interpol),
                (r".|\s"ms, STRING),
            ],
            :triple_strings => [
                (r"\"\"\"", STRING, :__pop__),
                (r"\\([\"\\'\$nrbtfav]|(x|u|U)[a-fA-F0-9]+|\d+)", STRING_ESCAPE),
                # (python_is_iterp_identifier, STRING_INTERPOL),
                # (r"(\$)(\()", (STRING_INTERPOL, PUNCTUATION), :in_interpol),
                (r".|\s"ms, STRING),
            ],
            :in_interpol => [
                (r"\(", PUNCTUATION, :__push__),
                (r"\)", PUNCTUATION, :__pop__),
                :root,
            ],
        ),
    )
end

