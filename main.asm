.data
    employes: .space 1000           
    nb_empl: .word 0           
    id_empl: .asciiz "Veuillez entrez l'ID de l'employe : "
    nom_empl: .asciiz "Veuillez entrez le nom de l'employe : "
    salaire: .asciiz "Veuillez entrez le salaire de l'employe : "
    menu: .asciiz "\nMenu :\n1. Ajouter un employe\n2. Afficher la liste\n3. Rechercher un employe\n4. Calculer le salaire min, max, moyen\n5. Quitter\nVotre Choix : "

    msg_empl_ajoute: .asciiz "Employe ajoute avec succes.\n"
    msg_empl_non_trouve: .asciiz "Employe non trouve.\n"
    msg_salaire_min: .asciiz "Salaire minimum : "
    msg_salaire_max: .asciiz "Salaire maximum : "
    msg_salaire_moyen: .asciiz "Salaire moyen : "
    nouvelle_ligne: .asciiz "\n"

.text
.globl main

main:
    # Boucle principale du menu
menu_loop:
    li $v0, 4               
    la $a0, menu
    syscall

    li $v0, 5               
    syscall
    move $t0, $v0

    beq $t0, 1, ajouter_employe
    beq $t0, 2, afficher_liste
    beq $t0, 3, rechercher_employe
    beq $t0, 4, calculer_statistiques
    beq $t0, 5, quitter
    j menu_loop

ajouter_employe:
    # Lire l'ID
    li $v0, 4
    la $a0, id_empl
    syscall

    li $v0, 5
    syscall
    move $t1, $v0          

    
    lw $t2, nb_empl    
    mul $t3, $t2, 20
    la $t4, employes       
    add $t4, $t4, $t3     

    sw $t1, 0($t4)         # Stockage de l'ID

    # Lire le nom
    li $v0, 4
    la $a0, nom_empl
    syscall

    addi $a0, $t4, 4       
    li $v0, 8              
    li $a1, 12             
    syscall

    # Lire le salaire
    li $v0, 4
    la $a0, salaire
    syscall

    li $v0, 5
    syscall
    sw $v0, 16($t4)        

    # Incrementer le nombre d'employes
    lw $t2, nb_empl        
    addi $t2, $t2, 1
    sw $t2, nb_empl           # Confirmation
    li $v0, 4
    la $a0, msg_empl_ajoute
    syscall

    j menu_loop            

afficher_liste:
    lw $t0, nb_empl        
    beqz $t0, menu_loop    
    
    la $t1, employes       
    li $t2, 0              

afficher_boucle:
    beq $t2, $t0, menu_loop    

    # Affichage de l'ID
    lw $a0, 0($t1)         
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, nouvelle_ligne
    syscall

    # Affichage du nom
    addi $a0, $t1, 4       
    li $v0, 4
    syscall

    # Affichage du salaire
    lw $a0, 16($t1)        
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, nouvelle_ligne
    syscall

    addi $t1, $t1, 20      
    addi $t2, $t2, 1       
    j afficher_boucle

rechercher_employe:
    li $v0, 4
    la $a0, id_empl
    syscall

    li $v0, 5
    syscall
    move $t0, $v0          

    lw $t1, nb_empl        
    beqz $t1, recherche_non_trouve

    la $t2, employes       
    li $t3, 0              

recherche_boucle:
    beq $t3, $t1, recherche_non_trouve    

    lw $t4, 0($t2)         
    beq $t4, $t0, trouve   

    addi $t2, $t2, 20      
    addi $t3, $t3, 1
    j recherche_boucle

trouve:
    addi $a0, $t2, 4       # Afficher le nom
    li $v0, 4
    syscall

    lw $a0, 16($t2)        # Afficher le salaire
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, nouvelle_ligne
    syscall

    j menu_loop

recherche_non_trouve:       
    li $v0, 4
    la $a0, msg_empl_non_trouve
    syscall
    j menu_loop

calculer_statistiques:
    lw $t0, nb_empl        
    beqz $t0, menu_loop    

    la $t1, employes       
    lw $t2, 16($t1)        
    move $t3, $t2          
    move $t4, $t2          
    li $t5, 1              
    addi $t1, $t1, 20      

statistiques_boucle:
    beq $t5, $t0, statistiques_fin

    lw $t6, 16($t1)       

    # Min
    blt $t6, $t2, nouveau_min
    j verif_max
nouveau_min:
    move $t2, $t6

verif_max:
    # Max
    bgt $t6, $t3, nouveau_max
    j continue_stats
nouveau_max:
    move $t3, $t6

continue_stats:
    add $t4, $t4, $t6      
    addi $t1, $t1, 20      
    addi $t5, $t5, 1       
    j statistiques_boucle

statistiques_fin:
    # Afficher min
    li $v0, 4
    la $a0, msg_salaire_min
    syscall
    move $a0, $t2
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, nouvelle_ligne
    syscall

    # Afficher max
    li $v0, 4
    la $a0, msg_salaire_max
    syscall
    move $a0, $t3
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, nouvelle_ligne
    syscall

    # Calculer et afficher moyenne
    div $t4, $t0           # Division par nombre d'employés
    mflo $t4               # Récupérer le quotient

    li $v0, 4
    la $a0, msg_salaire_moyen
    syscall
    move $a0, $t4
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, nouvelle_ligne
    syscall

    j menu_loop

quitter:
    li $v0, 10
    syscall