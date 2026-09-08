; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;windows only
CompilerIf #CompileWindows
  
  
  Interface IMSHelp20
    QueryInterface(a.l, b.l)
    AddRef()
    Release()
    GetTypeInfoCount(a.l)
    GetTypeInfo(a.l, b.l, c.l)
    GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
    Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
    Contents()
    Index()
    Search()
    IndexResults()
    SearchResults()
    DisplayTopicFromId(a.l, b.l)
    DisplayTopicFromURL(a.l)
    DisplayTopicFromURLEx(a.l, b.l)
    DisplayTopicFromKeyword(a.l)
    DisplayTopicFromF1Keyword(a.l)
    DisplayTopicFrom_OLD_Help(a.l, b.l)
    SyncContents(a.l)
    CanSyncContents(a.l)
    GetNextTopic(a.l, b.l)
    GetPrevTopic(a.l, b.l)
    FilterUI()
    CanShowFilterUI()
    Close()
    SyncIndex(a.l, b.l)
    SetCollection(a.l, b.l)
    GetCollection(a.l)
    GetFilter(a.l)
    SetFilter(a.l)
    FilterQuery(a.l)
    GetHelpOwner(a.l)
    SetHelpOwner(a.l)
    HxSession(a.l)
    Help(a.l)
    GetObject(a.l, b.l, c.l)
  EndInterface
  
  Global PlatformSDKObject.IMSHelp20, PlatformSDKHelpString$
  
  DataSection
    IID_IMSHelp20: ; 4A791148-19E4-11D3-B86B-00C04F79F802
    Data.l $4A791148
    Data.w $19E4, $11D3
    Data.b $B8, $6B, $00, $C0, $4F, $79, $F8, $02
  EndDataSection
  
  
  Procedure.l IsPlatformSDKAvailable()
    IsAvailable = 0
    
    If RegCreateKeyEx_(#HKEY_CURRENT_USER, "Software\Microsoft\MSDN\7.0\Help", 0, #Null$, #REG_OPTION_NON_VOLATILE, #KEY_READ , 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
      Index = 0
      Repeat
        ValueName$ = Space(260)
        ValueNameSize = 260
        ValueData$ = Space(260)
        ValueDataSize = 260
        
        Result = RegEnumValue_(NewKey, Index, @ValueName$, @ValueNameSize, 0, @ValueType, 0, 0)
        
        If Result = #ERROR_SUCCESS And ValueType = #REG_SZ
          
          If Left(LCase(ValueName$),18) = "ms-help://ms.psdk." ; current version: ms-help://MS.PSDK.1033
            PlatformSDKHelpString$ = ValueName$
            IsAvailable = 1
            ; do not break here, as the below (newer) key might be present too!
            
          ElseIf Left(UCase(ValueName$),27) = "MS-HELP://MS.PSDKSVR2003SP1" ; current version: ms-help://MS.PSDKSVR2003SP1.1033
            PlatformSDKHelpString$ = ValueName$
            IsAvailable = 1
            
            Break ; this one has priority, so abort now
          EndIf
          
        EndIf
        
        Index + 1
      Until Result <> #ERROR_SUCCESS
      
      RegCloseKey_(NewKey)
    EndIf
    
    ProcedureReturn IsAvailable
  EndProcedure
  
  
  Procedure.l DisplayPlatformSDKHelp(Keyword$)
    Success = 0
    
    If PlatformSDKObject = 0
      
      If PlatformSDKHelpString$ Or IsPlatformSDKAvailable()
        
        CoInitialize_(0)
        
        CLSIDFromProgID_("DExplore.AppObj", @CLSID_DExplore.CLSID)
        
        If CoCreateInstance_(@CLSID_Dexplore, 0, 4, ?IID_IMSHelp20, @PlatformSDKObject) = #S_OK
          
          HelpSelection$ = PlatformSDKHelpString$
          
          BSTR_HelpSelection = SysAllocString_(@HelpSelection$)
          
          NullString_UNICODE$ = ""
          
          BSTR_NullString = SysAllocString_(@NullString_UNICODE$)
          
          PlatformSDKObject\SetCollection(BSTR_HelpSelection, BSTR_NullString)
          
          SysFreeString_(BSTR_HelpSelection)
          SysFreeString_(BSTR_NullString)
          
        EndIf
        
      EndIf
      
    EndIf
    
    If PlatformSDKObject <> 0
      
      BSTR_Keyword = SysAllocString_(@Keyword$)
      
      PlatformSDKObject\Contents()
      If PlatformSDKObject\DisplayTopicFromF1Keyword(BSTR_Keyword) = #S_OK
        
        PlatformSDKObject\SyncIndex(BSTR_Keyword, 1)
        PlatformSDKObject\Index()
        
        Success = 1
        
      EndIf
      
      SysFreeString_(BSTR_Keyword)
      
    EndIf
    
    ProcedureReturn Success
  EndProcedure
  
  
  Procedure ClosePlatformSDKWindow()
    
    If PlatformSDKObject <> 0
      
      PlatformSDKObject\Release()
      CoUninitialize_()
      
    EndIf
    
  EndProcedure
  
  Procedure.s GetPureBasicChmPath()
    ; 1. Direct check in PureBasicPath$
    If FileSize(PureBasicPath$ + "PureBasic.chm") > 0
      ProcedureReturn PureBasicPath$ + "PureBasic.chm"
    EndIf
    
    ; 2. Check standard installation folders
    If FileSize("C:\Program Files\PureBasic\PureBasic.chm") > 0
      ProcedureReturn "C:\Program Files\PureBasic\PureBasic.chm"
    ElseIf FileSize("C:\PureBasic\PureBasic.chm") > 0
      ProcedureReturn "C:\PureBasic\PureBasic.chm"
    EndIf
    
    ; 3. Check PUREBASIC_HOME environment variable
    Protected Env$ = GetEnvironmentVariable("PUREBASIC_HOME")
    If Env$ <> ""
      If Right(Env$, 1) <> "\" And Right(Env$, 1) <> "/" : Env$ + "\" : EndIf
      If FileSize(Env$ + "PureBasic.chm") > 0
        ProcedureReturn Env$ + "PureBasic.chm"
      EndIf
    EndIf
    
    ; 4. Check compiler home constant
    If FileSize(#PB_Compiler_Home + "PureBasic.chm") > 0
      ProcedureReturn #PB_Compiler_Home + "PureBasic.chm"
    EndIf
    
    ; 5. Fallback check with #ProductName$
    If FileSize(PureBasicPath$ + #ProductName$ + ".chm") > 0
      ProcedureReturn PureBasicPath$ + #ProductName$ + ".chm"
    EndIf
    
    ProcedureReturn PureBasicPath$ + "PureBasic.chm"
  EndProcedure

  Procedure HtmlHelp(File$, Page$)
    ; Ensure valid chm path if File$ does not exist
    If FileSize(File$) <= 0
      File$ = GetPureBasicChmPath()
    EndIf
    
    ; Open the help tool if configured to do so, or html help otherwise
    ;
    If UseHelpToolF1 And HelpToolOpen
      If Page$ = ""
        Page$ = "/Reference/reference.html"
      ElseIf Left(Page$, 1) <> "/"
        Page$ = "/" + Page$
      EndIf
      SetGadgetText(#GADGET_HelpTool_Viewer, "mk:@MSITStore:" + File$ + "::" + Page$)
      ActivateTool("HelpTool") ; switches to the tool
    Else
      OpenHelp(File$, Page$)
    EndIf
  EndProcedure
  
  
  Procedure DisplayHelp(CurrentWord$)
    
    Protected OOPPage$ = GetOOPHelpPage(CurrentWord$)
    If OOPPage$ <> ""
      OpenOOPHelp(OOPPage$)
      ProcedureReturn
    EndIf
    
    If *ActiveSource\EnableASM And IsASMKeyword(CurrentWord$) And Asc(UCase(CurrentWord$)) = 'F' And FileSize(PureBasicPath$+"Help\ASMFPU.hlp") > 0
      OpenHelp(PureBasicPath$+"Help\ASMFPU.hlp", CurrentWord$)
      
    ElseIf *ActiveSource\EnableASM And IsASMKeyword(CurrentWord$) And FileSize(PureBasicPath$+"Help\ASM.hlp") > 0
      OpenHelp(PureBasicPath$+"Help\ASM.hlp", CurrentWord$)
      
    ElseIf CurrentWord$ = ""
      HtmlHelp(GetPureBasicChmPath(), "")
      
      
    ElseIf CheckPureBasicKeyWords(CurrentWord$) <> ""
      HtmlHelp(GetPureBasicChmPath(), CheckPureBasicKeyWords(CurrentWord$)+".html")
      
      
    Else
      ForceDefaultCompiler()
      
      If CompilerReady
        CompilerWrite("HELPDIRECTORY"+Chr(9)+CurrentWord$)
        HelpDirectory$ = CompilerRead()
        
        If HelpDirectory$ = "API"
          CurrentWord$ = Left(CurrentWord$, Len(CurrentWord$)-1) ; cut the '_'
          
          If FileSize(PureBasicpath$+"Help\Win32.hlp") > 0
            OpenHelp(PureBasicpath$+"Help\Win32.hlp", CurrentWord$)
          Else
            If DisplayPlatformSDKHelp(CurrentWord$) = 0
              HtmlHelp(GetPureBasicChmPath(), "") ; Fallback to PB help if all API help fail
            EndIf
          EndIf
          
        ElseIf HelpDirectory$ = "UNKNOWN"
          HtmlHelp(GetPureBasicChmPath(), "")
          
        Else ; build in command or userlib
          If LCase(GetExtensionPart(HelpDirectory$)) = "chm"  ; A .chm has been defined in the .DESC -> It's a user lib with its own help
            HtmlHelp(PureBasicPath$+"Help\"+HelpDirectory$, GetFilePart(HelpDirectory$, #PB_FileSystem_NoExtension)+"/"+CurrentWord$+".html")
          Else
            HtmlHelp(GetPureBasicChmPath(), HelpDirectory$+"/"+CurrentWord$+".html")
          EndIf
          
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
CompilerEndIf