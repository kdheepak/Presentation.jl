Presentation.Slide(
"""

# Presentation.jl

- Introduction

- Installation

- REPL

"""
)

Presentation.Slide(
"""

## Introduction

- Allows presenting Julia code from the terminal

- Allows defined predefined code to run

"""
)

Presentation.Slide(
"""

## Installation

- Run `Pkg.add("https://github.com/kdheepak/Presentation.jl")`

- Add `using Presentation` to `~/.juliarc.jl`

- Create slides in `slideshow.jl`

- Run `julia -i slideshow.jl`

"""
)

Presentation.Slide(
"""

## REPL

- Move forward slides by using Ctrl+f

- Move back slides by using Ctrl+b

- Input predefined expressions on a slide by using Ctrl+e

    - Slide(..., [
      :(1+1)
      :(println("hello world"))
      quote
          function add(x, y)
              x+y
          end
      end
      ]
    )


""", [
      :(1+1)
      :(println("hello world"))
      quote
          function add(x, y)
              x+y
          end
      end
     ]
)

