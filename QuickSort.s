.data
array: .word 5, 55, 2, 12, 6, 19, 11, 7
.text
.globl main

main:
    li s0, 0 # head
    la s1, array # ponteiro pro array
    li s2, 8 # tamanho
    li s3, 0 # i
monta_lista:
    bge s3, s2, fim_ml
    li a0, 8 # "malloc" do nó. 8bytes, 4 do valor e 4 do proximo
    li a7, 9 #syscall 9, aloca memória
    ecall

    mv t0, a0 #novo nó
    lw t1, 0(s1) #array[i]
    sw t1, 0(t0) #valor do nó
    sw s0, 4(t0) #nó.prox = head atual
    mv s0, t0 #head = nó novo

    addi s1, s1, 4
    addi s3, s3, 1
    j monta_lista
fim_ml:
    mv a0, s0
    jal ra, find_last_no #acha ultimo valor da lista
    mv s1, a0 #tail
    mv a0, s0 #head
    mv a1, s1 #tail
    jal ra, quicksort
    li a7, 10 #encerra programa
    ecall

#acha o ultimo nó e retorna em a0
find_last_no:
    beqz a0, end_find_last
loop_find_last:
    lw t0, 4(a0)
    beqz t0,  end_find_last
    mv a0, t0
    j loop_find_last
end_find_last:
    ret

#a0=head, a1=tail
quicksort:
    beqz a0, end_quicksort
    beq a0, a1, end_quicksort

    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)

    mv s0, a0 #head
    mv s1, a1 #tail
    
    jal ra, particiona #retorna, a0=nó do pivo e a1=anterior ao pivo
    mv s2, a0
    mv s3, a1

    beqz s3, left
    mv a0, s0
    mv a1, s3
    jal ra, quicksort
left:
    lw a0, 4(s2) #nó depois do pivo
    beqz a0, right
    mv a1, s1
    jal ra, quicksort
right:
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20
end_quicksort:
    ret

particiona:
    lw t0, 0(a1) #t0 = valor do pivô(valor do tail)
    li t1, 0 #t1 = i (nó confirmado < pivô, 0 = nenhum ainda)
    mv t2, a0 #t2 = j (percorre do head até antes do tail)
loop_particiona:
    beq t2, a1, fim_loop_particiona
    lw t3, 0(t2) #valor(j)
    blt t3, t0, troca_menor #se valor(j) < pivô, avança e troca
    j proximo_j
troca_menor:
    beqz t1, i_era_nulo
    lw t4, 4(t1)
    mv t1, t4 #i = proximo(i)
    j faz_a_troca
i_era_nulo:
    mv t1, a0 #i = head
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
    lw t4, 4(t1) #pos. final do pivô = proximo(i)
    j coloca_pivo
pivo_vai_pro_head:
    mv t4, a0 #pos. final do pivô = head
coloca_pivo:
    lw t5, 0(t4)
    lw t6, 0(a1)
    sw t6, 0(t4)
    sw t5, 0(a1)

    mv a0, t4
    mv a1, t1
    ret