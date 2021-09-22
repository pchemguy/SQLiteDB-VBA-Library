Attribute VB_Name = "LiteCheckTests"
'@Folder "SQLiteDB"
'@TestModule
'@IgnoreModule LineLabelNotUsed, UnhandledOnErrorResumeNext, FunctionReturnValueDiscarded
'@IgnoreModule IndexedDefaultMemberAccess
Option Explicit
Option Private Module

#Const LateBind = LateBindTests
#If LateBind Then
    Private Assert As Object
#Else
    Private Assert As Rubberduck.PermissiveAssertClass
#End If

Private Const LIB_NAME As String = "SQLiteDBVBA"
Private Const PATH_SEP As String = "\"
Private Const REL_PREFIX As String = "Library" & PATH_SEP & LIB_NAME & PATH_SEP


'This method runs once per module.
'@ModuleInitialize
Private Sub ModuleInitialize()
    #If LateBind Then
        Set Assert = CreateObject("Rubberduck.PermissiveAssertClass")
    #Else
        Set Assert = New Rubberduck.PermissiveAssertClass
    #End If
End Sub


'This method runs once per module.
'@ModuleCleanup
Private Sub ModuleCleanup()
    Set Assert = Nothing
End Sub


'This method runs after every test in the module.
'@TestCleanup
Private Sub TestCleanup()
    Err.Clear
End Sub


'===================================================='
'===================== FIXTURES ====================='
'===================================================='


'''' ##########################################################################
''''
'''' Must run "Library\SQLiteDBVBA\Fixtures\acl-restrict.bat" for access
''''   checking tests to work properly.
'''' Must run "Library\SQLiteDBVBA\Fixtures\acl-restore.bat" for git client to
''''   work properly.
''''
'''' ##########################################################################


Private Function zfxDefaultDbManager() As LiteCheck
    Dim FilePathName As String
    FilePathName = REL_PREFIX & LIB_NAME & ".db"
    
    Dim dbm As LiteCheck
    Set dbm = LiteCheck.Create(FilePathName)
    
    Set zfxDefaultDbManager = dbm
End Function


Private Function zfxFixturePrefix() As String
    zfxFixturePrefix = ThisWorkbook.Path & PATH_SEP & REL_PREFIX & "Fixtures" & PATH_SEP
End Function


'===================================================='
'==================== TEST CASES ===================='
'===================================================='


'@TestMethod("Integrity checking")
Private Sub ztcIntegrityADODB_PassesDefaultDatabaseIntegrityCheck()
    On Error GoTo TestFail

Arrange:
Act:
    Dim CheckResult As Boolean
    CheckResult = zfxDefaultDbManager().IntegrityADODB
Assert:
    Assert.IsTrue CheckResult, "Integrity check on default database failed"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcIntegrityADODB_ThrowsOnFileNotDatabase()
    On Error Resume Next
    LiteCheck(ThisWorkbook.Name).IntegrityADODB
    Guard.AssertExpectedError Assert, ErrNo.OLE_DB_ODBC_Err
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcIntegrityADODB_ThrowsOnCorruptedDatabase()
    On Error Resume Next
    LiteCheck(REL_PREFIX & "ICfailFKCfail.db").IntegrityADODB
    Guard.AssertExpectedError Assert, ErrNo.IntegrityCheckErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcIntegrityADODB_ThrowsOnFailedFKCheck()
    On Error Resume Next
    LiteCheck(REL_PREFIX & "ICokFKCfail.db").IntegrityADODB
    Guard.AssertExpectedError Assert, ErrNo.ConsistencyCheckErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcPathExistsAccessible_ThrowsOnLastFolderACLLock()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = ThisWorkbook.Path & PATH_SEP & REL_PREFIX & _
                   "Fixtures\ACLLocked\LockedFolder\LT100.db"
    LiteCheck(FilePathName).PathExistsAccessible FilePathName
    Guard.AssertExpectedError Assert, ErrNo.PermissionDeniedErr
End Sub

    
'@TestMethod("Integrity checking")
Private Sub ztcPathExistsAccessible_TraversesLockedFolder()
    On Error GoTo TestFail

Arrange:
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "ACLLocked\LockedFolder\SubFolder\TestC.db"
Act:
    LiteCheck(FilePathName).PathExistsAccessible FilePathName
Assert:
    Assert.Succeed

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub
    

'@TestMethod("Integrity checking")
Private Sub ztcPathExistsAccessible_ThrowsOnIllegalPath()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = ":Illegal Path<|>:"
    LiteCheck(FilePathName).PathExistsAccessible FilePathName
    Assert.IsTrue Err.Description = "Path is not absolute."
    Guard.AssertExpectedError Assert, ErrNo.PathNotFoundErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcPathExistsAccessible_ThrowsOnNonExistentPath()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "Dummy" & PATH_SEP & "Dummy.db"
    LiteCheck(FilePathName).PathExistsAccessible FilePathName
    Assert.IsTrue Err.Description <> "Path is not absolute."
    Guard.AssertExpectedError Assert, ErrNo.PathNotFoundErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcPathExistsAccessible_ThrowsOnNonExistentFile()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "Dummy.db"
    LiteCheck(FilePathName).PathExistsAccessible FilePathName
    Guard.AssertExpectedError Assert, ErrNo.FileNotFoundErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcExistsAccesibleValid_ThrowsOnLastFolderACLLock()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "ACLLocked\LockedFolder\LT100.db"
    LiteCheck(FilePathName).ExistsAccesibleValid
    Guard.AssertExpectedError Assert, ErrNo.PermissionDeniedErr
End Sub

    
'@TestMethod("Integrity checking")
Private Sub ztcExistsAccesibleValid_TraversesLockedFolder()
    On Error GoTo TestFail

Arrange:
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "ACLLocked\LockedFolder\SubFolder\TestC.db"
Act:
    LiteCheck(FilePathName).ExistsAccesibleValid
Assert:
    Assert.Succeed

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcExistsAccesibleValid_ThrowsOnIllegalPath()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = ":Illegal Path<|>:"
    LiteCheck(FilePathName).ExistsAccesibleValid
    Assert.IsTrue Err.Description = "Path is not absolute."
    Guard.AssertExpectedError Assert, ErrNo.PathNotFoundErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcExistsAccesibleValid_ThrowsOnNonExistentPath()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "Dummy" & PATH_SEP & "Dummy.db"
    LiteCheck(FilePathName).ExistsAccesibleValid
    Assert.IsTrue Err.Description <> "Path is not absolute."
    Guard.AssertExpectedError Assert, ErrNo.PathNotFoundErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcExistsAccesibleValid_ThrowsOnNonExistentFile()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "Dummy.db"
    LiteCheck(FilePathName).ExistsAccesibleValid
    Guard.AssertExpectedError Assert, ErrNo.FileNotFoundErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcFileAccessibleValid_ThrowsOnLT100File()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "LT100.db"
    LiteCheck(FilePathName).FileAccessibleValid FilePathName
    Guard.AssertExpectedError Assert, ErrNo.OLE_DB_ODBC_Err
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcFileAccessibleValid_ThrowsOnFileACLLock()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "ACLLocked\LockedDb.db"
    LiteCheck(FilePathName).FileAccessibleValid FilePathName
    Guard.AssertExpectedError Assert, ErrNo.PermissionDeniedErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcFileAccessibleValid_ThrowsOnBadMagic()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "BadMagic.db"
    LiteCheck(FilePathName).FileAccessibleValid FilePathName
    Guard.AssertExpectedError Assert, ErrNo.OLE_DB_ODBC_Err
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcFileAccessibleValid_ThrowsOnReadLockedFile()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "TestC.db"
    Dim dbm As ILiteADO
    Set dbm = LiteADO(FilePathName)
    dbm.ExecuteNonQuery "BEGIN IMMEDIATE"
    LiteCheck(FilePathName & "-shm").FileAccessibleValid FilePathName & "-shm"
    dbm.ExecuteNonQuery "ROLLBACK"
    Guard.AssertExpectedError Assert, ErrNo.TextStreamReadErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcExistsAccesibleValid_ThrowsOnLT100File()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "LT100.db"
    LiteCheck(FilePathName).ExistsAccesibleValid
    Guard.AssertExpectedError Assert, ErrNo.OLE_DB_ODBC_Err
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcExistsAccesibleValid_ThrowsOnFileACLLock()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "ACLLocked\LockedDb.db"
    LiteCheck(FilePathName).ExistsAccesibleValid
    Guard.AssertExpectedError Assert, ErrNo.PermissionDeniedErr
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcExistsAccesibleValid_ThrowsOnBadMagic()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "BadMagic.db"
    LiteCheck(FilePathName).ExistsAccesibleValid
    Guard.AssertExpectedError Assert, ErrNo.OLE_DB_ODBC_Err
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcExistsAccesibleValid_ThrowsOnReadLockedFile()
    On Error Resume Next
    Dim FilePathName As String
    FilePathName = zfxFixturePrefix & "TestC.db"
    Dim dbm As ILiteADO
    Set dbm = LiteADO(FilePathName)
    dbm.ExecuteNonQuery "BEGIN IMMEDIATE"
    LiteCheck(FilePathName & "-shm").ExistsAccesibleValid
    dbm.ExecuteNonQuery "ROLLBACK"
    Guard.AssertExpectedError Assert, ErrNo.TextStreamReadErr
End Sub


'Private Sub ztcExistsAccesibleValid_ThrowsOnBadMagicA()
'    Dim FilePathName As String
'    FilePathName = zfxFixturePrefix & "TestCWAL.db"
'    Dim dbm As ILiteADO
'    Set dbm = LiteADO(FilePathName)
'
'    Dim AdoConnection As ADODB.Connection
'    Set AdoConnection = dbm.AdoConnection
'
'    LiteCheck(FilePathName).ExistsAccesibleValid
'    Dim Response As Variant
'    Response = dbm.GetScalar("PRAGMA journal_mode")
'    dbm.ExecuteNonQuery "PRAGMA journal_mode='DELETE'"
'    Response = dbm.GetScalar("PRAGMA journal_mode")
'
'    On Error Resume Next
'    FilePathName = zfxFixturePrefix & "TestCWAL.db"
'    Set dbm = LiteADO(FilePathName)
'    dbm.ExecuteNonQuery "BEGIN IMMEDIATE"
'    LiteCheck(FilePathName & "-shm").ExistsAccesibleValid
'    dbm.ExecuteNonQuery "ROLLBACK"
'    Guard.AssertExpectedError Assert, ErrNo.TextStreamReadErr
'End Sub
