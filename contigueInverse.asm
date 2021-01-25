; Verifier si une chaine introduite par l'utilisateur est contigue inverse

Data segment
  
    chaine db 100 dup("$"); c'est ou on va stocker la chaine lu
    X dw ? ;cette variable sert a stocket l'offset de chaine[0]
    taille dw ?  ;cette variable sert a stocker la taille de la chaine lu
    testconinv db ? ;cette variable sert a stocker le resultas de la procedure contigueinverse elle recois 1 si contigue inverse 0 sinon
    ligne db 0Ah,0dh,0Ah,0dh,"$" ;cette chaine sert a  faire un saut de ligne
    msg1 db "Veuillez cliquer sur une touche pour sortir : $" ;ces chaines represente des messages de pour l'utilisateur       
    msg2 db "Veuillez introduire la chaine a traiter : $"
    contig db "Votre chaine est contigue inverse.$"
    noncontig db "Votre chaine n'est pas contigue inverse.$"  
    
Data ends

Code segment
   assume Cs:Code, Ds:Data 
 
 contigueinverse  proc near ;cette procedure nous dit si la chaine dont l'offset de debut est contenue dans x est contigue inverse 
                            ;et retourne le resulat dans la variable testconinv elle recois 1 si contigue inverse 0 sinon
							
      mov cx,taille  ; on initialise le compter cx a le taille de la chaine
      mov testconinv,1h;on initialise la var testconinv a 1 donc on supose que la chaine est  contigue inverse 
      
      mov si,x    ; on initalise a l'offset de debut de la chaine 
      mov di,si   ; on initalise a l'offset de debut de la chaine 
      add di,cx   ; on aditionne di avec la taille qui est dans le cx pour arriver dans l'offset de fin de chaine + 1
      sub di,1    ; on soustraie 1 a di pour arriver dans l'offset du caractere avant caractere fin de chaine $
      ; ces 3 dernieres instruction sont faite pour que di contienne l'adresse de l'avant dernier caractere (le dernier c'est $)
      shr cx,1    ; on decal a droit cx pour obtenir cx DIV 2 qui est le nombre d'iteration nessessaire au maximum pour tester 
     
      parcourir:  ; cette boule sert a parcourire et comparer 
        mov al,[si] ; on mov le contenue de si dans al car [si] est sur 8 bit char
        cmp al,[di] ; on compare al avec le char d'offset di
        jne notcontigueinverse  ;s'ils sont different donc la chaine est non contigue inverse
        dec di                 ; a chaque iteration on decrment di pour reculer dans la chaine 
        inc si                 ;a chaque iteration on decrment di pour avancer dans la chaine
        loop parcourir         ; retourner a la boucle
        jmp sorite             ; on jump vers sortie pour ne pas passer par  notcontigueinversse si la chaine est contigue inverse
        
        notcontigueinverse:   ; si la chaine n'est pas contigue inverse 
         mov testconinv,0h    ; on met testconinv a 0;
    
   sorite:  ;pour sortir 
    ret
 endp       
 
   affichage proc near ;cette procedure sert afficher le type de la chaine
    
        mov si,x ;on stocke l'offset de debut de chaine contenue dans x  dans le registre si
        mov dx,offset ligne
        mov ah,9h
        int 21H
	    ;les trois instructions sont pour le saut de ligne 
	    
	    cmp testconinv,0 ;on compare  testconinv et 0
        je affichernotcontigueinverse ;si testconinv==0 alors la chaine dont l'offset de debut est contenue dans x 
	                                 ;n'est pas contigue inverse donc on jump vers affichernotcontigueinverse
       
         affichagecontigueinverse:; si on a pas jumper dans l'intruction precedante  donc la chaine dont l'offset de debut est contenue dans x est contigue inverse
                 mov dx,offset contig
                 mov ah,9h
                 int 21H 
		  ; les trois instructions sont pour afficher  un message a l'utilisateur
         
       jmp finaffichage  ; on finie le traitment donc on jump vers la fin pour ne pas entrer dans l'etiquette affichernotcontigueinverse
       
       affichernotcontigueinverse: ; si on arive dans cette etiquette la donc la chaine n'est pas contigue inverse
            mov dx,offset noncontig
             mov ah,9h
            int 21H 
		  ; les trois instructions sont pour afficher  un message a l'utilisateur
       
    finaffichage:;etiquette pour finir et sortir de la procedure 
    ret
   endp   
   
  
   
 main:            ;  debut de notre programe 
    mov ax,Data   
    mov Ds,ax 
    
    mov dx,offset msg2
    mov ah,9h
    int 21H 
    ; les trois instructions sont pour afficher  un message a l'utilisateur
        
    mov dx, offset chaine 
    mov ah, 0ah
	int 21h       
	; les trois instructions sont pour lire une chaine du clavier 
	xor bx,bx     ; initialiser bx 
	mov bl, chaine[1] ; affecter dans bl le nombre des caractere car avec l'utilisation de INT 21h/0Ah
	                  ; on va obtenir dans [dx] la taille de la chaine et dans [dx + 1] le nombre de caractere lu
	                   ; et dans [dx + 2] l'offset du premier caractere de la chaine
	                    
	                     
	mov chaine[bx+2],'$' ; ajouter le caractere de fin de chaine 
	mov taille,bx    ; pour que taille contienne le nombre de caractere (la taille)
	mov x, offset chaine + 2   ; mettre dans x l'offset de debut de la chaine
    
    call contigueinverse  ;on verifie si la chaine extrainte est contigue inverse on a le resultas dans la variable testconinv
    call affichage     ;ensuite en fait appel a la procedure d'affichage pour afficher le resultat qui dependra de la variable testconinv
       
    exit:
        mov dx,offset ligne
        mov ah,9h
        int 21H
		  ;les trois instructions sont pour le saut de ligne
        mov dx,offset msg1
        mov ah,9h
        int 21H 
		  ; les trois instructions sont pour afficher  un message a l'utilisateur
        mov ah,0
        int 16h 
		  ; les trois instructions sont pour faire l'equivalent de system("pause") en langage c 
        mov ah, 4ch
        int 21h
		;les deux instructions precedante servent a arreter le programe     
		
Code ends
     end main
