<#//
#==========================================================================
# SCRIPT ..........: 
# AUTHOR ..........: Adrien GODET - godet.adrien@outlook.fr
# DATE (YYYY/MM/DD): 09/12/2019
# VERSION .........: 1.0
#==========================================================================
# COMPANY .........: Personnel
# PURPOSE .........: Script d'installation via un fichier XML
# DEPENDANCES .....: Aucune
# COMMENTS ........: Aucun
# LIMITS ..........: Aucune
# PREREQUISITES ...: Aucun
#
#==========================================================================
# RELEASE HISTORY
# 1.0 (09/12/2019): Version initiale
#==========================================================================
# ERROR CODE
# 999000 : Fichier XML Introuvable ou manquant
# 999001 : Le contenu du fichier comporte des erreurs
# 999011 : Erreur lors du traintement de l'installation. 
# 999021 : Erreur lors du traitement de la fonction d'ajout de fichier 
# 99990211 : Le type de création reporté n'est pas reconnu (Seul les types File et Directory sont valides)
# 99990212 : La création de l'élément pour l'utilisateur par défaut a retournée une erreur. 
# 99990213 : La création de l'élément pour les utilisateurs existant a retournée une erreur. 
# 99990214 : La création de l'élément unique a retournée une erreur. 
# 999022 : Erreur lors du traintement de la fonction d'ajout de clé de registre.
# 9990221 : Erreur lors du traintement de la fonction d'ajout de clé de registre.
# 999023 : Erreur lors du traintement de la fonction de suppression de fichier
# 999024 : Erreur lors du traintement de la fonction de suppression de clé de registre. 
# 999025 : Erreur lors du traintement de la fonction de copy de fichiers
# 999026 : Erreur lors du traintement de la fonction de copy de dossiers
# 999027 : Erreur lors du traintement de la fonction de déplacement de fichiers / Dossiers 
# 999028 : Erreur lors du traintement de la fonction de renommage de fichier
# 999029 : Erreur lors du traintement de la fonction de renommage de clé de registre
# 999030 : Erreur lors du traintement de la fonction d'execution de commande
# 999031 : Erreur lors du traintement de la fonction de configuration de service
# 999034 : Erreur lors du traintement de la fonction de suppression de tâche planIFiée
# 999035 : Erreur lors du traintement de la fonction de création de tâche planIFiée
# 999036 : Erreur lors du traintement de la fonction de désactivation de tâche planIFiée
#>


###############################################################################################################
# Paramètre
###############################################################################################################

    param(
        [string]$xmlfile, #= $(throw "Le paramètre xmlfile est obligatoire."),        
        [switch]$debug,
        # Définition du dossier par défaut dans le répertoire du script
        [string]$v_LogDir=[System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
    ) 

###############################################################################################################
# Variables
###############################################################################################################
    ### Variable permettant le calcul du temps d'éxecution du script. 
    $StartTime = Get-Date

    ### Logging
    # Définition du nom du fichier de log : YYYY-MM-DD-<Nom du script>.log
    $v_LogPathfile = $v_LogDir + "\" + (Get-Date -Format yyyy-MM-dd) + "-" + $myInvocation.MyCommand.Name.replace(".ps1",".log")

    $debug = $true
    $xmlfile="7zip.xml"
    $erroraction='Stop'

###############################################################################################################
# Fonctions de packaging
###############################################################################################################

    #Fonction Done
    function Addfile {

        Try {
            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action d'ajout de fichier"    
            #Récupération des actions à effectuer. 
            $xml.Package.$Phaserun.$TypeRun.AddFile.ChildNodes.Name | ForEach-Object -Process {

                #Mise en variable des éléments
                $ItemPath = $xml.Package.$Phaserun.$TypeRun.AddFile.$_.Path
                $ItemType = $xml.Package.$Phaserun.$TypeRun.AddFile.$_.Type
                $ItemValue = $xml.Package.$Phaserun.$TypeRun.AddFile.$_.Value
                $ItemName = $xml.Package.$Phaserun.$TypeRun.AddFile.$_.Itemname
                $ItemAllUsers = $xml.Package.$Phaserun.$TypeRun.AddFile.$_.AllUsers
                $ItemExclude = $xml.Package.$Phaserun.$TypeRun.AddFile.$_.Exclude

                Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Determination de l'action à effectuer"
                #Traitement pour un fichier
                IF ($ItemType -eq "File") {

                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "La création concerne un fichier"
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Determination du scope de la création"
                    
                    IF ($ItemAllUsers -eq "True"){
                        #Traitement pour tous les utilisateurs 
                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "La création concerne tous les utilisateurs"
                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Création du Fichier $ItemPath"
                        
                        #Argument de la création de fichier pour l'utilisateur par défaut 
                        $NewdefaultItemFileParams = @{
                            Path            = "C:\Users\Default\" + $ItemPath
                            Name            = $ItemName
                            ItemType        = $ItemType
                            Value           = $ItemValue
                            Force           = $true
                            ErrorAction     = $erroraction
                        }

                        try {
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Configuration environnement de l'utilisateur par défaut "
                            New-Item @NewdefaultItemFileParams | Out-Null 
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "Done"
                        }catch {
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur lors de la création de fichier pour le profil utilisateur par défaut"  
                            Exit-Error -Exitcode 99990212
                        }
                        

                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Configuration environnement utilisateur existant"

                        IF ($null -ne $ItemExclude) {
                            Get-ChildItem "C:\Users\" -Exclude $ItemExclude | ForEach-Object {
                                #Argument de la création de fichier pour tous les utilisateurs Existant sauf ceux spécifié
                                $NewAllUsersItemFileParams = @{
                                    Path            = "$_\" + $ItemPath
                                    Name            = $ItemName
                                    ItemType        = $ItemType
                                    Value           = $ItemValue
                                    Force           = $true
                                    ErrorAction     = $erroraction
                                }

                                try {
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "  - Configuration environnement de l'utilisateur $_ "
                                    New-Item @NewAllUsersItemFileParams | Out-Null 
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "  - Done"
                                }catch {
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur lors de la création de fichier pour les utilisateurs existant"  
                                    Exit-Error -Exitcode 99990213
                                }
                                
                            }

                        }Else{
                            Get-ChildItem "C:\Users\" | ForEach-Object {
                                #Argument de la création de fichier pour tous les utilisateurs
                                $NewAllUsersItemFileParams = @{
                                    Path            = "$_\" + $ItemPath
                                    Name            = $ItemName
                                    ItemType        = $ItemType
                                    Value           = $ItemValue
                                    Force           = $true
                                    ErrorAction     = $erroraction
                                }

                                try {
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "  - Configuration environnement de l'utilisateur $_ "
                                    New-Item @NewAllUsersItemFileParams | Out-Null 
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "  - Done"
                                }catch {
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur lors de la création de fichier pour les utilisateurs existant"  
                                    Exit-Error -Exitcode 99990213
                                }
                                
                            }
                        }

                    }else{
                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "La création est seulement pour un emplacement défini"
                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Création du Fichier $ItemPath"

                        #Argument de la création de fichier

                        $NewItemFileParams = @{
                            Name            = $ItemName
                            Path            = $ItemPath
                            ItemType        = $ItemType
                            Value           = $ItemValue
                            Force           = $true
                            ErrorAction     = $erroraction
                        }

                        try {
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Création du fichier "
                            New-Item @NewItemFileParams | Out-Null
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "Done"
                        }catch {
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur lors de la création du fichier"  
                            Exit-Error -Exitcode 99990214
                        }
                    }

                }ELSEIF($ItemType -eq "directory") {

                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "La création concerne un Dossier"
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Determination du scope de la création"

                    IF ($ItemAllUsers -eq "True"){

                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "La création concerne tous les utilisateurs"
                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Création du Dossier $ItemPath"
                        
                        #Argument de la création de fichier pour l'utilisateur par défaut 
                        $NewItemDirectoryDefaultParams = @{
                            Name            = $ItemName
                            Path            = "C:\Users\Default\" + $ItemPath
                            ItemType        = $ItemType
                            Force           = $true
                            ErrorAction     = $erroraction
                         }
                        
                         try {
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Configuration environnement de l'utilisateur par défaut "
                            New-Item @NewItemDirectoryDefaultParams | Out-Null 
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "Done"
                        }
                        catch {
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur lors de la création du dossier pour le profil utilisateur par défaut"  
                            Exit-Error -Exitcode 99990212
                        }
                        
                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Configuration environnement utilisateur existant"
                        IF ($null -ne $ItemExclude) {
                            Get-ChildItem "C:\Users\" -Exclude $ItemExclude | ForEach-Object {
                                #Argument de la création de fichier pour tous les utilisateurs Existant sauf ceux spécifié
                                $NewItemDirectoryAllUsersParams = @{
                                    Path            = "$_\" + $ItemPath
                                    Name            = $ItemName
                                    ItemType        = $ItemType
                                    Force           = $true
                                    ErrorAction     = $erroraction
                                }

                                try {
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Configuration environnement de l'utilisateur $_ "
                                    New-Item @NewItemDirectoryAllUsersParams | Out-Null
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "Done"
                                }
                                catch {
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur lors de la création du dossier pour les utilisateurs existant"  
                                    Exit-Error -Exitcode 99990213
                                }
                                
                            }

                        }Else{
                            Get-ChildItem "C:\Users\" | ForEach-Object {
                                #Argument de la création de fichier pour tous les utilisateurs
                                $NewItemDirectoryAllUsersParams = @{
                                    Path            = "$_\" + $ItemPath
                                    Name            = $ItemName
                                    ItemType        = $ItemType
                                    Value           = $ItemValue
                                    Force           = $true
                                    ErrorAction     = $erroraction
                                }

                                try {
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Configuration environnement de l'utilisateur $_ "
                                    New-Item @NewItemDirectoryAllUsersParams | Out-Null 
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "Done"
                                }
                                catch {
                                    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur lors de la création du dossier pour les utilisateurs existant"  
                                    Exit-Error -Exitcode 99990213
                                }
                                
                            }
                        }

                    }ELSE{

                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "La création est seulement pour un emplacement défini"
                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Création du Dossier $ItemPath"

                        #Argument de la création de dossier
                        $NewItemDirectoryParams = @{
                            Name            = $ItemName
                            Path            = $ItemPath
                            ItemType        = $ItemType
                            Force           = $true
                            ErrorAction     = $erroraction
                        }
                        
                         try {
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Création du Dossier à l'unique emplacement"
                            New-Item @NewItemDirectoryParams | Out-Null 
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "Done"
                        }
                        catch {
                            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur lors de la création du dossier"  
                            Exit-Error -Exitcode 99990214
                        }

                    }

                }ELSE{

                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel ERROR -v_Message  "Type de création non reconnu : $ItemType"
                        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Le type de fichier spécifié est inconnu : $ItemType"  
                        Exit-Error -Exitcode 99990211
                    }
                }       
        }Catch{
            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur de l'action d'ajout de fichier"  
            Exit-Error -Exitcode 9999021
        }   
    }

    #Fonction Done
    function AddReg {
        Try {
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action d'ajout de clé de registre"    
            #Récupération des actions à effectuer. 
            $xml.Package.$Phaserun.$TypeRun.AddReg.ChildNodes.Name | ForEach-Object -Process {

                #Mise en variable de la clé à creer à supprimer.        
                $AddRegPath = $xml.Package.$Phaserun.$TypeRun.AddReg.$_.Path
                $AddRegName = $xml.Package.$Phaserun.$TypeRun.AddReg.$_.RegName
                $AddRegValue = $xml.Package.$Phaserun.$TypeRun.AddReg.$_.Value
                $AddRegType = $xml.Package.$Phaserun.$TypeRun.AddReg.$_.PropertyType
                $regkey = $AddRegPath + "\" + $AddRegName
                Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Ajout de la clé de registre : $regkey"
                
                #Argument de la création du paramètre de clé
                $NewitempropertyParams = @{
                    Path            = $AddRegPath
                    Name            = $AddRegName
                    PropertyType    = $AddRegType
                    Value           = $AddRegValue
                    Force           = $true
                    ErrorAction     = $erroraction
                }
                #Argument de la création de la clé
                $NewitemParams = @{
                    Path            = $AddRegPath
                    Force           = $true
                    ErrorAction     = $erroraction
                }
                Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Vérification de la présence de la clé $AddRegPath"
                IF(!(Test-Path $AddRegPath)){
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "la clé $AddRegPath n'existe pas, début de la création"
                    New-Item @NewitemParams | Out-Null
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Done"
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Début de la création de la propriété $Addregname"
                    New-ItemProperty @NewitempropertyParams | Out-Null
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Done"
                } ELSE {
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "la clé $AddRegPath existe, début de la création de la propriété $addregname"
                    New-ItemProperty @NewitempropertyParams | Out-Null
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Done"
                }
                
                Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Done"
                Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "Done"
            }
        } Catch {
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel ERROR -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur de l'action" 
            Exit-Error -Exitcode 9999022
        }
        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }
    #Fonction Done
    function AddRegFile {
        Try {
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'import de clé de registre"    
            #Récupération des actions à effectuer. 
            $xml.Package.$Phaserun.$TypeRun.AddRegFile.ChildNodes.Name | ForEach-Object -Process {

                #Mise en variable du fichier à intégrer.        
                $AddRegFilePath = $xml.Package.$Phaserun.$TypeRun.AddRegFile.$_.Path
                Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Fusion de clé de registre via le fichier : $AddRegFilePath"
                
                #Vérification de la présence du fichier de log.
                IF (Test-path "$AddRegFilePath") {
                    $startprocessParams = @{
                        FilePath     = "$Env:SystemRoot\REGEDIT.exe"
                        ArgumentList = '/s',"`"$AddRegFilePath`""
                        Wait         = $true
                        PassThru     = $true
                        ErrorAction  = $erroraction
                    }
                    #Commande d'ajout de fichier reg
                    Start-Process @startprocessParams 
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Done"
                } ELSE {
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel ERROR -v_Message  "Le fichier .reg est introuvable. : $AddRegFilePath"
                }
                Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "Done"
            }
        } Catch {
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel ERROR -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
            Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur de l'action" 
            Exit-Error -Exitcode 99990221
        }
        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"
    }

    #Fonction Done
    function RemoveFile {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de suppression de fichier"    

    #Récupération des actions à effectuer. 
    $xml.Package.$Phaserun.$TypeRun.RemoveFile.ChildNodes.Name | ForEach-Object -Process {

        #Mise en variable du fichier à supprimer.        
        $removeFilePath = $xml.Package.$Phaserun.$TypeRun.RemoveFile.$_.path
        $removerecursive = $xml.Package.$Phaserun.$TypeRun.RemoveFile.$_.recursive

        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Suppression du fichier $removeFilePath"
            
        #Commande de suppression de clé de registre.        
        IF (Test-path $removeFilePath) {
            #Vérification si le paramètre recursive à été spécifié. sinon suppression classique. 
            IF ($removerecursive -eq "True") {
                $removeitemParams   = @{
                    Path            = $removeFilePath 
                    Recurse         = $true
                    ErrorAction     = $erroraction
                }
                Remove-Item @removeitemParams 
            } ELSE {
                $removeitemParams   = @{
                    Path            = $removeFilePath 
                    ErrorAction     = $erroraction
                }
                Remove-Item @removeitemParams 
            }
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Done"
        } ELSE {
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel WARN -v_Message  "Le fichier n'est actuellement pas présent sur le système"
        }
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel SUCCESS -v_Message "Done"    
    }       
    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel ERROR -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999023
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"
    }

    #Fonction Done
    function RemoveReg {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de suppression de clé de registre"    

    #Récupération des actions à effectuer. 
    $xml.Package.$Phaserun.$TypeRun.RemoveReg.ChildNodes.Name | ForEach-Object -Process {
        #Mise en variable de la clé à supprimer.         
        $removereg = $xml.Package.$Phaserun.$TypeRun.RemoveReg.$_.path
        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Suppression de la clé $removereg"

        #Commande de suppression de clé de registre.         
        IF (Test-path $removereg) {
            $removeitemParams = @{
                Path            = $removereg
                Recurse         = $true
                Force           = $true
                ErrorAction     = $erroraction
            }
            Remove-Item @removeitemParams
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Done"
        } ELSE {
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel WARN -v_Message  "La clé de registre n'est actuellement pas présente sur le système"
        }
    } 
    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel ERROR -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999024
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel SUCCESS -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"
    }

    function CopyFolder {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel INFO -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de Copy de Dossier"    

            

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBERRORUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999025
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

    function CopyFile {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de copy de fichier"    

            

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999026
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

    function MoveFile {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de déplacement de fichier"    

            

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999027
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

    function RenameFile {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de renommage de fichier"    

            

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999028
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

    function RenameReg {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de renommage de clé de registre"    

            

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999029
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

    function Execute {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action d'execution de commande"    

            

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999030
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

    function SetService {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action d'arret de service"    

    set-service -name gupdatem -startuptype manual

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999031
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

    function RemoveTask {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de suppresion de tâche planIFiée"    

    Unregister-ScheduledTask -TaskName GoogleUpdateTaskMachineCore -Confirm:$false       

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999034
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

    function CreateTask {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de création de tâche planIFiée"    

            

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999035
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

    function DisableTask {
    Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Execution de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Execution de l'action de désactivation de tâche planIFiée"    

            

    } Catch {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Erreur de la fonction $_ dans la phase $PhaseRun"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Erreur de l'action" 
    Exit-Error -Exitcode 9999036
    }
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Success de la fonction $_ dans la phase $PhaseRun"

    }

###############################################################################################################
# Fonction Commune
###############################################################################################################

    Function Write-Log(
        [string[]]$v_Message, [string]$v_Logfile, 
        [switch]$v_ConsoleOutput, 
        [ValidateSet("SUCCESS", "INFO", "WARN", "ERROR", "DEBUG")]
        [string]$v_LogLevel) {
        IF (!$v_LogLevel) { $v_LogLevel = "INFO" }

            switch ($v_LogLevel) {
            SUCCESS { $v_Color = "Green" } 
            INFO { $v_Color = "White" } 
            WARN { $v_Color = "Yellow" } 
            ERROR { $v_Color = "Red" } 
            DEBUG { $v_Color = "Gray" } 
        }

        IF ($null -ne $v_Message -and $v_Message.Length -gt 0) { 

            $v_TimeStamp = [System.DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")

            IF ($v_Logfile -ne $null -and $v_Logfile -ne [System.String]::Empty) {
                Out-File -Append -FilePath $v_Logfile -InputObject "[$v_TimeStamp] [$v_LogLevel] $v_Message"
            }

            IF ($v_ConsoleOutput -eq $true){
                Write-Host "[$v_TimeStamp] [$v_LogLevel] :: $v_Message" -ForegroundColor $v_Color 
            } 

            IF ($debug -eq $true){
                Write-Host "[$v_TimeStamp] [$v_LogLevel] :: $v_Message" -ForegroundColor $v_Color 
            }

        }
    }

    Function Exit-Error ($Exitcode) {
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "***Fin du script en erreur : $Exitcode***"
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "----------------------------------------------------------------------------------------------------------------------------"
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "***Détail de l'erreur***"
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "----------------------------------------------------------------------------------------------------------------------------"
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "$_"
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "----------------------------------------------------------------------------------------------------------------------------"
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "***Fin de l'erreur***"
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "----------------------------------------------------------------------------------------------------------------------------"
        $StopTime = Get-Date
        $TempsEcoulee=((Get-Date $StopTime) - (Get-Date $StartTime)).tostring()
        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel ERROR -v_Message  "***Executé en $TempsEcoulee !***"
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "***Executé en $TempsEcoulee !***"
        exit $Exitcode
    }
###############################################################################################################
# Run 
###############################################################################################################

#DEBUT
Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "*** Début du script ! ***"
#Révision des variables 
Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Révision des varaibles ! `n
------------------------------------------------------------------------------------------------------------------------
Dossier emplacement des log : $v_LogDir `n
Nom complet du fichier de logs : $v_LogPathfile `n
Fichier XML renseigné : $xmlfile `n
Variable de debugage : $debug `n
----------------------------------------------------------------------------------------------------------------------- `n
"

#Validation du chemin fichier XML
$v_xmlfullpath=$PSScriptRoot + "\" + $xmlfile
Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Test du fichier XML !"
Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Le fichier XML est $xmlfile ou $v_xmlfullpath !"

IF ((-not (Test-Path -Path "$v_xmlfullpath" -PathType Leaf)) -or ((-not (Test-Path -Path "$xmlfile" -PathType Leaf))) ) {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Le fichier XML introuvable !"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "Le fichier XML renseigné est introuvable"
    Exit-Error -Exitcode 999000
}

#Validation et récupération du fichier XML
Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Récupération de contenu du fichier xml"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message " Récupération de contenu du fichier xml"    

    [XML]$Xml= Get-Content -Path $xmlfile -ErrorAction SilentlyContinue

    IF($Error.Count -ne 0){ 
        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Récupération de contenu du fichier xml par son chemin complet si non renseigné"

        [XML]$Xml= Get-Content -Path $v_xmlfullpath -ErrorAction SilentlyContinue
    }


} Catch {
    Exit-Error -Exitcode 9999001
}


# RUN 

#################################
#Execution des dIFférents noeuds
#################################

### VérIFication et execution des prérequis 

$Phase = "PRE","RUN","POST"
$type = "File","REG","CMD"
#$Action = "AddFile","AddReg","RemoveFile","RemoveReg","CopyFolder","CopyFile","MoveFile","RenameFile","RenameReg","Install","Uninstall"

Try {
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Lancement de l'installation"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Lancement de l'installation"
    $PhaseXml=$xml.Package.ChildNodes.Name 
    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Phase actuellement présente dans le fichier XML : $PhaseXml "
    $Phase | ForEach-Object -Process {
        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message "Traitement de la phase $_"
        IF ($xml.Package.ChildNodes.Name -eq $_){
            $Phaserun=$_
            $TypeXml=$xml.Package.$Phaserun.ChildNodes.Name 
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message "Traitement de la phase $PhaseRun"
            Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Type d'action actuellement présente dans le fichier XML : $typeXml"
            $type | ForEach-Object -Process {
                IF ($xml.Package.$Phaserun.ChildNodes.Name -eq $_){
                    $TypeRun=$_
                    $TaskXml=$xml.Package.$Phaserun.$TypeRun.ChildNodes.Name 
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message "Traitement du type d'action $TypeRun"
                    Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Type d'action actuellement présente dans le fichier XML : $TaskXml"
                    $xml.Package.$Phaserun.$TypeRun.ChildNodes.Name | ForEach-Object -Process {
                        Write-Log -v_LogFile $v_LogPathfile  -v_LogLevel DEBUG -v_Message  "Traitement de l'action : $_"
                        IF ($_ -eq "Addfile"){Addfile}
                        IF ($_ -eq "AddReg"){AddReg}
                        IF ($_ -eq "AddRegFile"){AddRegFile}
                        IF ($_ -eq "RemoveFile"){RemoveFile}
                        IF ($_ -eq "RemoveReg"){RemoveReg}
                        IF ($_ -eq "CopyFolder"){CopyFolder}
                        IF ($_ -eq "CopyFile"){CopyFile}
                        IF ($_ -eq "MoveFile"){MoveFile}
                        IF ($_ -eq "RenameFile"){RenameFile}
                        IF ($_ -eq "RenameReg"){RenameReg}
                        IF ($_ -eq "SetService"){SetService}
                        IF ($_ -eq "CreateTask"){CreateTask}
                        IF ($_ -eq "RemoveTask"){RemoveTask}
                        IF ($_ -eq "DisableTask"){DisableTask}
                        IF ($_ -eq "Execute"){Execute}
                          }
                    }
                }
            }  
        }  
    }



Catch {
    Exit-Error -Exitcode 9999011
}

# FIN 
    $StopTime = Get-Date
    $TempsEcoulee=((Get-Date $StopTime) - (Get-Date $StartTime)).tostring()
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "*** Fin du script ! ***"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "***Executé en $TempsEcoulee !***"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "----------------------------------------------------------------------------------------------------------------------------"


#Try {
#    IF (-not (Test-Path -Path (Split-Path -Parent $LogFile) -PathType Container -ErrorAction Stop)) {
#        New-Item -Path (Split-Path -Parent $LogFile) -ItemType Directory -ErrorAction Stop | Out-Null -ErrorAction Stop
#    }
#} Catch {
#    Exit-Error -Exitcode 9999001
#}