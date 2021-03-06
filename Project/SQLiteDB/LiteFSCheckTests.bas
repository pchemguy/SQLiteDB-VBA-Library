Attribute VB_Name = "LiteFSCheckTests"
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

Private FilePathName As String
Private PathCheck As LiteFSCheck
Private ErrNumber As Long
Private ErrSource As String
Private ErrDescription As String
Private ErrStack As String


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


Private Function zfxFixturePrefix() As String
    zfxFixturePrefix = ThisWorkbook.Path & PATH_SEP & REL_PREFIX & "Fixtures" & PATH_SEP
End Function


'===================================================='
'==================== TEST CASES ===================='
'===================================================='


'@TestMethod("Integrity checking")
Private Sub ztcCreate_TraversesLockedFolder()
    On Error GoTo TestFail

Arrange:
    FilePathName = zfxFixturePrefix & "ACLLocked\LockedFolder\SubFolder\TestC.db"
Act:
    Set PathCheck = LiteFSCheck(FilePathName)
Assert:
    With PathCheck
        Assert.AreEqual FilePathName, .Database, "Database should be set"
        Assert.AreEqual 0, .ErrNumber, "ErrNumber should be 0"
        Assert.AreEqual 0, Len(.ErrSource), "ErrSource should be blank"
        Assert.AreEqual 0, Len(.ErrDescription), "ErrDescription should be blank"
        Assert.AreEqual 0, Len(.ErrStack), "ErrStack should be blank"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'''' ##########################################################################
''''
'''' Must run "Library\SQLiteDBVBA\Fixtures\acl-restrict.bat" for access
''''   checking tests to work properly.
'''' Must run "Library\SQLiteDBVBA\Fixtures\acl-restore.bat" for git client to
''''   work properly.
''''
'''' ##########################################################################
'@TestMethod("Integrity checking")
Private Sub ztcCreate_FailsOnLastFolderACLLock()
    On Error GoTo TestFail

Arrange:
    FilePathName = zfxFixturePrefix & "ACLLocked\LockedFolder\LT100.db"
    FilePathName = zfxFixturePrefix & "ACLLocked\LockedDb.db" '''' FailsOnFileACLLock
    ErrNumber = ErrNo.PermissionDeniedErr
    ErrSource = "LiteFSCheck"
    ErrDescription = "Permission denied" & vbNewLine & _
                     "Access is denied to the database file. " & _
                     "Check ACL permissions and file locks." & _
                     vbNewLine & "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine & _
               "FileAccessibleValid" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName)
Assert:
    With PathCheck
        If Len(.Database) > 0 Then Assert.Inconclusive "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.AreEqual ErrSource, .ErrSource, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcCreate_FailsOnIllegalPath()
    On Error GoTo TestFail

Arrange:
    FilePathName = ":Illegal Path<|>:"
    ErrNumber = ErrNo.PathNotFoundErr
    ErrSource = "LiteFSCheck"
    ErrDescription = "Database path (folder) is not found. Expected " & _
                     "absolute path. Check ACL settings. Enable path " & _
                     "resolution feature, if necessary." & _
                     vbNewLine & "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine & _
               "PathExistsAccessible" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName)
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.AreEqual ErrSource, .ErrSource, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcCreate_FailsOnNonExistentPath()
    On Error GoTo TestFail

Arrange:
    FilePathName = zfxFixturePrefix & "Dummy" & PATH_SEP & "Dummy.db"
    ErrNumber = ErrNo.PathNotFoundErr
    ErrSource = "LiteFSCheck"
    ErrDescription = "Database path (folder) is not found. Expected " & _
                     "absolute path. Check ACL settings. Enable path " & _
                     "resolution feature, if necessary." & _
                     vbNewLine & "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine & _
               "PathExistsAccessible" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName)
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.AreEqual ErrSource, .ErrSource, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcCreate_FailsOnNonExistentFile()
    On Error GoTo TestFail

Arrange:
    FilePathName = zfxFixturePrefix & "Dummy.db"
    ErrNumber = ErrNo.FileNotFoundErr
    ErrSource = "LiteFSCheck"
    ErrDescription = "Databse file is not found in the specified folder." & _
                     vbNewLine & "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName)
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.AreEqual ErrSource, .ErrSource, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcCreate_FailsOnLT100File()
    On Error GoTo TestFail

Arrange:
    FilePathName = zfxFixturePrefix & "LT100.db"
    ErrNumber = ErrNo.OLE_DB_ODBC_Err
    ErrSource = "LiteFSCheck"
    ErrDescription = "File is not a database. SQLite header size is 100 bytes." & _
                     vbNewLine & "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine & _
               "FileAccessibleValid" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName)
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.AreEqual ErrSource, .ErrSource, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcCreate_FailsOnBadMagic()
    On Error GoTo TestFail

Arrange:
    FilePathName = zfxFixturePrefix & "BadMagic.db"
    ErrNumber = ErrNo.OLE_DB_ODBC_Err
    ErrSource = "LiteFSCheck"
    ErrDescription = "Database file is damaged. The magic string did not match." & _
                     vbNewLine & "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine & _
               "FileAccessibleValid" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName)
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.AreEqual ErrSource, .ErrSource, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcCreate_FailsOnReadLockedFile()
    On Error GoTo TestFail

Arrange:
    FilePathName = zfxFixturePrefix & "TestC.db"
    ErrNumber = ErrNo.TextStreamReadErr
    ErrSource = "LiteFSCheck"
    ErrDescription = "Method 'Read' of object 'ITextStream' failed" & vbNewLine & _
                     "Cannot read from the database file. " & _
                     "The file might be locked by another app." & _
                     vbNewLine & "Source: " & FilePathName & "-shm"
    ErrStack = "ExistsAccesibleValid" & vbNewLine & _
               "FileAccessibleValid" & vbNewLine
Act:
    Dim dbm As ILiteADO
    Set dbm = LiteADO(FilePathName)
    FilePathName = FilePathName & "-shm"
    dbm.ExecuteNonQuery "BEGIN IMMEDIATE"
    Set PathCheck = LiteFSCheck(FilePathName)
    dbm.ExecuteNonQuery "ROLLBACK"
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.AreEqual ErrSource, .ErrSource, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Integrity checking")
Private Sub ztcCreate_FailsOnEmptyPath()
    On Error GoTo TestFail

Arrange:
    FilePathName = vbNullString
    ErrNumber = ErrNo.PathNotFoundErr
    ErrSource = "LiteFSCheck"
    ErrDescription = "Database path (folder) is not found. Expected " & _
                     "absolute path. Check ACL settings. Enable path " & _
                     "resolution feature, if necessary." & _
                     vbNewLine & "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine & _
               "PathExistsAccessible" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName)
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.AreEqual ErrSource, .ErrSource, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Path resolution")
Private Sub ztcCreate_ResolvesRelativePath()
    On Error GoTo TestFail

Arrange:
    FilePathName = REL_PREFIX & LIB_NAME & ".db"
    Dim Expected As String
    Expected = ThisWorkbook.Path & PATH_SEP & FilePathName
Act:
    Set PathCheck = LiteFSCheck(FilePathName, False)
Assert:
    Assert.AreEqual 0, PathCheck.ErrNumber, "Unexpected error occured"
    Assert.AreEqual Expected, PathCheck.Database, "Resolved path mismatch"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Path resolution")
Private Sub ztcCreate_FailsResolveCreatableWithEmptyPath()
    On Error GoTo TestFail

Arrange:
    FilePathName = vbNullString
    ErrNumber = ErrNo.FileNotFoundErr
    ErrSource = "CommonRoutines"
    ErrDescription = "File <> not found!" & vbNewLine & _
                     "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName, True)
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.AreEqual ErrSource, .ErrSource, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("New database")
Private Sub ztcCreate_FailsCreateDbInReadOnlyDir()
    On Error GoTo TestFail

Arrange:
    FilePathName = Environ$("ALLUSERSPROFILE") & PATH_SEP & "Dummy.db"
    ErrNumber = ErrNo.PermissionDeniedErr
    ErrSource = "LiteFSCheck"
    ErrDescription = "Permission denied" & vbNewLine & _
                     "Cannot create a new file." & vbNewLine & _
                     "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName, vbNullString)
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.IsTrue InStr(.ErrSource, ErrSource) > 0, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("New database")
Private Sub ztcCreate_FailsCreateDbNoFileName()
    On Error GoTo TestFail

Arrange:
    FilePathName = zfxFixturePrefix()
    ErrNumber = ErrNo.FileNotFoundErr
    ErrSource = "LiteFSCheck"
    ErrDescription = "Filename is not provided or provided name conflicts " & _
                     "with existing folder." & vbNewLine & _
                     "Source: " & FilePathName
    ErrStack = "ExistsAccesibleValid" & vbNewLine
Act:
    Set PathCheck = LiteFSCheck(FilePathName, vbNullString)
Assert:
    With PathCheck
        Assert.AreEqual 0, Len(.Database), "Database should not be set"
        Assert.AreEqual ErrNumber, .ErrNumber, "ErrNumber mismatch"
        Assert.IsTrue InStr(.ErrSource, ErrSource) > 0, "ErrSource mismatch"
        Assert.AreEqual ErrDescription, .ErrDescription, "ErrDescription mismatch"
        Assert.AreEqual ErrStack, .ErrStack, "ErrStack mismatch"
    End With

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Path resolution")
Private Sub ztcCreate_ResolvesBlankNoCreatePath()
    On Error GoTo TestFail
    
Arrange:
    FilePathName = vbNullString
    Dim Expected As String
    Expected = ThisWorkbook.Path & PATH_SEP & REL_PREFIX & LIB_NAME & ".db"
Act:
    Set PathCheck = LiteFSCheck(FilePathName, False)
Assert:
    Assert.AreEqual 0, PathCheck.ErrNumber, "Unexpected error occured"
    Assert.AreEqual Expected, PathCheck.Database, "Resolved path mismatch"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("Path resolution")
Private Sub ztcCreate_ResolvesNameOnlyNoCreatePath()
    On Error GoTo TestFail
    
Arrange:
    FilePathName = LIB_NAME & ".db"
    Dim Expected As String
    Expected = ThisWorkbook.Path & PATH_SEP & REL_PREFIX & LIB_NAME & ".db"
Act:
    Set PathCheck = LiteFSCheck(FilePathName, False)
Assert:
    Assert.AreEqual 0, PathCheck.ErrNumber, "Unexpected error occured"
    Assert.AreEqual Expected, PathCheck.Database, "Resolved path mismatch"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub
