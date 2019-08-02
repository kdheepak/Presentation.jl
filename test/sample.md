# Presentation.jl

## Presentation.jl is a presentation framework written in Julia for presenting slides in the terminal in interactive manner

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Installation

You can install `Presentation.jl` by using the following command:

```
(v1.1) pkg> add https://github.com/kdheepak/Presentation.jl
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

## Images

Supports images in the terminal

![](../examples/cat.jpg)

## Gifs

And gifs!

![](../examples/pratt.gif)

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

