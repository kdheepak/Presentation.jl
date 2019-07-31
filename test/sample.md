# Presentation.jl

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

