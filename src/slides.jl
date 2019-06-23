
struct Slide
    text::String
    expressions::Array
end

Slide(text) = Slide(text, Array{Expr,1}())



