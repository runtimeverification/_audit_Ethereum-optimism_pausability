requires "evm.md"
requires "foundry.md"

module PAUSABILITY-LEMMAS
    imports BOOL
    imports FOUNDRY
    imports INFINITE-GAS
    imports INT-SYMBOLIC
    imports MAP-SYMBOLIC
    imports SET-SYMBOLIC

    syntax StepSort ::= Int
                      | Bool
                      | Bytes
                      | Set
 // ------------------------

    syntax KItem ::= runLemma ( StepSort )
                   | doneLemma( StepSort )
 // --------------------------------------
    rule <k> runLemma(T) => doneLemma(T) ... </k>

    //
    // Arithmetic
    //

    rule ((X up/Int Y) *Int Y) <Int Z => true
      requires X <Int ((Z -Int Y) +Int 1)
      [simplification]

    rule ((X up/Int 32) *Int 32) <Int X => false
      [simplification]

    rule A modInt B => A
      requires 0 <=Int A andBool A <Int B
      [simplification]

    rule   A <=Int B                =>   A  ==Int  B   requires B <=Int A [simplification, concrete(A)]
    rule { A <=Int B #Equals true } => { A #Equals B } requires B <=Int A [simplification, concrete(A)]
    rule { true #Equals A <=Int B } => { A #Equals B } requires B <=Int A [simplification, concrete(A)]

    rule (   A +Int B          ) -Int B => A        [simplification]
    rule ( ( A +Int B ) +Int C ) -Int B => A +Int C [simplification]

    rule ( ( A +Int B ) +Int ( C +Int D ) ) => ( A +Int C +Int ( B +Int D ) ) [simplification, concrete(B, D)]

    rule A +Int B <=Int C +Int D => A <=Int C +Int (D -Int B) requires D >=Int B [simplification(60), concrete(B, D)]
    rule A +Int B <=Int C +Int D => A +Int (B -Int D) <=Int C requires B  <Int D [simplification(60), concrete(B, D)]


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
    // ML
    //

    rule { true  #Equals X     ==K   Y     } => { X #Equals Y } [simplification]
    rule { true  #Equals X:Int ==Int Y:Int } => { X #Equals Y } [simplification]
    rule { false #Equals X     ==K   Y     } => #Not ( { X #Equals Y } ) [simplification]
    rule { false #Equals X:Int ==Int Y:Int } => #Not ( { X #Equals Y } ) [simplification]

    rule { true  #Equals notBool X:Bool } => { false #Equals X } [simplification]
    rule { false #Equals notBool X:Bool } => { true  #Equals X } [simplification]

    rule { X     ==K   Y     #Equals true  } => { X #Equals Y } [simplification]
    rule { X:Int ==Int Y:Int #Equals true  } => { X #Equals Y } [simplification]
    rule { X     ==K   Y     #Equals false } => #Not ( { X #Equals Y } ) [simplification]
    rule { X:Int ==Int Y:Int #Equals false } => #Not ( { X #Equals Y } ) [simplification]

    rule { notBool X:Bool #Equals true  } => { false #Equals X } [simplification]
    rule { notBool X:Bool #Equals false } => { true  #Equals X } [simplification]

    rule #Not ( { X #Equals 0 } ) => { X #Equals 1 } requires #rangeBool ( X ) [simplification]
    rule #Not ( { X #Equals 1 } ) => { X #Equals 0 } requires #rangeBool ( X ) [simplification]

    //
    // &Int
    //

    // Commutativity
    rule   A &Int B  ==Int  B &Int A   => true [simplification, smt-lemma]
    rule { A &Int B #Equals B &Int A } => #Top [simplification]

    // Distributivity of &Int and |Int
    rule A &Int (B |Int C) => (A &Int B) |Int (A &Int C)
    [concrete(A, B), simplification]

    rule A &Int (B |Int C) => (A &Int B) |Int (A &Int C)
    [concrete(A, C), simplification]

    // &Int on non-negative integers remains non-negative
    rule 0 <=Int (X &Int Y) => true
      requires 0 <=Int X
       andBool 0 <=Int Y
      [simplification, smt-lemma]

    // Result of &Int cannot be greater than the operands
    rule (X &Int Y) <=Int Z => true
      requires 0 <=Int X
       andBool 0 <=Int Y
       andBool (X <=Int Z orBool Y <=Int Z)
      [simplification]

    // Anything negative is <Int than &Int
    rule A <Int X &Int Y => true
      requires 0 <=Int X andBool 0 <=Int Y
       andBool A <Int 0
      [simplification, concrete(A)]

    // Deconstruction of (maxUInt &Int ...)
    rule maxUInt8   &Int #asWord ( BA ) => #asWord ( #range(BA, 31,  1) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt16  &Int #asWord ( BA ) => #asWord ( #range(BA, 30,  2) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt24  &Int #asWord ( BA ) => #asWord ( #range(BA, 29,  3) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt32  &Int #asWord ( BA ) => #asWord ( #range(BA, 28,  4) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt40  &Int #asWord ( BA ) => #asWord ( #range(BA, 27,  5) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt48  &Int #asWord ( BA ) => #asWord ( #range(BA, 26,  6) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt56  &Int #asWord ( BA ) => #asWord ( #range(BA, 25,  7) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt64  &Int #asWord ( BA ) => #asWord ( #range(BA, 24,  8) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt72  &Int #asWord ( BA ) => #asWord ( #range(BA, 23,  9) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt80  &Int #asWord ( BA ) => #asWord ( #range(BA, 22, 10) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt88  &Int #asWord ( BA ) => #asWord ( #range(BA, 21, 11) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt96  &Int #asWord ( BA ) => #asWord ( #range(BA, 20, 12) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt104 &Int #asWord ( BA ) => #asWord ( #range(BA, 19, 13) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt112 &Int #asWord ( BA ) => #asWord ( #range(BA, 18, 14) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt120 &Int #asWord ( BA ) => #asWord ( #range(BA, 17, 15) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt128 &Int #asWord ( BA ) => #asWord ( #range(BA, 16, 16) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt136 &Int #asWord ( BA ) => #asWord ( #range(BA, 15, 17) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt144 &Int #asWord ( BA ) => #asWord ( #range(BA, 14, 18) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt152 &Int #asWord ( BA ) => #asWord ( #range(BA, 13, 19) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt160 &Int #asWord ( BA ) => #asWord ( #range(BA, 12, 20) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt168 &Int #asWord ( BA ) => #asWord ( #range(BA, 11, 21) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt176 &Int #asWord ( BA ) => #asWord ( #range(BA, 10, 22) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt184 &Int #asWord ( BA ) => #asWord ( #range(BA,  9, 23) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt192 &Int #asWord ( BA ) => #asWord ( #range(BA,  8, 24) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt200 &Int #asWord ( BA ) => #asWord ( #range(BA,  7, 25) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt208 &Int #asWord ( BA ) => #asWord ( #range(BA,  6, 26) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt216 &Int #asWord ( BA ) => #asWord ( #range(BA,  5, 27) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt224 &Int #asWord ( BA ) => #asWord ( #range(BA,  4, 28) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt232 &Int #asWord ( BA ) => #asWord ( #range(BA,  3, 29) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt240 &Int #asWord ( BA ) => #asWord ( #range(BA,  2, 30) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt248 &Int #asWord ( BA ) => #asWord ( #range(BA,  1, 31) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule maxUInt256 &Int #asWord ( BA ) => #asWord ( #range(BA,  0, 32) ) requires lengthBytes(BA) ==Int 32 [simplification]

    // Deconstruction of (notMaxUInt &Int ...)
    rule notMaxUInt8   &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 31) +Bytes #buf (  1, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt16  &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 30) +Bytes #buf (  2, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt32  &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 28) +Bytes #buf (  4, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt64  &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 24) +Bytes #buf (  8, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt96  &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 20) +Bytes #buf ( 12, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt128 &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 16) +Bytes #buf ( 16, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt160 &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 12) +Bytes #buf ( 20, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt192 &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 8)  +Bytes #buf ( 24, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt208 &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 6)  +Bytes #buf ( 26, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt224 &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 4)  +Bytes #buf ( 28, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt240 &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 2)  +Bytes #buf ( 30, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]
    rule notMaxUInt248 &Int #asWord ( BA ) => #asWord ( #range(BA, 0, 1)  +Bytes #buf ( 31, 0 ) ) requires lengthBytes(BA) ==Int 32 [simplification]

    // Irrelevance of lower bits
    rule notMaxUInt8   &Int (X |Int (maxUInt8   &Int _)) => notMaxUInt8   &Int X [simplification]
    rule notMaxUInt16  &Int (X |Int (maxUInt16  &Int _)) => notMaxUInt16  &Int X [simplification]
    rule notMaxUInt32  &Int (X |Int (maxUInt32  &Int _)) => notMaxUInt32  &Int X [simplification]
    rule notMaxUInt64  &Int (X |Int (maxUInt64  &Int _)) => notMaxUInt64  &Int X [simplification]
    rule notMaxUInt96  &Int (X |Int (maxUInt96  &Int _)) => notMaxUInt96  &Int X [simplification]
    rule notMaxUInt128 &Int (X |Int (maxUInt128 &Int _)) => notMaxUInt128 &Int X [simplification]
    rule notMaxUInt160 &Int (X |Int (maxUInt160 &Int _)) => notMaxUInt160 &Int X [simplification]
    rule notMaxUInt192 &Int (X |Int (maxUInt192 &Int _)) => notMaxUInt192 &Int X [simplification]
    rule notMaxUInt208 &Int (X |Int (maxUInt208 &Int _)) => notMaxUInt208 &Int X [simplification]
    rule notMaxUInt224 &Int (X |Int (maxUInt224 &Int _)) => notMaxUInt224 &Int X [simplification]
    rule notMaxUInt240 &Int (X |Int (maxUInt240 &Int _)) => notMaxUInt240 &Int X [simplification]
    rule notMaxUInt248 &Int (X |Int (maxUInt248 &Int _)) => notMaxUInt248 &Int X [simplification]

    // &Int yields zero for notMax and operand in appropriate range
    rule [bitwise-and-zero]:
      X &Int Y => 0
      requires 0 <=Int X
       andBool pow256 -Int X ==Int 2 ^Int log2Int(pow256 -Int X)
       andBool 0 <=Int Y andBool Y <Int 2 ^Int log2Int(pow256 -Int X)
       [concrete(X), simplification, comm]

    // Deconstruction of <<Int into #buf
    rule X <<Int Y => #asWord ( #buf ( 32 -Int (Y /Int 8) , X ) +Bytes #buf ( Y /Int 8 , 0 ) )
      requires 0 <=Int X andBool X <Int 2 ^Int (256 -Int Y)
       andBool 0 <=Int Y andBool Y <=Int 256 andBool Y modInt 8 ==Int 0
      [simplification, concrete(Y)]

    rule 0 <=Int (X &Int Y) +Int Z => true
      requires 0 <=Int X &Int Y
       andBool 0 <=Int Z
      [simplification]

    rule Z <Int X &Int Y => false
      requires #rangeUInt(256, X)
       andBool #rangeUInt(256, Y)
       andBool #rangeUInt(256, Z)
       andBool ((Y <Int Z) orBool (X <Int Z))
      [simplification]

    rule X &Int Y <Int Z => true
      requires #rangeUInt(256, X)
       andBool #rangeUInt(256, Y)
       andBool #rangeUInt(256, Z)
       andBool ((Y <Int Z) orBool (X <Int Z))
      [simplification]

    rule X &Int #asWord ( _Y +Bytes Z ) => X &Int #asWord ( Z )
      requires X <Int 2 ^Int (8 *Int lengthBytes(Z))
      [concrete(X, Z), simplification]

    rule X &Int #asWord ( _ +Bytes Z ) >>Int T => X &Int #asWord ( Z ) >>Int T
      requires X <Int 2 ^Int (8 *Int lengthBytes(Z) -Int T)
      [concrete(X, Z, T), simplification]

    // Moving from &Int to modInt
    rule 1 &Int X => X modInt 2 [simplification]

    //
    // |Int
    //

    // Commutativity
    rule   A |Int B  ==Int  B |Int A   => true [simplification, smt-lemma]
    rule { A |Int B #Equals B |Int A } => #Top [simplification]

    // Non-zeroedness of |Int
    rule X |Int _ ==Int 0 => false
      requires 0 <Int X
      [simplification]

    // |Int distributivity over #asWord and +Bytes, v1
    rule A |Int #asWord ( BA1 +Bytes BA2 ) =>
      #asWord ( BA1 +Bytes #buf ( lengthBytes(BA2), A |Int #asWord ( BA2 ) ) )
      requires A <Int 2 ^Int (8 *Int lengthBytes(BA2))
      [concrete(A), simplification]

    // |Int distributivity over #asWord and +Bytes, v2
    rule A |Int #asWord ( BA1 +Bytes BA2 ) =>
      #asWord (
        #buf ( lengthBytes(BA1), (A >>Int (8 *Int lengthBytes(BA2))) |Int #asWord ( BA1 ) )
        +Bytes
        #buf ( lengthBytes(BA2), (A modInt (2 ^Int (8 *Int lengthBytes(BA2)))) |Int #asWord ( BA2 ) )
      )
      requires 0 <=Int A
      [simplification(40), concrete(A, BA1)]

    // Prepend 4 bytes (used for function selectors)
    rule A |Int #asWord ( BUF ) => #asWord ( #range ( #buf ( 32 , A ) , 0 , 4 ) +Bytes BUF )
        requires notMaxUInt224 &Int A ==Int A
         andBool lengthBytes ( BUF ) ==Int 28
        [simplification, concrete(A)]

    // Irrelevance of lower bits for >>Int
    rule (X |Int Y) >>Int Z => X >>Int Z
      requires 0 <=Int Z
       andBool 0 <=Int Y andBool Y <Int 2 ^Int Z
       andBool X &Int (maxUInt256 -Int (2 ^Int Z -Int 1)) ==Int X
      [simplification, concrete(Z)]

    //
    // xorInt
    //

    // Commutativity
    rule   A xorInt B  ==Int  B xorInt A   => true [simplification, smt-lemma]
    rule { A xorInt B #Equals B xorInt A } => #Top [simplification]

    // Non-negativity of xorInt
    rule [bitwise-xor-geq-zero]:
      0 <=Int (A xorInt B) => true
      requires 0 <=Int A andBool 0 <=Int B
      [simplification]

    // xorInt
    rule [bitwise-xor-lt-pow256]:
      (A xorInt B) <Int pow256 => true
      requires 0 <=Int A andBool A <Int pow256
       andBool 0 <=Int B andBool B <Int pow256
      [simplification]

    // xor in terms of -Int
    rule X xorInt maxUInt256 => maxUInt256 -Int X
      requires #rangeUInt ( 256 , X )
      [simplification]

    //
    // Sets
    //

    // Empty sets has no elements
    rule _ in .Set => false [simplification]

    rule { true  #Equals _ in .Set} => #Bottom [simplification]
    rule { false #Equals _ in .Set} => #Top    [simplification]

    // Set membership element-by-elemnent deconstruction
    rule X in SetItem ( Y ) S:Set =>
           ( X  ==K Y andBool notBool (X in S) ) orBool
           ( X =/=K Y andBool          X in S  ) [simplification]

    rule X in S1:Set |Set S2:Set => (X in S1) orBool (X in S2)
      [simplification]

    rule S:Set |Set SetItem(X) => S
      requires X in S
      [simplification]

    //
    // Arithmetic
    //

    // Cancellativity #1
    rule A +Int B -Int B +Int C => A +Int C [simplification]

    // Cancellativity #2
    rule A -Int B +Int C -Int D +Int B +Int E => A -Int D +Int C +Int E [simplification]

    // Cancellativity #3
    rule ( A +Int B ) +Int C <=Int ( D +Int B ) +Int E => A +Int C <=Int D +Int E [simplification]

    // Cancellativity #4
    rule A +Int B <=Int ( A +Int C ) +Int D => B <=Int C +Int D [simplification]

    // Distributivity of minInt against +Int
    rule minInt ( A:Int +Int B:Int, C:Int +Int B:Int ) => minInt ( A, C ) +Int B [simplification]

    // Definition of maxInt
    rule maxInt(I1:Int, I2:Int) => I2 requires I1 <=Int I2 [simplification]
    rule maxInt(I1:Int, I2:Int) => I1 requires I1  >Int I2 [simplification]

    // Maximum is not greater than if both operands are not greater than
    rule maxInt(A:Int, B:Int) <=Int X:Int => A <=Int X andBool B <=Int X [simplification]

    // Cutting impossible branches
    rule { A:Int #Equals B:Int *Int X:Int +Int C:Int } => #Bottom
      requires A  <Int C
       andBool 0 <=Int B
       andBool 0 <=Int X
       [simplification]

    // Custom distributivity simplification
    rule 32 *Int ( A:Int +Int B:Int ) => 32 *Int A +Int 32 *Int B
      [simplification]

    // Matching resolutions

    rule { 32 *Int A:Int +Int X:Int #Equals 32 *Int B:Int +Int Y:Int } =>
         { B #Equals A +Int 1 }
         requires X -Int Y ==Int 32
         [simplification]

    rule { A:Int *Int X:Int +Int B #Equals A *Int Y:Int +Int B } =>
         { X #Equals Y }
         requires A =/=Int 0
         [simplification]

    rule { B #Equals A *Int Y:Int +Int B } =>
         { 0 #Equals Y }
         requires A =/=Int 0
         [simplification]

    // Chop custom simplification
    rule chop ( lengthBytes ( X ) +Int 115792089237316195423570985008687907853269984665640564039457584007913129640009 ) =>
         lengthBytes ( X ) +Int 73
         [simplification]

    // Chop custom simplification
    rule 0 ==Int chop (A:Int +Int B:Int) => A ==Int pow256 -Int B
      requires 0 <Int B
       andBool #rangeUInt(256, A)
       [concrete(B), simplification]

    rule { 0 #Equals chop (A:Int +Int B:Int) } => { A #Equals pow256 -Int B }
      requires 0 <Int B
       andBool #rangeUInt(256, A)
       [concrete(B), simplification]

    // Extremely specialised simplification
    rule A ==Int B => true
      requires 32 *Int A -Int 9 <Int 32 *Int B +Int 23
       andBool 32 *Int B -Int 9 <Int 32 *Int A +Int 23
      [simplification, smt-lemma]

    // FIXME: This should be provable by SMT but isn't
    rule 0 ==Int X -Int #asWord ( #range ( _ , _ , Y ) ) *Int Z => false
      requires ( 2 ^Int (Y *Int 8) ) *Int Z <Int X
      [concrete(X, Y), simplification]

    rule { 0 #Equals X -Int #asWord ( #range ( _ , _ , Y ) ) *Int Z } => #Bottom
      requires ( 2 ^Int (Y *Int 8) ) *Int Z <Int X
      [concrete(X, Y), simplification]

    // Range bit-shift arithmetic
    rule 0 <=Int (A <<Int X) => true
      requires 0 <=Int A
       andBool 0 <=Int X
      [simplification]

    // Lukso-specific bit-shift arithmetic
    rule pow96 <=Int (A <<Int 96) => true
      requires 0 <=Int A
      [simplification]

    // Range bit-shift arithmetic
    rule (A <<Int X) <Int pow256 => true
      requires A <Int 2 ^Int (256 -Int X)
      [simplification]

    //
    // Specialised chop-range
    //

    rule A <=Int B +Int C => true
      requires A <=Int 0
       andBool 0 <=Int B
       andBool 0 <=Int C
       [simplification, concrete(A)]

    rule A +Int B <Int C => true
      requires A <Int C /Int 2
       andBool B <Int C /Int 2
       [simplification, concrete(C)]

    rule A <Int B +Int C => true
      requires A <=Int 0
       andBool 0 <=Int B andBool 0 <=Int C
       andBool (0 <Int B  orBool 0 <Int C)
       [simplification, concrete(A)]

    //
    // Bytes
    //

    rule BA1:Bytes ==K BA2:Bytes => false
      requires lengthBytes(BA1) =/=Int lengthBytes(BA2)
      [simplification]

    rule _ +Bytes A ==K _ +Bytes B => false
        requires lengthBytes ( A ) ==Int lengthBytes ( B )
         andBool A =/=K B
        [simplification, concrete(A, B)]

    rule A1 +Bytes B1 ==K A2 +Bytes B2 => false
      requires #range(A1, 0, minInt(lengthBytes(A1), lengthBytes(A2)))
                 =/=K
               #range(A2, 0, minInt(lengthBytes(A1), lengthBytes(A2)))
       andBool lengthBytes(A1 +Bytes B1) ==Int lengthBytes(A2 +Bytes B2)
      [concrete(A1, A2), simplification]

    rule A +Bytes (B +Bytes C) => (A +Bytes B) +Bytes C
      [concrete(A, B), simplification]

    rule (A +Bytes B) +Bytes C => A +Bytes (B +Bytes C)
      [concrete(B, C), simplification]

    rule A +Bytes (B +Bytes C) +Bytes D => (A +Bytes B) +Bytes C +Bytes D
      [concrete(A, B), simplification]

    rule (A +Bytes B) +Bytes (C +Bytes D) => A +Bytes (B +Bytes C) +Bytes D
      [concrete(B, C), simplification]

    //
    // lengthBytes
    //

    // Empty Bytes
    rule lengthBytes ( X ) <=Int 0 => X ==K .Bytes
      [simplification]

    // Interaction between lengthBytes and slicing
    rule lengthBytes(#range(_, S, W)) => maxInt(0, W)
      requires 0 <=Int S
      [simplification(60)]

    // Safe hypothesis: any Bytes is of size at most 2^63 - 1
    rule lengthBytes(_:Bytes) <Int 9223372036854775808 => true [simplification, smt-lemma]

    // Size of paddings
    rule lengthBytes ( padRightBytes ( BA:Bytes, WIDTH, _ ) ) =>
      lengthBytes(BA) +Int WIDTH
      requires 0 <=Int WIDTH
      [simplification]

    // Upper bound on (pow256 - 32) &Int lengthBytes(X)
    rule notMaxUInt5 &Int Y <=Int Y => true
      requires 0 <=Int Y
      [simplification]

    // Lower bound on (pow256 - 32) &Int lengthBytes(X) +Int 31
    rule lengthBytes(X) <=Int notMaxUInt5 &Int lengthBytes(X) +Int 31 => true
      [simplification]

    // Upper bound on (pow256 - 32) &Int lengthBytes(X) +Int 31
    rule lengthBytes(X) +Int 32 >Int notMaxUInt5 &Int lengthBytes(X) +Int 31 => true
      [simplification]

    // Specialised simplification
    rule notMaxUInt5 &Int ( notMaxUInt5 &Int lengthBytes ( VV6__data_3c5818c8:Bytes ) +Int 31 ) +Int 63 => ( notMaxUInt5 &Int lengthBytes ( VV6__data_3c5818c8:Bytes ) +Int 31 ) +Int 32
      [simplification]

    //
    // #buf
    //

    // Invertibility of #buf and #asWord
    rule #buf ( WIDTH , #asWord ( BA:Bytes ) ) => BA
      requires lengthBytes(BA) ==K WIDTH
      [simplification]

    // Local injectivity for 8 bits
    rule { #buf ( 8 , A:Int ) #Equals #buf ( 8 , B:Int ) } => { A #Equals B }
    requires 0 <=Int A andBool A <Int pow64
     andBool 0 <=Int B andBool B <Int pow64
     [simplification]

    // Local injectivity for 32 bits
    rule { #buf ( 32 , A:Int ) #Equals #buf ( 32 , B:Int ) } => { A #Equals B }
    requires 0 <=Int A andBool A <Int pow256
     andBool 0 <=Int B andBool B <Int pow256
     [simplification]

    rule { #buf ( N, X ) #Equals #buf ( N, Y ) } => { X #Equals Y }
      requires 0 <=Int N
       andBool 0 <=Int X
       andBool 0 <=Int Y
       andBool X <Int 2 ^Int ( 8 *Int N )
       andBool Y <Int 2 ^Int ( 8 *Int N )
      [concrete(N), simplification]

    rule #buf ( N, X ) ==K #buf ( N, Y ) => X ==Int Y
      requires 0 <=Int N
       andBool 0 <=Int X
       andBool 0 <=Int Y
       andBool X <Int 2 ^Int ( 8 *Int N )
       andBool Y <Int 2 ^Int ( 8 *Int N )
      [concrete(N), simplification]

    //
    // #asWord
    //

    // Move to function parameters
    rule { #asWord ( X ) #Equals #asWord ( Y ) } => #Top
      requires X ==K Y
      [simplification]

    // Bounds: inherited from KEVM with smt-lemma
    rule 0 <=Int #asWord(_BA)             => true [simplification, smt-lemma]
    rule         #asWord(_BA) <Int pow256 => true [simplification, smt-lemma]

    // Invertibility of #buf with #asWord
    rule #buf ( 32 , #asWord ( X ) ) => X requires lengthBytes ( X ) ==Int 32 [simplification]
    rule #asWord ( #buf ( 32 , X ) ) => X requires #rangeUInt ( 256 , X )     [simplification]

    // #asWord ignores leading zeros
    rule #asWord ( BA1 +Bytes BA2 ) => #asWord ( BA2 )
      requires #asInteger(BA1) ==Int 0
      [simplification, concrete(BA1)]

    // <Int via ByteArray length
    rule #asWord ( BA ) <Int X => true
        requires lengthBytes( BA ) <=Int log2Int( X ) divInt 8
        [simplification, concrete(X)]

    // #asWord is not equal to the target if the leading bytes alone are greater than the target
    // or the trailing bytes are smaller than the difference between the target and leading bytes
    rule #asWord ( BA1 +Bytes BA2 ) ==Int X => false
      requires #asWord ( BA1 ) <<Int ( 8 *Int lengthBytes(BA2) ) >Int X
        orBool X -Int #asWord ( BA1 ) <<Int ( 8 *Int lengthBytes(BA2) ) >=Int 2 ^Int ( 8 *Int lengthBytes(BA2) )
      [simplification(40), concrete(BA1)]

    // #asWord is not smaller-or-equal to the target if the leading bytes alone are greater than the target
    rule #asWord ( BA1 +Bytes BA2 ) <=Int X => false
      requires #asWord ( BA1 ) <<Int ( 8 *Int lengthBytes(BA2) ) >Int X
      [simplification, concrete(BA1)]

    // #asWord is smaller-or-equal to the target if the trailing bytes are smaller than the difference between the target and leading bytes
    rule #asWord ( BA1 +Bytes BA2 ) <=Int X => true
      requires X -Int #asWord ( BA1 ) <<Int ( 8 *Int lengthBytes(BA2) ) >=Int 2 ^Int ( 8 *Int lengthBytes(BA2) ) -Int 1
      [simplification, concrete(BA1)]

    // and otherwise is not smaller-or-equal
    rule #asWord ( BA1 +Bytes BA2 ) <=Int X => false
         requires X <Int ( #asWord ( BA1 ) <<Int (8 *Int lengthBytes(BA2)) )
         [concrete(BA1), simplification]

    // Similar for greater-or-equal
    rule X <=Int #asWord ( BA1 +Bytes BA2 ) => true
      requires lengthBytes( BA1 +Bytes BA2 ) ==Int 32
       andBool X <=Int #asWord( BA1 ) <<Int (8 *Int lengthBytes(BA2))
      [concrete(BA1, X), simplification]

    // and smaller
    rule #asWord ( BA1 +Bytes BA2 ) <Int X => true
      requires lengthBytes( BA1 +Bytes BA2) ==Int 32
       andBool X -Int #asWord( BA1 ) <<Int ( 8 *Int lengthBytes(BA2) ) >Int 2 ^Int ( 8 *Int lengthBytes(BA2) ) -Int 1
      [concrete(BA1, X), simplification]

    // and greater
    rule X <Int #asWord ( BA1 +Bytes BA2 ) => true
      requires lengthBytes( BA1 +Bytes BA2 ) ==Int 32
       andBool X <Int #asWord( BA1 ) <<Int (8 *Int lengthBytes(BA2))
      [concrete(BA1, X), simplification]

    // Leveraging concreteness in #asWord equality
    rule #asWord ( A +Bytes B ) ==Int C:Int =>
      #asWord(B) ==Int C -Int ( #asWord(A) *Int (2 ^Int lengthBytes(B) ) )
      [concrete(A, C), simplification, comm]

    rule { #asWord ( A +Bytes B ) #Equals C } =>
      { #asWord(B) #Equals C -Int ( #asWord(A) *Int (2 ^Int lengthBytes(B) ) ) }
      [concrete(A, C), simplification, comm]

    rule #asWord ( A +Bytes B ) ==Int C:Int =>
      C -Int #asWord(B) ==Int #asWord(A) *Int (2 ^Int lengthBytes(B))
      [concrete(B, C), simplification, comm]

    rule { #asWord ( A +Bytes B ) #Equals C:Int } =>
      { C -Int #asWord(B) #Equals #asWord(A) *Int (2 ^Int lengthBytes(B)) }
      [concrete(B, C), simplification, comm]

    // Equality and #range
    rule #asWord ( #range ( #buf ( 32 , _X:Int ) , S:Int , W:Int ) ) ==Int Y:Int => false
        requires S +Int W <=Int 32
         andBool (2 ^Int (8 *Int W)) <=Int Y
        [concrete(S, W, Y), simplification]

    //
    // #padRightToWidth
    //

    rule #padRightToWidth (W, X) => X +Bytes #buf(W -Int lengthBytes(X), 0)
      [concrete(W), simplification]

    //
    // #range(M, START, WIDTH)
    //

    // Parameter equality
    rule { #range (A, B, C) #Equals #range (A, B, D) } => #Top
      requires C ==Int D
      [simplification]

    //
    // Infinite gas
    //

    rule                  _ <=Gas #gas(_) -Gas _:Int => true  [simplification]
    rule #gas(_) -Gas _:Int  <Gas              _:Int => false [simplification]

    rule Cgascap(SCHED, GCAP, GAVAIL, GEXTRA) => minInt(#allBut64th(GAVAIL -Int GEXTRA), GCAP)
      requires GAVAIL >=Int GEXTRA
       andBool notBool Gstaticcalldepth << SCHED >>
       [simplification]

    rule Cgascap(SCHED, GCAP, GAVAIL, GEXTRA) => GCAP
      requires GAVAIL <Int GEXTRA
        orBool Gstaticcalldepth << SCHED >>
        [simplification]

    //
    // #memoryUsageUpdate
    //

    rule { #memoryUsageUpdate ( A , B , C ) #Equals #memoryUsageUpdate ( D , E , F ) } => #Top
      requires A ==Int D andBool B ==Int E andBool C ==Int F
      [simplification]

    //
    // #lookup
    //

    rule #lookup(.Map, _) => 0
      [simplification]

    rule #lookup(M:Map, X:Int) => 0
      requires notBool (X:Int in keys(M):Set)
      [simplification]

    rule #lookup(M:Map [K:Int <- _], X:Int) => #lookup(M, X)
      requires X =/=Int K
      [simplification]

    rule #lookup((K:Int |-> _) M:Map, X:Int) => #lookup(M, X)
      requires X =/=Int K
      [simplification]

    rule keys(M [ K <- _ ]) => keys(M) |Set SetItem(K)
      [simplification]

    //
    // keccak
    //

    rule 0 <=Int keccak( _ )             => true [simplification, smt-lemma]
    rule         keccak( _ ) <Int pow256 => true [simplification, smt-lemma]

    // keccak does not equal a concrete value
    rule [keccak-eq-conc-false]: keccak(_A)  ==Int _B => false [symbolic(_A), concrete(_B), simplification, comm]
    rule [keccak-neq-conc-true]: keccak(_A) =/=Int _B => true  [symbolic(_A), concrete(_B), simplification, comm]

    rule [keccak-eq-conc-false-ml]: { keccak(_A) #Equals _B } => #Bottom [symbolic(_A), concrete(_B), simplification, comm]

    // corollary of `keccak-eq-conc-false`
    rule [keccak-eq-conc-false-extended]:
      ( ( keccak ( _X ) +Int A ) modInt pow256 ) ==Int _Y => false
      requires 0 <Int A andBool A <Int pow256
      [simplification, symbolic(_X), concrete(A, _Y)]

    // keccak is injective
    rule [keccak-inj]: keccak(A) ==Int keccak(B) => A ==K B [simplification]

    // keccak has no "fixpoint"
    rule [keccak-no-fix-eq-false]: #buf(32, keccak(X))  ==K X => false [simplification]
    rule [keccak-no-fix-neq-true]: #buf(32, keccak(X)) =/=K X => true  [simplification]

    // disequality of keccak under shifting
    rule ( ( keccak ( _X ) +Int A ) modInt pow256 ) ==Int keccak ( _Y ) => false
      requires 0 <Int A andBool A <Int pow256
      [simplification, symbolic(_X, _Y), concrete(A)]

    // chop of negative keccak
    rule chop (0 -Int keccak(BA)) => pow256 -Int keccak(BA)
        [simplification]

    // keccak cannot equal a number outside of its range
    rule { X #Equals keccak (_) } => #Bottom
      requires X <Int 0 orBool X >=Int pow256
      [concrete(X), simplification]

    // Your lemmas go here
    rule A ==Int B +Int C => A -Int C ==Int B [concrete(A, C), simplification, comm]
    rule A ==Int B +Int C => A -Int B ==Int C [concrete(A, B), simplification, comm]

endmodule
