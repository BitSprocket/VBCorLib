VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "BitArrayTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'
' Test BitArray
'
Option Explicit
Implements ITestCaseSource

Private Sub ITestCaseSource_GetTestCases(ByVal Test As SimplyVBComp.TestCaseCollector)
    Select Case Test.MethodName
        Case "Constructor_WithDefaultValue_CreatesInitializedList"
            Test.Use True
            Test.Use False
    End Select
End Sub

Public Sub Constructor_WhenCalled_CreatesListInitializedToFalse()
    Dim List As BitArray
    
    Set List = Cor.NewBitArray(10)
    
    Assert.That List(0), Iz.False
    Assert.That List(1), Iz.False
    Assert.That List(2), Iz.False
    Assert.That List(3), Iz.False
    Assert.That List(4), Iz.False
    Assert.That List(5), Iz.False
    Assert.That List(6), Iz.False
    Assert.That List(7), Iz.False
    Assert.That List(8), Iz.False
    Assert.That List(9), Iz.False
End Sub

Public Sub Constructor_WithDefaultValue_CreatesInitializedList(ByVal DefaultValue As Boolean)
    Dim List As BitArray
    
    Set List = Cor.NewBitArray(10, DefaultValue)
    
    Assert.That List(0), Iz.EqualTo(DefaultValue)
    Assert.That List(1), Iz.EqualTo(DefaultValue)
    Assert.That List(2), Iz.EqualTo(DefaultValue)
    Assert.That List(3), Iz.EqualTo(DefaultValue)
    Assert.That List(4), Iz.EqualTo(DefaultValue)
    Assert.That List(5), Iz.EqualTo(DefaultValue)
    Assert.That List(6), Iz.EqualTo(DefaultValue)
    Assert.That List(7), Iz.EqualTo(DefaultValue)
    Assert.That List(8), Iz.EqualTo(DefaultValue)
    Assert.That List(9), Iz.EqualTo(DefaultValue)
End Sub

Public Sub Item_WhenSet_ChangedBit()
    Dim List As BitArray
    Set List = Cor.NewBitArray(10)
    
    List(2) = True
    
    Assert.That List(1), Iz.False
    Assert.That List(2), Iz.True
    Assert.That List(3), Iz.False
End Sub

Public Sub Item_WithNegativeIndex_ThrowsArgumentOutOfRangeException()
    Dim List As BitArray
    Set List = Cor.NewBitArray(10)
    
    On Error Resume Next
    List(-1) = True
    
    AssertArgumentOutOfRangeException Err, "Index"
End Sub

Public Sub Item_WithIndexGreaterThanItemCount_ThrowsArgumentOutOfRangeException()
    Dim List As BitArray
    Set List = Cor.NewBitArray(10)
    
    On Error Resume Next
    List(10) = True
    
    AssertArgumentOutOfRangeException Err, "Index"
End Sub



'Private list As bitarray
'
'Public Sub Setup()
'    Set list = newbitarray(32)
'End Sub
'
'Public Sub TestAnd()
'    Dim andlist As bitarray
'    Set andlist = newbitarray(list.Count)
'    Dim i As Long
'    For i = 0 To andlist.Count - 1
'        andlist(i) = Not CBool(i And 1)
'    Next i
'    list.SetAll True
'    list.AndBits andlist
'    AssertAlternatingPattern
'End Sub
'
'Public Sub TestOr()
'    Dim orlist As bitarray
'    Dim i As Long
'    Set orlist = newbitarray(list.Count)
'    For i = 0 To orlist.Count - 1
'        orlist(i) = Not CBool(i And 1)
'    Next i
'    list.OrBits orlist
'    AssertAlternatingPattern
'End Sub
'
'Public Sub TestSetAll()
'    Dim i As Long
'    list.SetAll True
'    For i = 0 To list.Count - 1
'        Assert.IsTrue list(i), "Failed at " & i
'    Next i
'
'    list.SetAll False
'    For i = 0 To list.Count - 1
'        Assert.IsFalse list(i), "Failed at " & i
'    Next i
'End Sub
'
'Public Sub TestSetLengthClearsNewBits()
'    Dim i As Long
'    i = list.Length
'    list.Length = list.Length + 35
'    list.SetAll True
'    list.Length = list.Length - 35
'    list.Length = list.Length + 35
'
'    For i = i To list.Count - 1
'        Assert.IsFalse list(i), "New bits were not cleared."
'    Next i
'End Sub
'
'Public Sub TestNot()
'    Dim i As Long
'
'    For i = 0 To list.Count - 1
'        list(i) = i And 1
'    Next i
'    list.NotBits
'    AssertAlternatingPattern
'End Sub
'
'Public Sub TestXor()
'    Dim i As Long
'    Dim b As bitarray
'    Set b = newbitarray(list.Count)
'    b.SetAll True
'    list.XorBits b
'
'    For i = 0 To list.Count - 1
'        Assert.IsTrue list(i), "Bit should be true."
'    Next i
'End Sub
'
'Public Sub TestFromLongs()
'    Dim l() As Long
'    l = NewLongs(&H55555555, &H55555555)
'
'    Set list = bitarray.FromLongs(l)
'    Assert.AreEqual 64, list.Count, "Count should be 64."
'    AssertAlternatingPattern
'End Sub
'
'Public Sub TestFromBytes()
'    Dim b() As Byte
'    b = NewBytes(&H55, &H55, &H55)
'
'    Set list = bitarray.FromBytes(b)
'    Assert.AreEqual 24, list.Count, "Count should be 24."
'    AssertAlternatingPattern
'End Sub
'
'Public Sub TestFromBooleans()
'    Dim b(60) As Boolean
'    Dim i As Long
'    For i = 0 To 60
'        b(i) = Not CBool(i And 1)
'    Next i
'    Set list = bitarray.FromBooleans(b)
'    Assert.AreEqual 61, list.Count, "Count should be 61."
'    AssertAlternatingPattern
'End Sub
'
'Public Sub TestEnumerator()
'    Dim v As Variant
'    list.SetAll True
'    For Each v In list
'        Assert.IsTrue v
'    Next v
'End Sub
'
'Public Sub TestCopyToLongs()
'    Dim l(1) As Long
'    list.SetAll True
'
'    list.CopyTo l, 0
'
'    Assert.AreEqual -1, l(0)
'    Assert.AreEqual 0, l(1)
'
'End Sub
'
'Public Sub TestCopyToBytes()
'    Dim b(3) As Byte
'    list.SetAll True
'
'    list.CopyTo b, 0
'    Dim i As Long
'    For i = 0 To 3
'        Assert.AreEqual 255, b(i)
'    Next i
'End Sub
'
'Public Sub TestCopyToBooleans()
'    Dim b(31) As Boolean
'    list.SetAll True
'    list.CopyTo b, 0
'    Dim i As Long
'    For i = 0 To 31
'        Assert.IsTrue b(i)
'    Next i
'End Sub
'
'Public Sub TestCopyToWrongType()
'    Dim a(31) As Integer
'    On Error GoTo errTrap
'    list.CopyTo a, 0
'    On Error GoTo 0
'    Assert.Fail "Error should have been raised."
'errTrap:
'    Dim Ex As Exception
'    Assert.IsTrue Catch(Ex), "Exception should have been caught."
'    Assert.IsTrue TypeOf Ex Is ArrayTypeMismatchException, "Wrong exception type."
'End Sub
'
'
'Private Sub AssertAlternatingPattern()
'    Dim i As Long
'    For i = 0 To list.Count - 1
'        If i And 1 Then
'            Assert.IsFalse list(i), "Index " & i & " should be false."
'        Else
'            Assert.IsTrue list(i), "Index " & i & " should be true."
'        End If
'    Next i
'End Sub