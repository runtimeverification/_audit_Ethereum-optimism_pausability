requires "evm.md"
requires "foundry.md"

module PAUSABILITY-LEMMAS
    imports BOOL
    imports FOUNDRY
    imports INFINITE-GAS
    imports INT-SYMBOLIC

rule A ==Int B +Int C => A -Int C ==Int B [concrete(A, C), simplification, comm]

rule A ==Int B +Int C => A -Int B ==Int C [concrete(A, B), simplification, comm]

endmodule
