# Welcome

TypeClasses defines general programmatic abstractions taken from Scala cats
and Haskell TypeClasses. Building on top of Traits, you can actually dispatch
on whether a type implements an abstraction or not, which enables
a function to a concretely dispatchable type.

# Current Limitations

Julia's type inference does not work well with nested functions
