;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  !include nsDialogs.nsh


;--------------------------------
;General

  ;Name and file
  Name "PolyDev App"
  OutFile "PolyDevAppInstaller.exe"

  ;Default installation folder
  InstallDir "$LOCALAPPDATA\polydev"

  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\polydev" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;--------------------------------
;Variables

  Var StartMenuFolder
  Var EnvType

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_WELCOMEPAGE_TEXT "Installer Example$\r$\nAuthor: Maciej Michalec$\r$\n$\r$\n--$\r$\nMore info on: https://PolyDev.pl"
  
  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\polydev" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "PolyDev App"  
  !define MUI_ICON  "polydev.ico"

;--------------------------------
;Functions
Function GetEnvPageCreate
    !insertmacro MUI_HEADER_TEXT "Programming Skills" "Provide information about your programming skills"
    nsDialogs::Create 1018

	${NSD_CreateLabel} 0 0 100% 15u "Select level of your programming skills"

	pop $0
	${NSD_CreateRadioButton} 0 20u 100% 10u "Beginner"
	pop $1
	${NSD_CreateRadioButton} 0 30u 100% 10u "Intermediate"
	pop $2
	${NSD_CreateRadioButton} 0 40u 100% 10u "Expert"
	pop $3
	
	${If} $EnvType == Beginner
		${NSD_Check} $1
	${ElseIf} $EnvType == Intermediate
		${NSD_Check} $2
	${ElseIf} $EnvType == Expert
		${NSD_Check} $3
	${Else}
		${NSD_Check} $1
	${EndIf}
    nsDialogs::Show
FunctionEnd

Function GetEnvPageLeave
	${NSD_GetState} $1 $R0
	${NSD_GetState} $2 $R1

	${If} $R0 = ${BST_CHECKED}
		StrCpy $EnvType Beginner
	${ElseIf} $R1 = ${BST_CHECKED}
		StrCpy $EnvType Intermediate
	${Else}
		StrCpy $EnvType Expert
	${EndIf}
FunctionEnd

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "licence.txt"
  Page Custom GetEnvPageCreate GetEnvPageLeave ;Custom page
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder  
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "PolyDev App Core" SecCore
  SetOutPath "$INSTDIR"
  ;Install myApp directory
  File /nonfatal /a /r "myApp\"

  ;Store installation folder
  WriteRegStr HKCU "Software\polydev" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    ;Create shortcuts in start menu
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
	CreateShortcut "$SMPROGRAMS\$StartMenuFolder\PolyDevApp.lnk" "$INSTDIR\run_app.py"
  !insertmacro MUI_STARTMENU_WRITE_END  
SectionEnd

;Unselected by default
Section /o "Additional Tools" SecAdditionalTools
SectionEnd
;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecCore ${LANG_ENGLISH} "Core of the PolyDev App"
  LangString DESC_SecAdditionalTools ${LANG_ENGLISH} "Set of additional tools"

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} $(DESC_SecCore)
	!insertmacro MUI_DESCRIPTION_TEXT ${SecAdditionalTools} $(DESC_SecAdditionalTools)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section
Section "Uninstall"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
  Delete "$SMPROGRAMS\$StartMenuFolder\PolyDevApp.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"
  
  DeleteRegKey /ifempty HKCU "Software\polydev"

SectionEnd
