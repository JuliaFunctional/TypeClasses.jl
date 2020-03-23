using TypeClasses
using Traits
using IsDef

# MonoidAlternative
# =================

@traits function TypeClasses.neutral(::Type{Tuple{A}}) where {A, isNeutral(A)}
  (neutral(A),)
end

@traits function TypeClasses.combine(x::Tuple{A}, y::Tuple{A}) where {A, isCombine(A)}
  (x.:1 ⊕ y.:1,)
end

@traits function TypeClasses.neutral(::Type{Tuple{A,B}}) where {A, B, isNeutral(A), isNeutral(B)}
  (neutral(A), neutral(B))
end

@traits function TypeClasses.combine(x::Tuple{A,B}, y::Tuple{A,B}) where {A, B, isCombine(A), isCombine(B)}
  (x.:1 ⊕ y.:1, x.:2 ⊕ y.:2)
end

@traits function TypeClasses.neutral(::Type{Tuple{A,B,C}}) where {A, B, C, isNeutral(A), isNeutral(B), isNeutral(C)}
  (neutral(A), neutral(B), neutral(C))
end

@traits function TypeClasses.combine(x::Tuple{A,B,C}, y::Tuple{A,B,C}) where {A, B, C, isCombine(A), isCombine(B), isCombine(C)}
  (x.:1 ⊕ y.:1, x.:2 ⊕ y.:2, x.:3 ⊕ y.:3)
end

# TODO create others by macro


@traits function TypeClasses.absorbing(::Type{Tuple{A}}) where {A, isAbsorbing(A)}
  (neutral(A),)
end

@traits function TypeClasses.orelse(x::Tuple{A}, y::Tuple{A}) where {A, isOrElse(A)}
  (x.:1 ⊗ y.:1,)
end

@traits function TypeClasses.absorbing(::Type{Tuple{A,B}}) where {A, B, isAbsorbing(A), isAbsorbing(B)}
  (absorbing(A), absorbing(B))
end

@traits function TypeClasses.orelse(x::Tuple{A,B}, y::Tuple{A,B}) where {A, B, isOrElse(A), isOrElse(B)}
  (x.:1 ⊗ y.:1, x.:2 ⊗ y.:2)
end

@traits function TypeClasses.absorbing(::Type{Tuple{A,B,C}}) where {A, B, C, isAbsorbing(A), isAbsorbing(B), isAbsorbing(C)}
  (absorbing(A), absorbing(B), absorbing(C))
end

@traits function TypeClasses.orelse(x::Tuple{A,B,C}, y::Tuple{A,B,C}) where {A, B, C, isOrElse(A), isOrElse(B), isOrElse(C)}
  (x.:1 ⊗ y.:1, x.:2 ⊗ y.:2, x.:3 ⊗ y.:3)
end

# TODO create others by macro
