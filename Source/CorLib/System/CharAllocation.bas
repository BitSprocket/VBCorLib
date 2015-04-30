Attribute VB_Name = "CharAllocation"
'The MIT License (MIT)
'Copyright (c) 2015 Kelly Ethridge
'
'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights to
'use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
'the Software, and to permit persons to whom the Software is furnished to do so,
'subject to the following conditions:
'
'The above copyright notice and this permission notice shall be included in all
'copies or substantial portions of the Software.
'
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
'INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
'PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
'FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
'OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
'DEALINGS IN THE SOFTWARE.
'
'
' Module: CharAllocation
'

''
' Provides a central location to create Integer array proxy access to Strings.
'
' @remarks <p>A proxy char buffer is used with the backing of the string value
' passed in. Once the buffer access is no longer needed then the FreeChars
' method is called, passing in the Integer array returned during allocation.</p>
' <p>A Variant that contains either a String or Integer array can also be accessed
' as an array by calling AsChars. If the Variant contains a String type then the
' process works the same as calling AllocChars. If the Variant contains an Integer
' array, then the array itself is returned without allocating any char buffers.
' Which ever method is used, FreeChars must still be called using the original
' array returned to remove having multiple handles point to the same data.
'
Option Explicit

Private Const DefaultBufferSize As Long = 16

Private Type Bucket
    TablePtr    As Long
    Self        As IUnknown
    ReleasePtr  As Long
    Buffer      As SafeArray1d
End Type

Private mInited     As Boolean
Private mBuffers()  As Bucket


''
' Allocates an Integer array backed by the String passed in.
'
' @param s The string to back an Integer array and allow access using Array syntax.
' @return Returns an Integer array that points to the String structure passed in.
' @remarks Once work is finished with the array, FreeChars must be called to remove
' any references to the original string value.
'
Public Function AllocChars(ByRef s As String) As Integer()
    If Not mInited Then
        InitBuffers
        mInited = True
    End If
    
    Dim BufferIndex As Long
    BufferIndex = FindAvailableBuffer
    
    With mBuffers(BufferIndex).Buffer
        .cElements = Len(s)
        .pvData = StrPtr(s)
    End With

    SAPtr(AllocChars) = VarPtr(mBuffers(BufferIndex).Buffer)
End Function

''
' Either allocs or returns an Integer array.
'
' @param v A Variant containing either a String or Integer() data type.
' @return Returns a reference to an Integer array to access the original value.
' @remarks <p>If a String is passed in then the AllocChars method is used to create
' an Integer array with the string as a backing-store. If an Integer array is
' passed in, then another reference to the array is returned.</p>
' <p>Once work is finished with the array, FreeChars must be called to remove
' any references to the original string value.</p>
'
Public Function AsChars(ByRef v As Variant) As Integer()
    If Not mInited Then
        InitBuffers
        mInited = True
    End If
    
    Select Case VarType(v)
        Case vbString
            ' Directly assigning a string pointer prevents a string from being copied.
            Dim LocalString As String
            StringPtr(LocalString) = StrPtr(v)
            AsChars = AllocChars(LocalString)
            StringPtr(LocalString) = vbNullPtr
            
        Case vbIntegerArray
            ' Directly assigning an array pointer prevents the source array from being copied.
            SAPtr(AsChars) = ArrayPointer(v)
            
        Case Else
            Debug.Assert False
            
    End Select
End Function

''
' Removes the refernece the allocated Integer array points to.
'
' @param Chars The array that the reference is removed from.
' @remarks If the original backing of the array was a string, then
' the internal char-buffer is cleared as well.
'
Public Sub FreeChars(ByRef Chars() As Integer)
    Dim BufferIndex As Long
    BufferIndex = FindAllocatedBuffer(Chars)
    
    If BufferIndex >= 0 Then
        mBuffers(BufferIndex).Buffer.pvData = vbNullPtr
    End If
    
    SAPtr(Chars) = vbNullPtr
End Sub


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Helpers
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub InitBuffers()
    ReDim mBuffers(0 To DefaultBufferSize - 1)

    Dim i As Long
    For i = 0 To UBound(mBuffers)
        With mBuffers(i)
            .Buffer.cbElements = 2
            .Buffer.cDims = 1
            .Buffer.cLocks = 1
            .TablePtr = VarPtr(.TablePtr)
            ObjectPtr(.Self) = .TablePtr
            .ReleasePtr = FuncAddr(AddressOf BucketRelease)
        End With
    Next
End Sub

Private Function FindAvailableBuffer() As Long
    Dim i As Long
    For i = 0 To UBound(mBuffers)
        If mBuffers(i).Buffer.pvData = vbNullPtr Then
            FindAvailableBuffer = i
            Exit Function
        End If
    Next
    
    Debug.Assert False
End Function

Private Function FindAllocatedBuffer(ByRef Chars() As Integer) As Long
    Dim Ptr As Long
    Ptr = SAPtr(Chars)
    
    Dim i As Long
    For i = 0 To UBound(mBuffers)
        If VarPtr(mBuffers(i).Buffer) = Ptr Then
            FindAllocatedBuffer = i
            Exit Function
        End If
    Next
    
    FindAllocatedBuffer = -1
End Function

Private Function BucketRelease(ByRef This As Bucket) As Long
    This.Buffer.pvData = vbNullPtr
    This.Buffer.cbElements = 0
    This.Buffer.cLocks = 0
End Function