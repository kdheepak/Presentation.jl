# Presentation.jl

# Presentation.jl is a presentation framework written in Julia for presenting slides in the terminal in interactive manner

## Installation

You can install `Presentation.jl` by using the following command:

```
(v1.1) pkg> add Presentation
```

## Syntax highlighting for Julia code

```julia

# function to calculate the volume of a sphere
function sphere_vol(r)
    # julia allows Unicode names (in UTF-8 encoding)
    # so either "pi" or the symbol π can be used
    return 4/3*pi*r^3
end

# functions can also be defined more succinctly
quadratic(a, sqr_term, b) = (-b + sqr_term) / 2a

```

## Display images in the terminal

![](../examples/cat.jpg)

## Bulleted list

This is a list of items:

- Item 1
    - Sub Item 1
        - Sub sub item 1
        - Sub sub item 2
    - Sub Item 2
- Item 2
- Item 3

## Numbered list

This is a list of items:

1. Item 1
    1. Sub Item 1
2. Item 2
3. Item 3

## Links

This is a [link](https://github.com/kdheepak/Presentation.jl) to the repository.

