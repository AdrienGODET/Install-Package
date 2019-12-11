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
#>


###############################################################################################################
# Paramètre
###############################################################################################################

    param(
        [string]$xmlfile, #= $(throw "Le paramètre xmlfile est obligatoire."),        
        [string]$debug="false",
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

    #
    $xmlfile="7zip.xml"
    $debug="true"

###############################################################################################################
# Fonctions Communes
###############################################################################################################

    function Addfile {
      Write-Host "Function Start Addfile" $xml.Package.$Phaserun.$TypeRun.$_.ChildNodes.Name 
    }

    function AddReg {
        Write-Host "Function Start AddReg"
      }

      function RemoveFile {
        Write-Host "Function Start RemoveFile"
      }

      function RemoveReg {
        Write-Host "Function Start RemoveReg"
      }

      function CopyFolder {
        Write-Host "Function Start CopyFolder"
      }

      function CopyFile {
        Write-Host "Function Start CopyFile"
      }

      function MoveFile {
        Write-Host "Function Start MoveFile"
      }
  
      function RenameFile {
        Write-Host "Function Start RenameFile"
      }

      function RenameReg {
        Write-Host "Function Start RenameReg"
      }

      function Execute {
        Write-Host "Function Start test"
      }

      

    Function Write-Log(
        [string[]]$v_Message, [string]$v_Logfile, 
        [switch]$v_ConsoleOutput, 
        [ValidateSet("SUCCESS", "INFO", "WARN", "ERROR", "DEBUG")]
        [string]$v_LogLevel) {
        If (!$v_LogLevel) { $v_LogLevel = "INFO" }

            switch ($v_LogLevel) {
            SUCCESS { $v_Color = "Green" } 
            INFO { $v_Color = "White" } 
            WARN { $v_Color = "Yellow" } 
            ERROR { $v_Color = "Red" } 
            DEBUG { $v_Color = "Gray" } 
        }

        if ($null -ne $v_Message -and $v_Message.Length -gt 0) { 

            $v_TimeStamp = [System.DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")

            if ($v_Logfile -ne $null -and $v_Logfile -ne [System.String]::Empty) {
                Out-File -Append -FilePath $v_Logfile -InputObject "[$v_TimeStamp] [$v_LogLevel] $v_Message"
            }

            if ($v_ConsoleOutput -eq $true){
                Write-Host "[$v_TimeStamp] [$v_LogLevel] :: $v_Message" -ForegroundColor $v_Color 
            } 

        }
    }

    Function Exit-Error ($Exitcode) {
        IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel ERROR -v_Message  "Fin du script en erreur : $Exitcode" }
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
        Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "***Executé en $TempsEcoulee !***"
        exit $Exitcode
    }

###############################################################################################################
# Run 
###############################################################################################################

#DEBUT
IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Execution du script en mode DEBUG !" }
Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "*** Début du script ! ***"
#Révision des variables 
IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Révision des varaibles ! `n
------------------------------------------------------------------------------------------------------------------------
Dossier emplacement des log : $v_LogDir `n
Nom complet du fichier de logs : $v_LogPathfile `n
Fichier XML renseigné : $xmlfile `n
Variable de debugage : $debug `n
----------------------------------------------------------------------------------------------------------------------- `n
"
}

#Validation du chemin fichier XML
$v_xmlfullpath=$PSScriptRoot + "\" + $xmlfile
IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Test du fichier XML !" }
IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Le fichier XML est $xmlfile ou $v_xmlfullpath !" }

If ((-not (Test-Path -Path "$v_xmlfullpath" -PathType Leaf)) -or ((-not (Test-Path -Path "$xmlfile" -PathType Leaf))) ) {
    IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Le fichier XML introuvable !" }
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel ERROR -v_Message  "Le fichier XML renseigné est introuvable"
    Exit-Error -Exitcode 999000
}

#Validation et récupération du fichier XML
Try {
    IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Récupération de contenu du fichier xml" }
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message " Récupération de contenu du fichier xml"    

    [XML]$Xml= Get-Content -Path $xmlfile -ErrorAction SilentlyContinue

    IF($Error.Count -ne 0){ 
        IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Récupération de contenu du fichier xml par son chemin complet si non renseigné" }

        [XML]$Xml= Get-Content -Path $v_xmlfullpath -ErrorAction SilentlyContinue
    }


} Catch {
    Exit-Error -Exitcode 9999001
}


# RUN 

#################################
#Execution des différents noeuds
#################################

### Vérification et execution des prérequis 

$Phase = "PRE","RUN","POST"
$type = "File","REG","CMD"
#$Action = "AddFile","AddReg","RemoveFile","RemoveReg","CopyFolder","CopyFile","MoveFile","RenameFile","RenameReg","Install","Uninstall"

Try {
    IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Lancement de l'installation" }
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message "Lancement de l'installation"
    $PhaseXml=$xml.Package.ChildNodes.Name
    IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Phase actuellement présente dans le fichier XML : $PhaseXml " }
    $Phase | ForEach-Object -Process {
        IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message "Traitement de la phase $_" }
        IF ($xml.Package.ChildNodes.Name -eq $_){
            $Phaserun=$_
            $TypeXml=$xml.Package.$Phaserun.ChildNodes.Name
            IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message "Traitement de la phase $PhaseRun"}
            IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Type d'action actuellement présente dans le fichier XML : $typeXml"}
            $type | ForEach-Object -Process {
                IF ($xml.Package.$Phaserun.ChildNodes.Name -eq $_){
                    $TypeRun=$_
                    $TaskXml=$xml.Package.$Phaserun.$TypeRun.ChildNodes.Name
                    IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message "Traitement du type d'action $TypeRun"}
                    IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Type d'action actuellement présente dans le fichier XML : $TaskXml"}
                    $xml.Package.$Phaserun.$TypeRun.ChildNodes.Name
                    $xml.Package.$Phaserun.$TypeRun.ChildNodes.Name | ForEach-Object -Process {
                        IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Traitement de l'action : $_"}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "Addfile"){Addfile}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "AddReg"){AddReg}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "RemoveFile"){RemoveFile}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "RemoveReg"){RemoveReg}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "CopyFolder"){CopyFolder}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "CopyFile"){CopyFile}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "MoveFile"){MoveFile}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "RenameFile"){RenameFile}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "RenameReg"){RenameReg}
                        IF ($xml.Package.$Phaserun.$TypeRun.ChildNodes.Name -contains "Execute"){Execute}
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
    IF ($debug -eq "true") { Write-Log -v_LogFile $v_LogPathfile -v_ConsoleOutput -v_LogLevel DEBUG -v_Message  "Fin du script !" }
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "*** Fin du script ! ***"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "***Executé en $TempsEcoulee !***"
    Write-Log -v_LogFile $v_LogPathfile -v_LogLevel INFO -v_Message  "----------------------------------------------------------------------------------------------------------------------------"


#Try {
#    if (-not (Test-Path -Path (Split-Path -Parent $LogFile) -PathType Container -ErrorAction Stop)) {
#        New-Item -Path (Split-Path -Parent $LogFile) -ItemType Directory -ErrorAction Stop | Out-Null -ErrorAction Stop
#    }
#} Catch {
#    Exit-Error -Exitcode 9999001
#}