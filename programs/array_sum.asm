# =============================================================================
# Program 1: Array Sum
# Description: Computes the sum of a 5-element 32-bit integer array stored
#              in Data Memory at word indices 0 to 4 (byte offsets 0 to 16).
# Input Array:  [3, 1, 4, 1, 5]
# Expected Sum: 14 (0x0000000E) written to Data Memory word index 5 (byte offset 20).
# =============================================================================

# Register Allocation:
#   $t0 ($8)  : Byte offset pointer into array (increments by 4)
#   $t1 ($9)  : Loop iteration counter i (0 to 5)
#   $t2 ($10) : Loop bound N = 5
#   $s0 ($16) : Accumulator / Running sum
#   $t3 ($11) : Current loaded array element
#   $t4 ($12) : Destination address for final result (byte offset 20)

        ADDI $t0, $zero, 0       # $t0 = 0 (byte offset)
        ADDI $t1, $zero, 0       # $t1 = 0 (counter i = 0)
        ADDI $t2, $zero, 5       # $t2 = 5 (array size N = 5)
        ADDI $s0, $zero, 0       # $s0 = 0 (sum = 0)

loop:
        BEQ  $t1, $t2, done      # if (i == N) branch to done
        LW   $t3, 0($t0)         # $t3 = DataMemory[$t0]
        ADD  $s0, $s0, $t3       # sum = sum + $t3
        ADDI $t0, $t0, 4         # $t0 = $t0 + 4 (next word address)
        ADDI $t1, $t1, 1         # i = i + 1
        J    loop                # repeat loop

done:
        ADDI $t4, $zero, 20      # destination address = 20
        SW   $s0, 0($t4)         # DataMemory[20] = sum (14)

end_loop:
        J    end_loop            # Halt trap
