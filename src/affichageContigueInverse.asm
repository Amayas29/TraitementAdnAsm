; afficher la chaine adn avec coloration des chaines contigue inverse sans affichage des tirets

Data segment
    ADN db "GCAACCGCCAACGCGTATGA-GCGCGGATGCGCGCGGATGC-TTACGCGTAAAATGCGCATT-CTTCCGCACATCCCGCTACT-GCACGATGGTACCGGTCGCC-CCTGCCATGGTGTGATCCGC-CCGCTACTGCCGTCATCGCC-AAAATAGGCGCCACAGAAAC-GCAGAGGGGAAGGGGAGACG-CGCTCCTTCGGCTTCCTCGC-GTCCGGACCGTGCTGACCCC-AAAATAGGCGCCACAGAAAC$"
    chaine db 100 dup(?); cette chaine sert a stocker la sous chaine de adn
    X dw ? ;cette variable sert a stocket l'offset de chaine[0]
    taille dw ?  ;cette variable sert a stocker la taille de sous chaine de adn
    testconinv db ? ;cette variable sert a stocker le resultas de la procedure contigueinverse elle recois 1 si contigue inverse 0 sinon
    y dw ? ;cette variable sert a stocker l'offset d'avancement dans ADN
    ligne db 0Ah,0dh,0Ah,0dh,"$" ;cette chaine sert a  faire un saut de ligne
    msg db "Veuillez cliquer sur une touche pour sortir : $" ;cette chaine represente le message de fin de programe 
Data ends

Code segment
   assume Cs:Code, Ds:Data 
   lenght proc near       ; cette procedure calcule la taille d'une chaine stocke,  dont l'offset de debut est stocker dans la variable X.
       mov cx,0          ;on initalise le compter cx a 0.
       mov si,x          ; on mov l'offset de debut de la chaine dans si.
       boucle:           ;on parcour la chaine grace a cette boucle
        cmp [si],'-'     ; si on trouve un '-' 
        je fin           ; on sort de la boucle
        cmp [si],'$'     ; ; si on trouve un une marque de fin de chaine'$' 
        je fin           ; on sort de la boucle
        inc cx           ; on incremante cx a chaque iteration pour avoir la taille de la chaine
        inc si           ;on incremante si a chaque iteration pour avancer dans la chaine
      jmp boucle         ;le jum sert a boucler
   fin:                  ; on est sortie de la boucle 
   mov taille,cx         ; on sauvgarde la taille de la chaine contenue dans cx 
    ret                  
   endp   
   
 contigueinverse  proc near ;cette procedure nous dit si la chaine dont l'offset de debut est contenue dans x est contigue inverse 
                            ;et retourne le resulat dans la variable testconinv elle recois 1 si contigue inverse 0 sinon
							
      call lenght   ;on fait appel a la procedure lenght on aura la taille de la chaine  dans la variable taille et l'offset de debut est contenue dans x
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
 
   affichage proc near ;cette procedure sert afficher la chaine dont l'offset de debut est contenue dans x en rouge si testconinv==1 en blanc sinon
      mov si,x ;on stocke l'offset de debut de chaine contenue dans x  dans le registre si
	cmp testconinv,0 ;on compare  testconinv et 0
       je affichernotcontigueinverse ;si testconinv==0 alors la chaine dont l'offset de debut est contenue dans x 
	                                 ;n'est pas contigue inverse donc on jump vers affichernotcontigueinverse
       
        
       
        
         affichagecontigueinverse:; si on a pas jumper dans l'intruction precedante  donc la chaine dont l'offset de debut est contenue dans x est contigue inverse
           mov ah,9h 
           mov bx,4
			; ces 2 instructions precedentes sont utiliser pour choisir la couleur rouge et la fonction de coloriage 
           mov cx,1 ; pour colorer un seul caractere a la fois
           int 10h ; l'interuption dont le role est de colorer
           mov dl,[si]
           mov ah,2h
           int 21h 
		     ; les trois instructions precentes servent a afficher le caractere [si]
           inc si ; on avance dans la chaine 
           dec taille ;on decrement la taille pour signifier qu'une iteration a ete faite
           cmp taille,0 ; quand on arrive a la fin de la chaine on a decrementer taille jusqu'a 0 donc on finie d'afficher la chaine 
           ja affichagecontigueinverse ;si taille > 0 donc on continue l'affichage
         
       jmp finaffichage  ; on finie le traitment donc on jump vers la fin pour ne pas entrer dans l'etiquette affichernotcontigueinverse
       
       affichernotcontigueinverse: ; si on arive dans cette etiquette la donc la chaine n'est pas contigue inverse on affiche en blanc
         mov cx,taille            ;on initialise le compteur cx a taille de la chaine 
         afficher:               ; cette boucle permet d'afficher la chaine caractere pas caractere 
           mov dl,[si]
           mov ah,2h
           int 21h
		     ;les 3 instructions precedente servent a afficher le caractere contenue dans si
           inc si   ; on avance dans la chaine 
         loop afficher   ; on retourne a la chaine tantque cx =/= 0
       
    finaffichage:;etiquette pour finir et sortir de la procedure 
    ret
   endp   
   
   extrairechaine proc near ;cette procedure sert a extraire une sous chaine et de la mettre dans la variable chaine 
      mov si,y    ; y represente notre avancment dans la grand chaine adn  on le mov dans le registre si 
      mov bx,0    ; on initialise bx a 0 sa sera l'indice de la chaine extraite  (adressage base)
      aller:              ;on fait une une boucle conditionelle pour extraire la sous chaine     
        cmp [si],'-'     ; on compare le contenue de si  avec le '-'
        je sortrir      ; si [si] == '-'  donc la sous chaine est finie donc on jump vers la sorite
        cmp [si],'$'  ;on compare le contenue de si  avec le '$'
        je sortrir   ; si [si] == '$'donc la sous chaine est finie donc on jump vers la sorite
                                                         
        mov al,[si] ; on copie le caracter contenu dans si ([si]) dans le registre al  (al car sur 8b)
        mov chaine[bx],al ; on copie le contenue de al dans (l'offset de chaine + [bx] adressage base)
        inc si     ; on anvance dans la chaine adn 
        inc bx    ; on increment l'indice de notre chaine extraite 
        jmp aller ; si on est ariver vers cette instruction donc reboucle 
             
     sortrir:
        mov y,si ; on sauvgarde notre avancement dans la chaine adn dans la variable y
        mov chaine[bx],"$"  ;  ; on introduis une marque de fin de chaine a notre chaine extraite
   ret
   endp          
   
 main:            ;  debut de notre programe 
    mov ax,Data   
    mov Ds,ax
    mov y,offset ADN[0] ; on initialise y a l'offset de debut de adn car dans notre programe il representra l'avencment dans la chaine adn 
    
    boucleADN:       ; pour traiter toute les sous chaine de adn 
        call extrairechaine  ;on fait appel a extrairechaine, elle mets la sous chaine dans la variable chaine 
        mov x,offset chaine[0]; x recois l'offset de debut de la chaine extraite 
        call contigueinverse  ; on verifie si la chaine extrainte est contigue inverse on a le resultas dans la variable testconinv
        call affichage       ; ensuite en fait appel a la procedure d'affichage pour afficher la sous chaine,la couleur dependra de la variable testconinv
        mov si,y           ; on copie le y dans le registre si on a deux cas sois [si]=="-" ou [si]=="$"
        cmp [si],"$"      ; on compare [si] avec "$"
        je exit          ; si [si] == "$" donc on a traiter l'intergralite de adn donc on peut terminer le programe
               ; sinon donc il reste des sous chaine a traiter   
           
        inc y       ; on incremente y pour tomber dans l'offset ou commence la prochaine sous chaine de adn 
        jmp boucleADN ; si on arive a cette instruction donc on a pas terminer le programe alors on reboucle 
        

    exit:
        mov dx,offset ligne
        mov ah,9h
        int 21H
		  ;les trois instructions sont pour le saut de ligne
        mov dx,offset msg
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