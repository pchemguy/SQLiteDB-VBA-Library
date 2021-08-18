Attribute VB_Name = "CommonRoutinesTests"
'@Folder "Common.Shared"
'@TestModule
'@IgnoreModule LineLabelNotUsed, UnhandledOnErrorResumeNext, FunctionReturnValueDiscarded
Option Explicit
Option Private Module


#Const LateBind = LateBindTests
#If LateBind Then
    Private Assert As Object
#Else
    Private Assert As Rubberduck.PermissiveAssertClass
#End If


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
'==================== TEST CASES ===================='
'===================================================='


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_ThrowsIfScalarArgument()
    On Error Resume Next
    UnfoldParamArray 1
    AssertExpectedError Assert, ErrNo.ExpectedArrayErr
End Sub


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_ThrowsIfObjectArgument()
    On Error Resume Next
    UnfoldParamArray Application
    AssertExpectedError Assert, ErrNo.ExpectedArrayErr
End Sub


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_VerifiesUnfoldsWrappedArray()
    On Error GoTo TestFail

Arrange:
    Dim ParamArrayParamArrayArg(0 To 0) As Variant
    ParamArrayParamArrayArg(0) = Array(1024&, 2048&)
Act:
    Dim Actual As Variant
    Actual = UnfoldParamArray(ParamArrayParamArrayArg)
Assert:
    Assert.AreEqual 1024, Actual(0), "Unfolding error"
    Assert.AreEqual 2048, Actual(1), "Unfolding error"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_VerifiesNoUnfoldingEmptyArray()
    On Error GoTo TestFail

Arrange:
Act:
    Dim Actual As Variant
    Actual = UnfoldParamArray(Array())
Assert:
    Assert.AreEqual -1, UBound(Actual), "Returned argument error"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_VerifiesNoUnfoldingMismatch1stLB()
    On Error GoTo TestFail

Arrange:
    Dim ArgumentOuter(1 To 1) As Variant
    Dim ArgumentInner(0 To 1) As Long
    ArgumentInner(0) = 1024&
    ArgumentInner(1) = 2048&
    ArgumentOuter(1) = ArgumentInner
Act:
    Dim Actual As Variant
    Actual = UnfoldParamArray(ArgumentOuter)
Assert:
    Assert.AreEqual 1024, Actual(1)(0), "Returned argument error"
    Assert.AreEqual 2048, Actual(1)(1), "Returned argument error"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_VerifiesNoUnfoldingMismatch1stUB()
    On Error GoTo TestFail

Arrange:
    Dim ArgumentOuter(0 To 1) As Variant
    Dim ArgumentInner(0 To 1) As Long
    ArgumentInner(0) = 1024&
    ArgumentInner(1) = 2048&
    ArgumentOuter(1) = ArgumentInner
Act:
    Dim Actual As Variant
    Actual = UnfoldParamArray(ArgumentOuter)
Assert:
    Assert.AreEqual 1024, Actual(1)(0), "Returned argument error"
    Assert.AreEqual 2048, Actual(1)(1), "Returned argument error"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_VerifiesNoUnfoldingMismatch1stDim()
    On Error GoTo TestFail

Arrange:
    Dim Argument(0 To 0, 0 To 1) As Variant
    Argument(0, 0) = 1024&
    Argument(0, 1) = 2048&
Act:
    Dim Actual As Variant
    Actual = UnfoldParamArray(Argument)
Assert:
    Assert.AreEqual 1024, Actual(0, 0), "Returned argument error"
    Assert.AreEqual 2048, Actual(0, 1), "Returned argument error"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_VerifiesNoUnfoldingMismatch2ndLB()
    On Error GoTo TestFail

Arrange:
    Dim ArgumentOuter(0 To 0) As Variant
    Dim ArgumentInner(1 To 2) As Long
    ArgumentInner(1) = 1024&
    ArgumentInner(2) = 2048&
    ArgumentOuter(0) = ArgumentInner
Act:
    Dim Actual As Variant
    Actual = UnfoldParamArray(ArgumentOuter)
Assert:
    Assert.AreEqual 1024, Actual(0)(1), "Returned argument error"
    Assert.AreEqual 2048, Actual(0)(2), "Returned argument error"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_VerifiesNoUnfoldingMismatch2ndDim()
    On Error GoTo TestFail

Arrange:
    Dim ArgumentOuter(0 To 0) As Variant
    Dim ArgumentInner(0 To 0, 0 To 1) As Long
    ArgumentInner(0, 0) = 1024&
    ArgumentInner(0, 1) = 2048&
    ArgumentOuter(0) = ArgumentInner
Act:
    Dim Actual As Variant
    Actual = UnfoldParamArray(ArgumentOuter)
Assert:
    Assert.AreEqual 1024, Actual(0)(0, 0), "Returned argument error"
    Assert.AreEqual 2048, Actual(0)(0, 1), "Returned argument error"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub


'@TestMethod("ParramArray")
Private Sub ztcUnfoldParamArray_VerifiesNoUnfoldingMismatch2ndType()
    On Error GoTo TestFail

Arrange:
Act:
    Dim Actual As Variant
    Actual = UnfoldParamArray(Array(1024&, 2048&))
Assert:
    Assert.AreEqual 1024, Actual(0), "Returned argument error"
    Assert.AreEqual 2048, Actual(1), "Returned argument error"

CleanExit:
    Exit Sub
TestFail:
    Assert.Fail "Error: " & Err.Number & " - " & Err.Description
End Sub