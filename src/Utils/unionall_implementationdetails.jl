"""
abstract away too much type detail which may appear due to typeinference by value

Example
```julia
# because the second typeparemeter of Iterable is more like extra information about the value
# this should be unionalled out
unionall_implementationdetails(Iterable{Int, UnitRange{Int}}) == Iterable{Int}
```

Defaults to not changing anything.
Overwrite this if you have complex types with tags or other instance-details.
"""
unionall_implementationdetails(T::Type) = T
