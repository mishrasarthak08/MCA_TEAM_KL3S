# =============================================================================
# Program 2: Maximum Element Search
# Description: Finds the maximum integer in a 5-element array stored in
#              Data Memory at word indices 0 to 4 (byte offsets 0 to 16).
# Input Array: [7, 2, 11, 4, 9]
# Expected Max: 11 (0x0000000B) written to Data Memory word index 5 (byte offset 20).
# =============================================================================

# Register Allocation:
#   $t0 ($8)  : Byte offset pointer into array
#   $t1 ($9)  : Loop counter i (1 to 5)
#   $t2 ($10) : Loop bound N = 5
#   $s0 ($16) : Current maximum value
#   $t3 ($11) : Current loaded array element
#   $t4 ($12) : Comparison flag (1 if current_max < element, else 0)
#   $t5 ($13) : Target memory address for final maximum (20)

        # 1. Initialize pointer and load first element as initial maximum
        ADDI $t0, $zero, 0       # $t0 = 0 (byte offset 0)
        LW   $s0, 0($t0)         # $s0 = array[0] (7)

        # 2. Initialize loop index and bound
        ADDI $t1, $zero, 1       # i = 1 (start comparison from index 1)
        ADDI $t2, $zero, 5       # N = 5
        ADDI $t0, $t0, 4         # pointer = 4 (address of array[1])

loop:
        BEQ  $t1, $t2, done      # if (i == N) branch to done
        LW   $t3, 0($t0)         # $t3 = array[i]
        SLT  $t4, $s0, $t3       # $t4 = ($s0 < $t3) ? 1 : 0
        BEQ  $t4, $zero, skip    # if (max >= element) skip update
        ADD  $s0, $zero, $t3     # update max: $s0 = $t3

skip:
        ADDI $t0, $t0, 4         # advance pointer to next word
        ADDI $t1, $t1, 1         # i = i + 1
        J    loop                # repeat loop

done:
        ADDI $t5, $zero, 20      # destination address = 20 (word 5)
        SW   $s0, 0($t5)         # DataMemory[20] = maximum (11)

end_loop:
        J    end_loop            # Halt trap
