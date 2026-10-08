.data
array: .word 5, 55, 2, 12, 6, 19, 11, 7
.text
.globl main

main:
    li s5, 0 # modo de teste: 0 = roda tudo, 1/2/3 = para após a etapa 1/2/3
    li s0, 0 # head (0 = lista vazia)
    la s1, array # ponteiro pro array
    li s2, 8 # tamanho
    li s3, 0 # i
monta_lista:
    bge s3, s2, fim_ml # se i >= tamanho, terminou de montar
    li a0, 9 # ecall 9 (sbrk) no Venus: a0 = número da ecall
    li a1, 8 # "malloc" do nó. 8 bytes, 4 do valor e 4 do próximo
    ecall # endereço do nó novo volta em a0
    mv t0, a0 # novo nó
    lw t1, 0(s1) # array[i]
    sw t1, 0(t0) # valor do nó
    sw s0, 4(t0) # nó.prox = head atual
    mv s0, t0 # head = nó novo
    addi s1, s1, 4 # próximo elemento do array
    addi s3, s3, 1 # i++
    j monta_lista
fim_ml:
    li t0, 1
    beq s5, t0, sair # teste 1: para após montar a lista

    mv a0, s0 # a0 = head
    jal ra, find_last_no # acha o último nó da lista
    mv s1, a0 # tail
    li t0, 2
    beq s5, t0, sair # teste 2: para após achar o tail

    mv a0, s0 # head
    mv a1, s1 # tail
    jal ra, quicksort # ordena a lista
    li t0, 3
    beq s5, t0, sair # teste 3: para após ordenar (sem imprimir)

    mv s4, s0 # s4 = nó atual (começa no head)
print_loop:
    beqz s4, sair # chegou ao fim da lista
    li a0, 1 # ecall 1: imprime inteiro
    lw a1, 0(s4) # valor do nó atual
    ecall
    li a0, 11 # ecall 11: imprime caractere
    li a1, 32 # 32 = espaço
    ecall
    lw s4, 4(s4) # avança para o próximo nó
    j print_loop
sair:
    li a0, 10 # ecall 10: encerra programa
    ecall

# acha o último nó e retorna em a0
find_last_no:
    beqz a0, end_find_last # lista vazia
loop_find_last:
    lw t0, 4(a0) # t0 = próximo do nó atual
    beqz t0, end_find_last # próximo nulo: este é o último
    mv a0, t0 # avança para o próximo nó
    j loop_find_last
end_find_last:
    ret

# a0 = head, a1 = tail da sublista
quicksort:
    beqz a0, ret_qs # sublista vazia
    beq a0, a1, ret_qs # só um nó: já está ordenada
    addi sp, sp, -20 # reserva espaço na pilha
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)
    mv s0, a0 # head
    mv s1, a1 # tail
    jal ra, particiona # retorna a0 = nó do pivô e a1 = anterior ao pivô
    mv s2, a0 # pivô
    mv s3, a1 # anterior ao pivô
    beqz s3, left # sem anterior: não há parte esquerda
    mv a0, s0 # head
    mv a1, s3 # tail da parte esquerda = anterior ao pivô
    jal ra, quicksort
left:
    beq s2, s1, fim_qs # CORREÇÃO: pivô é o tail, sem parte direita
    lw a0, 4(s2) # nó depois do pivô
    beqz a0, fim_qs # sem próximo: não há parte direita
    mv a1, s1 # tail
    jal ra, quicksort
fim_qs:
    lw ra, 16(sp) # restaura registradores
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20 # libera a pilha
ret_qs:
    ret

# a0 = head, a1 = tail
# retorna a0 = nó onde o pivô ficou, a1 = nó anterior ao pivô
particiona:
    lw t0, 0(a1) # t0 = valor do pivô (valor do tail)
    li t1, 0 # t1 = i (último nó < pivô, 0 = nenhum ainda)
    mv t2, a0 # t2 = j (percorre do head até antes do tail)
loop_particiona:
    beq t2, a1, fim_loop_particiona # chegou no tail: fim da varredura
    lw t3, 0(t2) # valor(j)
    blt t3, t0, troca_menor # se valor(j) < pivô, avança i e troca
    j proximo_j
troca_menor:
    beqz t1, i_era_nulo # i ainda não existe
    lw t4, 4(t1)
    mv t1, t4 # i = próximo(i)
    j faz_a_troca
i_era_nulo:
    mv t1, a0 # i = head
faz_a_troca:
    lw t4, 0(t1) # troca valor(i) com valor(j)
    lw t5, 0(t2)
    sw t5, 0(t1)
    sw t4, 0(t2)
proximo_j:
    lw t2, 4(t2) # j = próximo(j)
    j loop_particiona
fim_loop_particiona:
    beqz t1, pivo_vai_pro_head # i = 0: pivô vai pro head
    lw t4, 4(t1) # pos. final do pivô = próximo(i)
    j coloca_pivo
pivo_vai_pro_head:
    mv t4, a0 # pos. final do pivô = head
coloca_pivo:
    lw t5, 0(t4) # troca valor da posição final com o do tail (pivô)
    lw t6, 0(a1)
    sw t6, 0(t4)
    sw t5, 0(a1)
    mv a0, t4 # retorna o nó do pivô
    mv a1, t1 # retorna o anterior ao pivô
    ret
