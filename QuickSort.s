.data
array: .word 5, 55, 2, 12, 6, 19, 11, 7
.text
.globl main

main:
    li s5, 0               # 0 = roda tudo
    li s0, 0
    la s1, array
    li s2, 8
    li s3, 0
monta_lista:
    bge s3, s2, fim_ml
    li a0, 9
    li a1, 8
    ecall
    mv t0, a0
    lw t1, 0(s1)
    sw t1, 0(t0)
    sw s0, 4(t0)
    mv s0, t0
    addi s1, s1, 4
    addi s3, s3, 1
    j monta_lista
fim_ml:
    li t0, 1
    beq s5, t0, sair

    mv a0, s0
    jal ra, find_last_no
    mv s1, a0
    li t0, 2
    beq s5, t0, sair

    mv a0, s0
    mv a1, s1
    jal ra, quicksort
    li t0, 3
    beq s5, t0, sair

    mv s4, s0
print_loop:
    beqz s4, sair
    li a0, 1
    lw a1, 0(s4)
    ecall
    li a0, 11
    li a1, 32
    ecall
    lw s4, 4(s4)
    j print_loop
sair:
    li a0, 10
    ecall

find_last_no:
    beqz a0, end_find_last
loop_find_last:
    lw t0, 4(a0)
    beqz t0, end_find_last
    mv a0, t0
    j loop_find_last
end_find_last:
    ret

quicksort:
    beqz a0, ret_qs
    beq a0, a1, ret_qs
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)
    mv s0, a0
    mv s1, a1
    jal ra, particiona
    mv s2, a0
    mv s3, a1
    beqz s3, left
    mv a0, s0
    mv a1, s3
    jal ra, quicksort
left:
    beq s2, s1, fim_qs     # <<< CORREÇÃO: pivô é o tail, sem parte direita
    lw a0, 4(s2)
    beqz a0, fim_qs
    mv a1, s1
    jal ra, quicksort
fim_qs:
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20
ret_qs:
    ret

particiona:
    lw t0, 0(a1)
    li t1, 0
    mv t2, a0
loop_particiona:
    beq t2, a1, fim_loop_particiona
    lw t3, 0(t2)
    blt t3, t0, troca_menor
    j proximo_j
troca_menor:
    beqz t1, i_era_nulo
    lw t4, 4(t1)
    mv t1, t4
    j faz_a_troca
i_era_nulo:
    mv t1, a0
faz_a_troca:
    lw t4, 0(t1)
    lw t5, 0(t2)
    sw t5, 0(t1)
    sw t4, 0(t2)
proximo_j:
    lw t2, 4(t2)
    j loop_particiona
fim_loop_particiona:
    beqz t1, pivo_vai_pro_head
    lw t4, 4(t1)
    j coloca_pivo
pivo_vai_pro_head:
    mv t4, a0
coloca_pivo:
    lw t5, 0(t4)
    lw t6, 0(a1)
    sw t6, 0(t4)
    sw t5, 0(a1)
    mv a0, t4
    mv a1, t1
    ret
