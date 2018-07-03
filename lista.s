@ arm-none-eabi-as -o lista.o lista.s
@ arm-none-eabi-ld -o lista lista.o
@ ./armsim -l lista -c

.global _start

/*
R0, R1, R2, R7 = reservados para usar o console
R4 = endereço inicial da lista na memória
R3 = auxiliar
R6 = contador de produtos
R8 = recebe o valor do calculo para sabar a posição do produto adicionado
R9 = contador na impreção
R12 = calcula a posição inicial da memória onde vai armazanar os dados
*/

.set endereco, 0x1000

.set opcao_novo_produto, "1"
.set opcao_excluir_produto, "2"
.set opcao_listar_produto, "3"
.set opcao_sair, "0"

.set tam, 35

.equ tamanho_nome_produto,30
.equ tamanho_preco_produto,5
.equ tamanho_nodo, 35
.equ tamanho_opcao_escolhida_menu,1

_start:
	mov r6, #0
	mov r12, #0
	mov r8, #0
 	ldr r8, =tamanho_nodo
	ldr r4, =endereco
	b main

main:
	mov r0, #1
	ldr r1, =menu_inicial
	ldr r2, =tamanho_mensagem_escrita
	mov r7, #4
	svc 0x055

	mov r0, #0
	ldr r1, =tamanho_opcao_escolhida_menu
	ldr r2, =tamanho_opcao_escolhida_menu
	mov r7, #3
	svc	#0x55

	b menu

menu:
	add r5, r5,r1
	add r9, r9,#1

	cmp r1, #1
	beq novo_produto

	cmp r1, #2
	beq excluir_produto

	cmp r1, #3
	beq listar_produtos

	cmp r1, #0
	beq sair

inicializa_novo_nodo:
	ldr r3, [r4, r12]
	add r12, r12, #1
	cmp r12, r8
	blt inicializa_novo_nodo

novo_produto:
  mov r0, #1
  ldr r1, =msg_novo_produto
  ldr r2, =msg_novo_produto_len
  mov r7, #4
  svc 0x055

  mov r0, #1
  ldr r1, =msg_produto_novo_nome
  ldr r2, =msg_produto_novo_nome_len
  mov r7, #4
  svc 0x055

  mov r0, #0
  ldr r1, =tamanho_nome_produto
  ldr r2, =tamanho_nome_produto
  mov r7, #3
  svc #0x55

  str r1, [r4,r12]
  add r12, r12,#tamanho_nome_produto

  mov r0, #1
  ldr r1, =msg_produto_novo_preco
  ldr r2, =msg_produto_novo_preco_len
  mov r7, #4
  svc 0x055

  mov r0, #0
  ldr r1, =tamanho_nome_produto
  ldr r2, =tamanho_preco_produto
  mov r7, #3
  svc #0x55

  str r1, [r4,r12]
  add r12, r12,#tamanho_preco_produto

  mov r0, #1
  ldr r1, =msg_quebra_linha_produto_novo
  ldr r2, =msg_quebra_linha_produto_novo_len
  mov r7, #4
  svc 0x055

	ldr r9, =tamanho_nodo

  mul r8, r6, r9
  mov r0, #1
  ldr r1, [r4,r8]
  ldr r2, =tamanho_nodo
  mov r7, #4
  svc 0x055
  add r6, r6, #1

	cmp r6, #2
	@beq sair
	blt novo_produto

	b listar_produtos

excluir_produto:
	b main

listar_produtos:
	mov r0, #1
	ldr r1, =msg_imprimir_produtos
	ldr r2, =msg_imprimir_produtos_len
	mov r7, #4
	svc 0x055

	mov r0, #1
	ldr r1, =msg_imprimir_produtos_descricao
	ldr r2, =msg_imprimir_produtos_descricao_len
	mov r7, #4
	svc 0x055

	mov r9, #0
	b imprimir

imprimir:
	ldr r10, =#1023
	mov r3, #3
	add r3, r3,r3

	mov r0, #1
	ldr r1, [r4,r8]
	ldr r2, =tamanho_nodo
	mov r7, #4
	svc 0x055

	mov r0, #1
	ldr r1, [r10,r8]
	ldr r2, =tamanho_nodo
	mov r7, #4
	svc 0x055

	add r8, r8, #tamanho_nodo

	b sair

	add r9, r9, #1

	cmp r9,r6
	blt imprimir
	b sair

sair:
	mov r0, #0
	mov r7, #1
	svc #0x055

@ Mensagens e constantes

menu_inicial:
	.ascii "\n(1) Inserir produto\n(2) Excluir\n(3) Listar produtos\n(0) Sair\n"
	tamanho_mensagem_escrita = . - menu_inicial

msg_novo_produto:
  .ascii "\n\nAdicionar novo produto!\n"
  msg_novo_produto_len = . - msg_novo_produto

msg_produto_novo_nome:
  .ascii "\nNome do produto: "
  msg_produto_novo_nome_len = . - msg_produto_novo_nome

msg_produto_novo_preco:
  .ascii "\nPreco do produto: "
  msg_produto_novo_preco_len = . - msg_produto_novo_preco

msg_quebra_linha_produto_novo:
  .ascii "\n\nProduto adicionado: "
  msg_quebra_linha_produto_novo_len = . - msg_quebra_linha_produto_novo

msg_imprimir_produtos:
	.ascii "\nImprimir produtos!\n"
	msg_imprimir_produtos_len =. - msg_imprimir_produtos

msg_imprimir_produtos_descricao:
	.ascii "\nNome                 Preco\n____________________ _____\n"
	msg_imprimir_produtos_descricao_len = . - msg_imprimir_produtos_descricao

msg_excluir:
	.ascii "\nExcluir produto!\n\n"
	tamanho_msg_excluir = . - msg_excluir
