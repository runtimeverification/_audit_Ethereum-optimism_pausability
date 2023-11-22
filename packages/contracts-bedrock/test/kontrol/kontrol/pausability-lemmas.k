requires "evm.md"
requires "foundry.md"

module PAUSABILITY-LEMMAS
    imports BOOL
    imports FOUNDRY
    imports INFINITE-GAS
    imports INT-SYMBOLIC

    rule A ==Int B +Int C => A -Int C ==Int B [concrete(A, C), simplification, comm]

    rule A ==Int B +Int C => A -Int B ==Int C [concrete(A, B), simplification, comm]

    //
    // Bool
    //

    rule X ==Bool true => X [simplification]
    rule true ==Bool X => X [simplification]

    rule false ==Bool X => notBool X [simplification]
    rule X ==Bool false => notBool X [simplification]

    rule notBool notBool X => X [simplification]

    rule   notBool X ==Bool  notBool Y   =>   X ==Bool  Y   [simplification]
    rule { notBool X #Equals notBool Y } => { X #Equals Y } [simplification]

    rule bool2Word ( X ) => 1 requires X         [simplification]
    rule bool2Word ( X ) => 0 requires notBool X [simplification]

    rule   bool2Word ( X )  ==Int  bool2Word ( Y )   =>   X ==Bool  Y   [simplification]
    rule { bool2Word ( X ) #Equals bool2Word ( Y ) } => { X #Equals Y } [simplification]

    //
    // Bitwise simplifications
    //

    // Commutativity
    rule A &Int B ==Int B &Int A => true [simplification]
    rule A |Int B ==Int B |Int A => true [simplification]

    rule { A &Int B #Equals B &Int A } => #Top [simplification]
    rule { A |Int B #Equals B |Int A } => #Top [simplification]

    // Non-zeroedness of |Int: upstreamed currently has concrete(X)
    rule X |Int _ ==Int 0 => false
      requires 0 <Int X
      [simplification]

    // Moving from &Int to modInt
    rule 1 &Int X => X modInt 2 [simplification]



endmodule
