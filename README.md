# Presentation.jl

## Installation

```
Pkg.clone("https://github.com/kdheepak/Presentation.jl")
```

## Usage

```julia
using Presentation
render("/path/to/filename.md")
```

Use `next()` or `previous()` to move between slides.

## Motivation

The motivation was to build a presentation tool that uses the text interface in a Terminal.
I was interested in building it to learn the Julia programming language and to learn about ANSI terminal escape codes.
Other tools exist for this purpose that may solve this problem better.


