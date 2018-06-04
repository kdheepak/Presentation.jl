# Presentation.jl

[![](https://user-images.githubusercontent.com/1813121/40890475-d49ef4c2-6733-11e8-8c67-7a0b21113022.gif)](https://asciinema.org/a/FONgs1emrdZgtyFMTrihclvYu)

## Installation

```
Pkg.clone("https://github.com/kdheepak/Presentation.jl")
```

## Usage

Add the following to your `~/.juliarc.jl` file.

```
using Presentation
```

Then, open a new file (e.g. `slideshow.jl`), and create a slideshow by creating multiple slides.

```julia

Slide(
"""
# Julia Language Tutorial

- Introduction

...
"""
)

Slide(
"""
# Introduction

- Julia is a high-level dynamic programming language
- Designed to address the needs of high-performance numerical analysis and computational science
    - Example of addition

""", [
    :(1+1)
    ]
)

```

Finally, open the `slideshow.jl` using `julia -i slideshow.jl`.
