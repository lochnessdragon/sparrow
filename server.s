	.file	"server.c"
	.text
	.globl	tpool_work_create
	.type	tpool_work_create, @function
tpool_work_create:
.LFB5:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	cmpq	$0, -24(%rbp)
	jne	.L2
	movl	$0, %eax
	jmp	.L3
.L2:
	movl	$24, %edi
	call	malloc@PLT
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	-24(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-8(%rbp), %rax
	movq	-32(%rbp), %rdx
	movq	%rdx, 8(%rax)
	movq	-8(%rbp), %rax
	movq	$0, 16(%rax)
	movq	-8(%rbp), %rax
.L3:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	tpool_work_create, .-tpool_work_create
	.globl	tpool_work_destroy
	.type	tpool_work_destroy, @function
tpool_work_destroy:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L7
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	jmp	.L4
.L7:
	nop
.L4:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	tpool_work_destroy, .-tpool_work_destroy
	.globl	tpool_work_get
	.type	tpool_work_get, @function
tpool_work_get:
.LFB7:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	cmpq	$0, -24(%rbp)
	jne	.L9
	movl	$0, %eax
	jmp	.L10
.L9:
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jne	.L11
	movl	$0, %eax
	jmp	.L10
.L11:
	movq	-8(%rbp), %rax
	movq	16(%rax), %rax
	testq	%rax, %rax
	jne	.L12
	movq	-24(%rbp), %rax
	movq	$0, (%rax)
	movq	-24(%rbp), %rax
	movq	$0, 8(%rax)
	jmp	.L13
.L12:
	movq	-8(%rbp), %rax
	movq	16(%rax), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, (%rax)
.L13:
	movq	-8(%rbp), %rax
.L10:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	tpool_work_get, .-tpool_work_get
	.globl	tpool_worker
	.type	tpool_worker, @function
tpool_worker:
.LFB8:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	-24(%rbp), %rax
	movq	%rax, -16(%rbp)
.L22:
	movq	-16(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	jmp	.L15
.L17:
	movq	-16(%rbp), %rax
	leaq	16(%rax), %rdx
	movq	-16(%rbp), %rax
	addq	$56, %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	pthread_cond_wait@PLT
.L15:
	movq	-16(%rbp), %rax
	movq	(%rax), %rax
	testq	%rax, %rax
	jne	.L16
	movq	-16(%rbp), %rax
	movzbl	168(%rax), %eax
	xorl	$1, %eax
	testb	%al, %al
	jne	.L17
.L16:
	movq	-16(%rbp), %rax
	movzbl	168(%rax), %eax
	testb	%al, %al
	jne	.L25
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	tpool_work_get
	movq	%rax, -8(%rbp)
	movq	-16(%rbp), %rax
	movq	152(%rax), %rax
	leaq	1(%rax), %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, 152(%rax)
	movq	-16(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	cmpq	$0, -8(%rbp)
	je	.L20
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movq	-8(%rbp), %rdx
	movq	8(%rdx), %rdx
	movq	%rdx, %rdi
	call	*%rax
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	tpool_work_destroy
.L20:
	movq	-16(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movq	-16(%rbp), %rax
	movq	152(%rax), %rax
	leaq	-1(%rax), %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, 152(%rax)
	movq	-16(%rbp), %rax
	movzbl	168(%rax), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L21
	movq	-16(%rbp), %rax
	movq	152(%rax), %rax
	testq	%rax, %rax
	jne	.L21
	movq	-16(%rbp), %rax
	movq	(%rax), %rax
	testq	%rax, %rax
	jne	.L21
	movq	-16(%rbp), %rax
	addq	$104, %rax
	movq	%rax, %rdi
	call	pthread_cond_signal@PLT
.L21:
	movq	-16(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	jmp	.L22
.L25:
	nop
	movq	-16(%rbp), %rax
	movq	160(%rax), %rax
	leaq	-1(%rax), %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, 160(%rax)
	movq	-16(%rbp), %rax
	addq	$104, %rax
	movq	%rax, %rdi
	call	pthread_cond_signal@PLT
	movq	-16(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	tpool_worker, .-tpool_worker
	.globl	tpool_create
	.type	tpool_create, @function
tpool_create:
.LFB9:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	cmpq	$0, -40(%rbp)
	jne	.L27
	movq	$2, -40(%rbp)
.L27:
	movl	$176, %esi
	movl	$1, %edi
	call	calloc@PLT
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	-40(%rbp), %rdx
	movq	%rdx, 160(%rax)
	movq	-16(%rbp), %rax
	addq	$16, %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_mutex_init@PLT
	movq	-16(%rbp), %rax
	addq	$56, %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_cond_init@PLT
	movq	-16(%rbp), %rax
	addq	$104, %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_cond_init@PLT
	movq	-16(%rbp), %rax
	movq	$0, (%rax)
	movq	-16(%rbp), %rax
	movq	$0, 8(%rax)
	movq	$0, -24(%rbp)
	jmp	.L28
.L29:
	movq	-16(%rbp), %rdx
	leaq	-32(%rbp), %rax
	movq	%rdx, %rcx
	leaq	tpool_worker(%rip), %rdx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create@PLT
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	pthread_detach@PLT
	addq	$1, -24(%rbp)
.L28:
	movq	-24(%rbp), %rax
	cmpq	-40(%rbp), %rax
	jb	.L29
	movq	-16(%rbp), %rax
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L31
	call	__stack_chk_fail@PLT
.L31:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	tpool_create, .-tpool_create
	.globl	tpool_add_work
	.type	tpool_add_work, @function
tpool_add_work:
.LFB10:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	cmpq	$0, -24(%rbp)
	jne	.L33
	movl	$0, %eax
	jmp	.L34
.L33:
	movq	-40(%rbp), %rdx
	movq	-32(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	tpool_work_create
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jne	.L35
	movl	$0, %eax
	jmp	.L34
.L35:
	movq	-24(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	testq	%rax, %rax
	jne	.L36
	movq	-24(%rbp), %rax
	movq	-8(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-24(%rbp), %rax
	movq	(%rax), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, 8(%rax)
	jmp	.L37
.L36:
	movq	-24(%rbp), %rax
	movq	8(%rax), %rax
	movq	-8(%rbp), %rdx
	movq	%rdx, 16(%rax)
	movq	-24(%rbp), %rax
	movq	-8(%rbp), %rdx
	movq	%rdx, 8(%rax)
.L37:
	movq	-24(%rbp), %rax
	addq	$56, %rax
	movq	%rax, %rdi
	call	pthread_cond_broadcast@PLT
	movq	-24(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movl	$1, %eax
.L34:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	tpool_add_work, .-tpool_add_work
	.globl	tpool_wait
	.type	tpool_wait, @function
tpool_wait:
.LFB11:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L45
	movq	-8(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
.L44:
	movq	-8(%rbp), %rax
	movzbl	168(%rax), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L41
	movq	-8(%rbp), %rax
	movq	152(%rax), %rax
	testq	%rax, %rax
	jne	.L42
.L41:
	movq	-8(%rbp), %rax
	movzbl	168(%rax), %eax
	testb	%al, %al
	je	.L43
	movq	-8(%rbp), %rax
	movq	160(%rax), %rax
	testq	%rax, %rax
	je	.L43
.L42:
	movq	-8(%rbp), %rax
	leaq	16(%rax), %rdx
	movq	-8(%rbp), %rax
	addq	$104, %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	pthread_cond_wait@PLT
	jmp	.L44
.L43:
	movq	-8(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	jmp	.L38
.L45:
	nop
.L38:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	tpool_wait, .-tpool_wait
	.globl	tpool_destroy
	.type	tpool_destroy, @function
tpool_destroy:
.LFB12:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	cmpq	$0, -24(%rbp)
	je	.L51
	movq	-24(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -16(%rbp)
	jmp	.L49
.L50:
	movq	-16(%rbp), %rax
	movq	16(%rax), %rax
	movq	%rax, -8(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	tpool_work_destroy
	movq	-8(%rbp), %rax
	movq	%rax, -16(%rbp)
.L49:
	cmpq	$0, -16(%rbp)
	jne	.L50
	movq	-24(%rbp), %rax
	movb	$1, 168(%rax)
	movq	-24(%rbp), %rax
	addq	$56, %rax
	movq	%rax, %rdi
	call	pthread_cond_broadcast@PLT
	movq	-24(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	tpool_wait
	movq	-24(%rbp), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	pthread_mutex_destroy@PLT
	movq	-24(%rbp), %rax
	addq	$56, %rax
	movq	%rax, %rdi
	call	pthread_cond_destroy@PLT
	movq	-24(%rbp), %rax
	addq	$104, %rax
	movq	%rax, %rdi
	call	pthread_cond_destroy@PLT
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	jmp	.L46
.L51:
	nop
.L46:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	tpool_destroy, .-tpool_destroy
	.section	.rodata
	.align 8
.LC0:
	.string	"===============================================\n\t\tSparrow Version 0.1\n===============================================\n"
.LC1:
	.string	"HTTP Server starting..."
	.align 8
.LC2:
	.string	"Failed to listen on address 0.0.0.0:%d \n"
.LC3:
	.string	"Failed"
.LC4:
	.string	"Failed accepting connection"
.LC5:
	.string	"Cleaning up"
	.text
	.globl	main
	.type	main, @function
main:
.LFB13:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	leaq	.LC0(%rip), %rdi
	call	puts@PLT
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	movl	$4, %edi
	call	tpool_create
	movq	%rax, -24(%rbp)
	movl	$0, -28(%rbp)
	movl	$0, -32(%rbp)
	leaq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	server_listen
	movl	%eax, -28(%rbp)
	cmpl	$0, -28(%rbp)
	je	.L53
	movl	$8080, %esi
	leaq	.LC2(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	.LC3(%rip), %rdi
	call	perror@PLT
	movl	-28(%rbp), %eax
	jmp	.L57
.L53:
	movl	$8, %edi
	call	malloc@PLT
	movq	%rax, -16(%rbp)
	leaq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	server_accept
	movl	%eax, %edx
	movq	-16(%rbp), %rax
	movl	%edx, (%rax)
	movq	-16(%rbp), %rax
	movl	(%rax), %eax
	testl	%eax, %eax
	jns	.L55
	leaq	.LC4(%rip), %rdi
	call	puts@PLT
	movl	$1, -28(%rbp)
	nop
	leaq	.LC5(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	tpool_destroy
	movl	-32(%rbp), %eax
	movl	%eax, %edi
	call	close@PLT
	movl	-28(%rbp), %eax
	jmp	.L57
.L55:
	movq	-16(%rbp), %rdx
	movq	-24(%rbp), %rax
	leaq	handle_http(%rip), %rsi
	movq	%rax, %rdi
	call	tpool_add_work
	jmp	.L53
.L57:
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L58
	call	__stack_chk_fail@PLT
.L58:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	main, .-main
	.section	.rodata
.LC6:
	.string	"Could not start server!"
.LC7:
	.string	"Socket created successfully!"
.LC8:
	.string	"Bind failed."
.LC9:
	.string	"Binded successfully!"
.LC10:
	.string	"Could not set to listen."
.LC11:
	.string	"Set listening mode correctly."
	.text
	.globl	server_listen
	.type	server_listen, @function
server_listen:
.LFB14:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, %edx
	movl	$1, %esi
	movl	$2, %edi
	call	socket@PLT
	movl	%eax, %edx
	movq	-40(%rbp), %rax
	movl	%edx, (%rax)
	movq	-40(%rbp), %rax
	movl	(%rax), %eax
	cmpl	$-1, %eax
	jne	.L60
	leaq	.LC6(%rip), %rdi
	call	puts@PLT
	movl	$1, %eax
	jmp	.L64
.L60:
	leaq	.LC7(%rip), %rdi
	call	puts@PLT
	movw	$2, -32(%rbp)
	movl	$0, -28(%rbp)
	movl	$8080, %edi
	call	htons@PLT
	movw	%ax, -30(%rbp)
	movq	-40(%rbp), %rax
	movl	(%rax), %eax
	leaq	-32(%rbp), %rcx
	movl	$16, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	bind@PLT
	testl	%eax, %eax
	jns	.L62
	leaq	.LC8(%rip), %rdi
	call	puts@PLT
	movl	$1, %eax
	jmp	.L64
.L62:
	leaq	.LC9(%rip), %rdi
	call	puts@PLT
	movq	-40(%rbp), %rax
	movl	(%rax), %eax
	movl	$50, %esi
	movl	%eax, %edi
	call	listen@PLT
	testl	%eax, %eax
	je	.L63
	leaq	.LC10(%rip), %rdi
	call	puts@PLT
	movl	$1, %eax
	jmp	.L64
.L63:
	leaq	.LC11(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
.L64:
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L65
	call	__stack_chk_fail@PLT
.L65:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	server_listen, .-server_listen
	.section	.rodata
.LC12:
	.string	"Connection failed..."
.LC13:
	.string	"Server accepted the client..."
	.text
	.globl	server_accept
	.type	server_accept, @function
server_accept:
.LFB15:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%rdi, -56(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$16, -40(%rbp)
	movq	-56(%rbp), %rax
	movl	(%rax), %eax
	leaq	-40(%rbp), %rdx
	leaq	-32(%rbp), %rcx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	accept@PLT
	movl	%eax, -36(%rbp)
	cmpl	$0, -36(%rbp)
	jns	.L67
	leaq	.LC12(%rip), %rdi
	call	puts@PLT
	movl	$-1, %eax
	jmp	.L69
.L67:
	leaq	.LC13(%rip), %rdi
	call	puts@PLT
	movl	-36(%rbp), %eax
.L69:
	movq	-8(%rbp), %rsi
	xorq	%fs:40, %rsi
	je	.L70
	call	__stack_chk_fail@PLT
.L70:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	server_accept, .-server_accept
	.section	.rodata
.LC14:
	.string	"Process ID: %ld\n"
.LC15:
	.string	"No bytes to read."
	.align 8
.LC16:
	.string	"Read: %d\nGetting request and response data.\n"
.LC17:
	.string	"GET"
.LC18:
	.string	"GET request"
.LC19:
	.string	".php"
.LC20:
	.string	".png"
.LC21:
	.string	"image/png"
.LC22:
	.string	".jpeg"
.LC23:
	.string	"image/jpeg"
.LC24:
	.string	".jpg"
.LC25:
	.string	"image/jpg"
.LC26:
	.string	".gif"
.LC27:
	.string	"image/gif"
.LC28:
	.string	".html"
.LC29:
	.string	"text/html"
.LC30:
	.string	".css"
.LC31:
	.string	"text/css"
.LC32:
	.string	".js"
.LC33:
	.string	"text/javascript"
.LC34:
	.string	"text/plain"
.LC35:
	.string	"404 Not Found!"
.LC36:
	.string	"501 Not Implemented!"
.LC37:
	.string	"Error writing message"
	.text
	.globl	handle_http
	.type	handle_http, @function
handle_http:
.LFB16:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$1184, %rsp
	movq	%rdi, -1144(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	call	getpid@PLT
	cltq
	movq	%rax, %rsi
	leaq	.LC14(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-1144(%rbp), %rax
	movq	%rax, -1096(%rbp)
	movq	-1096(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -1124(%rbp)
	leaq	-1040(%rbp), %rdx
	movl	$0, %eax
	movl	$128, %ecx
	movq	%rdx, %rdi
	rep stosq
	leaq	-1040(%rbp), %rcx
	movl	-1124(%rbp), %eax
	movl	$1024, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	read@PLT
	movl	%eax, -1120(%rbp)
	leaq	-1040(%rbp), %rax
	movq	%rax, %rdi
	call	puts@PLT
	cmpl	$0, -1120(%rbp)
	jg	.L72
	leaq	.LC15(%rip), %rdi
	call	puts@PLT
	movl	-1124(%rbp), %eax
	movl	%eax, %edi
	call	close@PLT
	jmp	.L71
.L72:
	movl	-1120(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC16(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	-1040(%rbp), %rax
	movq	%rax, %rdi
	call	read_request
	movq	%rax, -1088(%rbp)
	movq	%rdx, -1080(%rbp)
	movq	-1088(%rbp), %rax
	movl	$3, %edx
	leaq	.LC17(%rip), %rsi
	movq	%rax, %rdi
	call	strncmp@PLT
	testl	%eax, %eax
	jne	.L74
	leaq	.LC18(%rip), %rdi
	call	puts@PLT
	movq	$0, -1112(%rbp)
	movq	$0, -1104(%rbp)
	movq	-1080(%rbp), %rax
	leaq	.LC19(%rip), %rsi
	movq	%rax, %rdi
	call	strstr@PLT
	testq	%rax, %rax
	je	.L75
	movq	-1088(%rbp), %rdx
	movq	-1080(%rbp), %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	cgi_script
	movq	%rax, -1104(%rbp)
	jmp	.L76
.L75:
	movq	-1080(%rbp), %rax
	leaq	-1104(%rbp), %rdx
	leaq	-1112(%rbp), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	load_file
.L76:
	movq	-1104(%rbp), %rax
	testq	%rax, %rax
	je	.L77
	movq	-1080(%rbp), %rax
	leaq	.LC20(%rip), %rsi
	movq	%rax, %rdi
	call	strstr@PLT
	testq	%rax, %rax
	je	.L78
	leaq	.LC21(%rip), %rax
	movq	%rax, -1064(%rbp)
	jmp	.L79
.L78:
	movq	-1080(%rbp), %rax
	leaq	.LC22(%rip), %rsi
	movq	%rax, %rdi
	call	strstr@PLT
	testq	%rax, %rax
	je	.L80
	leaq	.LC23(%rip), %rax
	movq	%rax, -1064(%rbp)
	jmp	.L79
.L80:
	movq	-1080(%rbp), %rax
	leaq	.LC24(%rip), %rsi
	movq	%rax, %rdi
	call	strstr@PLT
	testq	%rax, %rax
	je	.L81
	leaq	.LC25(%rip), %rax
	movq	%rax, -1064(%rbp)
	jmp	.L79
.L81:
	movq	-1080(%rbp), %rax
	leaq	.LC26(%rip), %rsi
	movq	%rax, %rdi
	call	strstr@PLT
	testq	%rax, %rax
	je	.L82
	leaq	.LC27(%rip), %rax
	movq	%rax, -1064(%rbp)
	jmp	.L79
.L82:
	movq	-1080(%rbp), %rax
	leaq	.LC28(%rip), %rsi
	movq	%rax, %rdi
	call	strstr@PLT
	testq	%rax, %rax
	je	.L83
	leaq	.LC29(%rip), %rax
	movq	%rax, -1064(%rbp)
	jmp	.L79
.L83:
	movq	-1080(%rbp), %rax
	leaq	.LC30(%rip), %rsi
	movq	%rax, %rdi
	call	strstr@PLT
	testq	%rax, %rax
	je	.L84
	leaq	.LC31(%rip), %rax
	movq	%rax, -1064(%rbp)
	jmp	.L79
.L84:
	movq	-1080(%rbp), %rax
	leaq	.LC32(%rip), %rsi
	movq	%rax, %rdi
	call	strstr@PLT
	testq	%rax, %rax
	je	.L85
	leaq	.LC33(%rip), %rax
	movq	%rax, -1064(%rbp)
	jmp	.L79
.L85:
	leaq	.LC34(%rip), %rax
	movq	%rax, -1064(%rbp)
.L79:
	movq	-1112(%rbp), %rax
	movq	%rax, -1056(%rbp)
	movl	$200, -1072(%rbp)
	movq	-1104(%rbp), %rax
	movq	%rax, -1048(%rbp)
	jmp	.L87
.L77:
	leaq	-1072(%rbp), %rax
	movl	$14, %r8d
	leaq	.LC35(%rip), %rcx
	leaq	.LC34(%rip), %rdx
	movl	$404, %esi
	movq	%rax, %rdi
	call	build_response
	jmp	.L87
.L74:
	leaq	-1184(%rbp), %rax
	movl	$20, %r8d
	leaq	.LC36(%rip), %rcx
	leaq	.LC34(%rip), %rdx
	movl	$501, %esi
	movq	%rax, %rdi
	call	build_response
	movq	-1184(%rbp), %rax
	movq	-1176(%rbp), %rdx
	movq	%rax, -1072(%rbp)
	movq	%rdx, -1064(%rbp)
	movq	-1168(%rbp), %rax
	movq	-1160(%rbp), %rdx
	movq	%rax, -1056(%rbp)
	movq	%rdx, -1048(%rbp)
.L87:
	movl	-1124(%rbp), %eax
	pushq	-1048(%rbp)
	pushq	-1056(%rbp)
	pushq	-1064(%rbp)
	pushq	-1072(%rbp)
	movl	%eax, %edi
	call	send_response
	addq	$32, %rsp
	movl	%eax, -1116(%rbp)
	cmpl	$-1, -1116(%rbp)
	jne	.L88
	leaq	.LC3(%rip), %rdi
	call	perror@PLT
	leaq	.LC37(%rip), %rdi
	call	puts@PLT
.L88:
	leaq	.LC5(%rip), %rdi
	call	puts@PLT
	movl	-1124(%rbp), %eax
	movl	%eax, %edi
	call	close@PLT
	movq	-1088(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	movq	-1080(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	movl	-1072(%rbp), %eax
	cmpl	$200, %eax
	jne	.L89
	movq	-1056(%rbp), %rax
	movq	%rax, %rdx
	movq	-1048(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	munmap@PLT
.L89:
	movq	-1144(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
.L71:
	movq	-8(%rbp), %rax
	xorq	%fs:40, %rax
	je	.L90
	call	__stack_chk_fail@PLT
.L90:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE16:
	.size	handle_http, .-handle_http
	.section	.rodata
	.align 8
.LC38:
	.string	"We think this is a directory, so we are going to return index.html"
	.align 8
.LC39:
	.string	"Parsed Method: %s| Filename: %s|\n"
	.text
	.globl	read_request
	.type	read_request, @function
read_request:
.LFB17:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$72, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -72(%rbp)
	movq	$0, -32(%rbp)
	movq	$0, -24(%rbp)
	movq	-72(%rbp), %rax
	movl	$32, %esi
	movq	%rax, %rdi
	call	strchr@PLT
	movq	%rax, -56(%rbp)
	movq	-56(%rbp), %rdx
	movq	-72(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	addq	$1, %rax
	movl	$1, %esi
	movq	%rax, %rdi
	call	calloc@PLT
	movq	%rax, -32(%rbp)
	movq	-56(%rbp), %rdx
	movq	-72(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	movq	%rax, %rdx
	movq	-32(%rbp), %rax
	movq	-72(%rbp), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	strncpy@PLT
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	leaq	1(%rax), %rdx
	movq	-72(%rbp), %rax
	addq	%rdx, %rax
	movl	$47, %esi
	movq	%rax, %rdi
	call	strchr@PLT
	movq	%rax, -48(%rbp)
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	leaq	1(%rax), %rdx
	movq	-72(%rbp), %rax
	addq	%rdx, %rax
	movl	$32, %esi
	movq	%rax, %rdi
	call	strchr@PLT
	movq	%rax, -40(%rbp)
	movq	-40(%rbp), %rax
	subq	$1, %rax
	movzbl	(%rax), %eax
	cmpb	$47, %al
	jne	.L92
	leaq	.LC38(%rip), %rdi
	call	puts@PLT
	movq	-40(%rbp), %rdx
	movq	-48(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	addq	$16, %rax
	movl	$1, %esi
	movq	%rax, %rdi
	call	calloc@PLT
	movq	%rax, -24(%rbp)
	movq	-24(%rbp), %rax
	movl	$6448503, (%rax)
	movq	-40(%rbp), %rdx
	movq	-48(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	movq	%rax, %rbx
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	leaq	1(%rax), %rdx
	movq	-72(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movq	-24(%rbp), %rax
	movq	%rbx, %rdx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	strncat@PLT
	movq	-24(%rbp), %rdx
	movq	%rdx, %rax
	movq	$-1, %rcx
	movq	%rax, %rsi
	movl	$0, %eax
	movq	%rsi, %rdi
	repnz scasb
	movq	%rcx, %rax
	notq	%rax
	subq	$1, %rax
	addq	%rdx, %rax
	movabsq	$8388005400609582697, %rbx
	movq	%rbx, (%rax)
	movw	$27757, 8(%rax)
	movb	$0, 10(%rax)
	jmp	.L93
.L92:
	movq	-40(%rbp), %rdx
	movq	-48(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	addq	$5, %rax
	movl	$1, %esi
	movq	%rax, %rdi
	call	calloc@PLT
	movq	%rax, -24(%rbp)
	movq	-24(%rbp), %rax
	movl	$6448503, (%rax)
	movq	-40(%rbp), %rdx
	movq	-48(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	movq	%rax, %rbx
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	leaq	1(%rax), %rdx
	movq	-72(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movq	-24(%rbp), %rax
	movq	%rbx, %rdx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	strncat@PLT
.L93:
	movq	-24(%rbp), %rdx
	movq	-32(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC39(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-32(%rbp), %rax
	movq	-24(%rbp), %rdx
	addq	$72, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE17:
	.size	read_request, .-read_request
	.globl	build_response
	.type	build_response, @function
build_response:
.LFB18:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -40(%rbp)
	movl	%esi, -44(%rbp)
	movq	%rdx, -56(%rbp)
	movq	%rcx, -64(%rbp)
	movq	%r8, -72(%rbp)
	movq	$0, -32(%rbp)
	movq	$0, -24(%rbp)
	movq	$0, -16(%rbp)
	movq	$0, -8(%rbp)
	movl	-44(%rbp), %eax
	movl	%eax, -32(%rbp)
	movq	-56(%rbp), %rax
	movq	%rax, -24(%rbp)
	movq	-64(%rbp), %rax
	movq	%rax, -8(%rbp)
	movq	-72(%rbp), %rax
	movq	%rax, -16(%rbp)
	movq	-40(%rbp), %rcx
	movq	-32(%rbp), %rax
	movq	-24(%rbp), %rdx
	movq	%rax, (%rcx)
	movq	%rdx, 8(%rcx)
	movq	-16(%rbp), %rax
	movq	-8(%rbp), %rdx
	movq	%rax, 16(%rcx)
	movq	%rdx, 24(%rcx)
	movq	-40(%rbp), %rax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE18:
	.size	build_response, .-build_response
	.section	.rodata
.LC40:
	.string	"%a, %m %b %G %T %Z"
.LC41:
	.string	"Sparrow/0.1"
	.align 8
.LC42:
	.string	"HTTP/1.1 %d %s\r\nServer: %s\r\nDate: %s\r\nContent-Type: %s\r\nContent-Length: %ld\r\n\r\n"
	.text
	.globl	send_response
	.type	send_response, @function
send_response:
.LFB19:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r12
	pushq	%rbx
	subq	$336, %rsp
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	movl	%edi, -340(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -24(%rbp)
	xorl	%eax, %eax
	movl	16(%rbp), %eax
	movl	%eax, %edi
	call	get_error_msg
	movq	%rax, -320(%rbp)
	leaq	-328(%rbp), %rax
	movq	%rax, %rdi
	call	time@PLT
	movq	%rax, -328(%rbp)
	leaq	-328(%rbp), %rax
	movq	%rax, %rdi
	call	gmtime@PLT
	movq	%rax, -312(%rbp)
	movq	-312(%rbp), %rdx
	leaq	-288(%rbp), %rax
	movq	%rdx, %rcx
	leaq	.LC40(%rip), %rdx
	movl	$256, %esi
	movq	%rax, %rdi
	call	strftime@PLT
	movq	24(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movq	%rax, %rbx
	leaq	-288(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	addq	%rax, %rbx
	movq	-320(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	addq	%rbx, %rax
	addq	$92, %rax
	movl	$1, %esi
	movq	%rax, %rdi
	call	calloc@PLT
	movq	%rax, -304(%rbp)
	movq	32(%rbp), %rdi
	movq	24(%rbp), %rsi
	movl	16(%rbp), %edx
	leaq	-288(%rbp), %r8
	movq	-320(%rbp), %rcx
	movq	-304(%rbp), %rax
	pushq	%rdi
	pushq	%rsi
	movq	%r8, %r9
	leaq	.LC41(%rip), %r8
	leaq	.LC42(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	sprintf@PLT
	addq	$16, %rsp
	movq	-304(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movq	%rax, %rdx
	movq	32(%rbp), %rax
	addq	%rdx, %rax
	addq	$1, %rax
	movl	$1, %esi
	movq	%rax, %rdi
	call	calloc@PLT
	movq	%rax, -296(%rbp)
	movq	-304(%rbp), %rdx
	movq	-296(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	strcpy@PLT
	movq	32(%rbp), %rax
	movq	%rax, %r12
	movq	40(%rbp), %rbx
	movq	-304(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movq	%rax, %rdx
	movq	-296(%rbp), %rax
	addq	%rdx, %rax
	movq	%r12, %rdx
	movq	%rbx, %rsi
	movq	%rax, %rdi
	call	memcpy@PLT
	movq	-304(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movq	%rax, %rdx
	movq	32(%rbp), %rax
	addq	%rax, %rdx
	movq	-296(%rbp), %rcx
	movl	-340(%rbp), %eax
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	write@PLT
	movl	%eax, -332(%rbp)
	movq	-304(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	movq	-296(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	movl	-332(%rbp), %eax
	movq	-24(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L99
	call	__stack_chk_fail@PLT
.L99:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE19:
	.size	send_response, .-send_response
	.section	.rodata
.LC43:
	.string	"Executing cgi script: %s\n"
.LC44:
	.string	"Setting environment variables"
.LC45:
	.string	"CONTENT_LENGTH=NULL"
.LC46:
	.string	"GATEWAY_INTERFACE=CGI/1.1"
.LC47:
	.string	"PATH_INFO=script.php"
.LC48:
	.string	"QUERY_STRING=\"\""
.LC49:
	.string	"REMOTE_ADDR=127.0.0.1"
.LC50:
	.string	"REMOTE_HOST=NULL"
.LC51:
	.string	"REQUEST_METHOD=GET"
.LC52:
	.string	"SCRIPT_NAME=/script.php"
.LC53:
	.string	"SERVER_NAME=localhost"
.LC54:
	.string	"SERVER_PORT=%d"
.LC55:
	.string	"SERVER_PROTOCOL=HTTP/1.1"
.LC56:
	.string	"SERVER_SOFTWARE=Sparrow/0.1"
.LC57:
	.string	"REDIRECT_STATUS=CGI"
.LC58:
	.string	"SCRIPT_FILENAME=script.php"
.LC59:
	.string	"Executing script now."
.LC60:
	.string	"r"
	.align 8
.LC61:
	.string	"cd web && php-cgi -fscript.php"
.LC62:
	.string	"Failed to run command"
.LC63:
	.string	"Response:"
	.text
	.globl	cgi_script
	.type	cgi_script, @function
cgi_script:
.LFB20:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%rdi, %rax
	movq	%rsi, %rcx
	movq	%rcx, %rdx
	movq	%rax, -64(%rbp)
	movq	%rdx, -56(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movq	-56(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC43(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	.LC44(%rip), %rdi
	call	puts@PLT
	leaq	.LC45(%rip), %rdi
	call	putenv@PLT
	leaq	.LC46(%rip), %rdi
	call	putenv@PLT
	leaq	.LC47(%rip), %rdi
	call	putenv@PLT
	leaq	.LC48(%rip), %rdi
	call	putenv@PLT
	leaq	.LC49(%rip), %rdi
	call	putenv@PLT
	leaq	.LC50(%rip), %rdi
	call	putenv@PLT
	leaq	.LC51(%rip), %rdi
	call	putenv@PLT
	leaq	.LC52(%rip), %rdi
	call	putenv@PLT
	leaq	.LC53(%rip), %rdi
	call	putenv@PLT
	leaq	-32(%rbp), %rax
	movl	$8080, %edx
	leaq	.LC54(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	sprintf@PLT
	leaq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	putenv@PLT
	leaq	.LC55(%rip), %rdi
	call	putenv@PLT
	leaq	.LC56(%rip), %rdi
	call	putenv@PLT
	leaq	.LC57(%rip), %rdi
	call	putenv@PLT
	leaq	.LC58(%rip), %rdi
	call	putenv@PLT
	leaq	.LC59(%rip), %rdi
	call	puts@PLT
	leaq	.LC60(%rip), %rsi
	leaq	.LC61(%rip), %rdi
	call	popen@PLT
	movq	%rax, -40(%rbp)
	cmpq	$0, -40(%rbp)
	jne	.L101
	leaq	.LC62(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	jmp	.L105
.L101:
	leaq	.LC63(%rip), %rdi
	call	puts@PLT
	jmp	.L103
.L104:
	movq	-40(%rbp), %rax
	movq	%rax, %rdi
	call	fgetc@PLT
	movl	%eax, %edi
	call	putchar@PLT
.L103:
	movq	-40(%rbp), %rax
	movq	%rax, %rdi
	call	feof@PLT
	testl	%eax, %eax
	je	.L104
	movq	-40(%rbp), %rax
	movq	%rax, %rdi
	call	pclose@PLT
	movl	$0, %eax
.L105:
	movq	-8(%rbp), %rdx
	xorq	%fs:40, %rdx
	je	.L106
	call	__stack_chk_fail@PLT
.L106:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE20:
	.size	cgi_script, .-cgi_script
	.section	.rodata
.LC64:
	.string	"Continue"
.LC65:
	.string	"Switching Protocols"
.LC66:
	.string	"Processing"
.LC67:
	.string	"Early Hints"
.LC68:
	.string	"OK"
.LC69:
	.string	"Created"
.LC70:
	.string	"Accepted"
.LC71:
	.string	"Non-Authoritative Information"
.LC72:
	.string	"No Content"
.LC73:
	.string	"Reset Content"
.LC74:
	.string	"Partial Content"
.LC75:
	.string	"Multi-Status"
.LC76:
	.string	"Already Reported"
.LC77:
	.string	"IM Used"
.LC78:
	.string	"Multiple Choices"
.LC79:
	.string	"Moved Permanently"
.LC80:
	.string	"Found"
.LC81:
	.string	"See Other"
.LC82:
	.string	"Not Modified"
.LC83:
	.string	"Use Proxy"
.LC84:
	.string	"Switch Proxy"
.LC85:
	.string	"Temporary Redirect"
.LC86:
	.string	"Permanent Redirect"
.LC87:
	.string	"Bad Request"
.LC88:
	.string	"Unauthorized"
.LC89:
	.string	"Payment Required"
.LC90:
	.string	"Forbidden"
.LC91:
	.string	"Not found"
.LC92:
	.string	"Method Not Allowed"
.LC93:
	.string	"Not Acceptable"
.LC94:
	.string	"Proxy Authentication Required"
.LC95:
	.string	"Request Timeout"
.LC96:
	.string	"Conflict"
.LC97:
	.string	"Gone"
.LC98:
	.string	"Length Required"
.LC99:
	.string	"Precondition Failed"
.LC100:
	.string	"Payload Too Large"
.LC101:
	.string	"URI Too Long"
.LC102:
	.string	"Unsupported Media Type"
.LC103:
	.string	"Range Not Satisfiable"
.LC104:
	.string	"Expectation Failed"
.LC105:
	.string	"I'm a teapot"
.LC106:
	.string	"Misdirected Request"
.LC107:
	.string	"Unprocessable Entity"
.LC108:
	.string	"Locked"
.LC109:
	.string	"Failed Dependency"
.LC110:
	.string	"Too Early"
.LC111:
	.string	"Upgrade Required"
.LC112:
	.string	"Precondition Required"
.LC113:
	.string	"Too Many Requests"
	.align 8
.LC114:
	.string	"Request Header Fields Too Large"
.LC115:
	.string	"Unavailable for Legal Reasons"
.LC116:
	.string	"Internal Server Error"
.LC117:
	.string	"Not Implemented!"
.LC118:
	.string	"Bad Gateway"
.LC119:
	.string	"Service Unavailable"
.LC120:
	.string	"Gateway Timeout"
.LC121:
	.string	"HTTP Version Not Supported"
.LC122:
	.string	"Variant Also Negotiates"
.LC123:
	.string	"Insufficient Storage"
.LC124:
	.string	"Loop Detected"
.LC125:
	.string	"Not Extended"
	.align 8
.LC126:
	.string	"Network Authentication Required"
.LC127:
	.string	"Unknown"
	.text
	.globl	get_error_msg
	.type	get_error_msg, @function
get_error_msg:
.LFB21:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %eax
	subl	$100, %eax
	cmpl	$411, %eax
	ja	.L108
	movl	%eax, %eax
	leaq	0(,%rax,4), %rdx
	leaq	.L110(%rip), %rax
	movl	(%rdx,%rax), %eax
	movslq	%eax, %rdx
	leaq	.L110(%rip), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section	.rodata
	.align 4
	.align 4
.L110:
	.long	.L109-.L110
	.long	.L111-.L110
	.long	.L112-.L110
	.long	.L113-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L114-.L110
	.long	.L115-.L110
	.long	.L116-.L110
	.long	.L117-.L110
	.long	.L118-.L110
	.long	.L119-.L110
	.long	.L120-.L110
	.long	.L121-.L110
	.long	.L122-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L123-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L124-.L110
	.long	.L125-.L110
	.long	.L126-.L110
	.long	.L127-.L110
	.long	.L128-.L110
	.long	.L129-.L110
	.long	.L130-.L110
	.long	.L131-.L110
	.long	.L132-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L133-.L110
	.long	.L134-.L110
	.long	.L135-.L110
	.long	.L136-.L110
	.long	.L137-.L110
	.long	.L138-.L110
	.long	.L139-.L110
	.long	.L140-.L110
	.long	.L141-.L110
	.long	.L142-.L110
	.long	.L143-.L110
	.long	.L144-.L110
	.long	.L145-.L110
	.long	.L146-.L110
	.long	.L147-.L110
	.long	.L148-.L110
	.long	.L149-.L110
	.long	.L150-.L110
	.long	.L151-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L152-.L110
	.long	.L153-.L110
	.long	.L154-.L110
	.long	.L155-.L110
	.long	.L156-.L110
	.long	.L157-.L110
	.long	.L108-.L110
	.long	.L158-.L110
	.long	.L159-.L110
	.long	.L108-.L110
	.long	.L160-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L161-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L108-.L110
	.long	.L162-.L110
	.long	.L163-.L110
	.long	.L164-.L110
	.long	.L165-.L110
	.long	.L166-.L110
	.long	.L167-.L110
	.long	.L168-.L110
	.long	.L169-.L110
	.long	.L170-.L110
	.long	.L108-.L110
	.long	.L171-.L110
	.long	.L172-.L110
	.text
.L109:
	leaq	.LC64(%rip), %rax
	jmp	.L173
.L111:
	leaq	.LC65(%rip), %rax
	jmp	.L173
.L112:
	leaq	.LC66(%rip), %rax
	jmp	.L173
.L113:
	leaq	.LC67(%rip), %rax
	jmp	.L173
.L114:
	leaq	.LC68(%rip), %rax
	jmp	.L173
.L115:
	leaq	.LC69(%rip), %rax
	jmp	.L173
.L116:
	leaq	.LC70(%rip), %rax
	jmp	.L173
.L117:
	leaq	.LC71(%rip), %rax
	jmp	.L173
.L118:
	leaq	.LC72(%rip), %rax
	jmp	.L173
.L119:
	leaq	.LC73(%rip), %rax
	jmp	.L173
.L120:
	leaq	.LC74(%rip), %rax
	jmp	.L173
.L121:
	leaq	.LC75(%rip), %rax
	jmp	.L173
.L122:
	leaq	.LC76(%rip), %rax
	jmp	.L173
.L123:
	leaq	.LC77(%rip), %rax
	jmp	.L173
.L124:
	leaq	.LC78(%rip), %rax
	jmp	.L173
.L125:
	leaq	.LC79(%rip), %rax
	jmp	.L173
.L126:
	leaq	.LC80(%rip), %rax
	jmp	.L173
.L127:
	leaq	.LC81(%rip), %rax
	jmp	.L173
.L128:
	leaq	.LC82(%rip), %rax
	jmp	.L173
.L129:
	leaq	.LC83(%rip), %rax
	jmp	.L173
.L130:
	leaq	.LC84(%rip), %rax
	jmp	.L173
.L131:
	leaq	.LC85(%rip), %rax
	jmp	.L173
.L132:
	leaq	.LC86(%rip), %rax
	jmp	.L173
.L133:
	leaq	.LC87(%rip), %rax
	jmp	.L173
.L134:
	leaq	.LC88(%rip), %rax
	jmp	.L173
.L135:
	leaq	.LC89(%rip), %rax
	jmp	.L173
.L136:
	leaq	.LC90(%rip), %rax
	jmp	.L173
.L137:
	leaq	.LC91(%rip), %rax
	jmp	.L173
.L138:
	leaq	.LC92(%rip), %rax
	jmp	.L173
.L139:
	leaq	.LC93(%rip), %rax
	jmp	.L173
.L140:
	leaq	.LC94(%rip), %rax
	jmp	.L173
.L141:
	leaq	.LC95(%rip), %rax
	jmp	.L173
.L142:
	leaq	.LC96(%rip), %rax
	jmp	.L173
.L143:
	leaq	.LC97(%rip), %rax
	jmp	.L173
.L144:
	leaq	.LC98(%rip), %rax
	jmp	.L173
.L145:
	leaq	.LC99(%rip), %rax
	jmp	.L173
.L146:
	leaq	.LC100(%rip), %rax
	jmp	.L173
.L147:
	leaq	.LC101(%rip), %rax
	jmp	.L173
.L148:
	leaq	.LC102(%rip), %rax
	jmp	.L173
.L149:
	leaq	.LC103(%rip), %rax
	jmp	.L173
.L150:
	leaq	.LC104(%rip), %rax
	jmp	.L173
.L151:
	leaq	.LC105(%rip), %rax
	jmp	.L173
.L152:
	leaq	.LC106(%rip), %rax
	jmp	.L173
.L153:
	leaq	.LC107(%rip), %rax
	jmp	.L173
.L154:
	leaq	.LC108(%rip), %rax
	jmp	.L173
.L155:
	leaq	.LC109(%rip), %rax
	jmp	.L173
.L156:
	leaq	.LC110(%rip), %rax
	jmp	.L173
.L157:
	leaq	.LC111(%rip), %rax
	jmp	.L173
.L158:
	leaq	.LC112(%rip), %rax
	jmp	.L173
.L159:
	leaq	.LC113(%rip), %rax
	jmp	.L173
.L160:
	leaq	.LC114(%rip), %rax
	jmp	.L173
.L161:
	leaq	.LC115(%rip), %rax
	jmp	.L173
.L162:
	leaq	.LC116(%rip), %rax
	jmp	.L173
.L163:
	leaq	.LC117(%rip), %rax
	jmp	.L173
.L164:
	leaq	.LC118(%rip), %rax
	jmp	.L173
.L165:
	leaq	.LC119(%rip), %rax
	jmp	.L173
.L166:
	leaq	.LC120(%rip), %rax
	jmp	.L173
.L167:
	leaq	.LC121(%rip), %rax
	jmp	.L173
.L168:
	leaq	.LC122(%rip), %rax
	jmp	.L173
.L169:
	leaq	.LC123(%rip), %rax
	jmp	.L173
.L170:
	leaq	.LC124(%rip), %rax
	jmp	.L173
.L171:
	leaq	.LC125(%rip), %rax
	jmp	.L173
.L172:
	leaq	.LC126(%rip), %rax
	jmp	.L173
.L108:
	leaq	.LC127(%rip), %rax
.L173:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE21:
	.size	get_error_msg, .-get_error_msg
	.section	.rodata
.LC128:
	.string	"rb"
.LC129:
	.string	"Size: %ld\n"
.LC130:
	.string	"Could not find file."
	.text
	.globl	load_file
	.type	load_file, @function
load_file:
.LFB22:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	movq	-24(%rbp), %rax
	movl	$4, %esi
	movq	%rax, %rdi
	call	access@PLT
	cmpl	$-1, %eax
	je	.L175
	movq	-24(%rbp), %rax
	leaq	.LC128(%rip), %rsi
	movq	%rax, %rdi
	call	fopen@PLT
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	$2, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	fseek@PLT
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	ftell@PLT
	movq	%rax, %rdx
	movq	-32(%rbp), %rax
	movq	%rdx, (%rax)
	movq	-8(%rbp), %rax
	movl	$0, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	fseek@PLT
	movq	-32(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, %rsi
	leaq	.LC129(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	fileno@PLT
	movl	%eax, %edx
	movq	-32(%rbp), %rax
	movq	(%rax), %rax
	movl	$0, %r9d
	movl	%edx, %r8d
	movl	$2, %ecx
	movl	$1, %edx
	movq	%rax, %rsi
	movl	$0, %edi
	call	mmap@PLT
	movq	%rax, %rdx
	movq	-40(%rbp), %rax
	movq	%rdx, (%rax)
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	fclose@PLT
	jmp	.L177
.L175:
	movq	-40(%rbp), %rax
	movq	$0, (%rax)
	leaq	.LC130(%rip), %rdi
	call	puts@PLT
	leaq	.LC3(%rip), %rdi
	call	perror@PLT
	call	__errno_location@PLT
	movl	$0, (%rax)
.L177:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE22:
	.size	load_file, .-load_file
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
