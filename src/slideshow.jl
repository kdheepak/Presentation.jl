
mutable struct SlideShow{T}
    slides::Array{T,1}
    current_slide::Int
    current_expr::Int
end

SlideShow(;
          slides=[],
          current_slide=1,
          current_expr=1
         ) = SlideShow(slides, current_slide, current_expr)


