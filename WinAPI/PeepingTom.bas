Option Explicit
$NoPrefix
$Console:Only

'Begin $INCLUDE

Type PROCESSENTRY32
    As Unsigned Long dwSize, cntUsage, th32ProcessID
    $If 64BIT Then
        As String * 4 alignment
    $End If
    As Unsigned Offset th32DefaultHeapID
    As Unsigned Long th32ModuleID, cntThreads, th32ParentProcessID
    As Long pcPriClassBase
    As Unsigned Long dwFlags
    As String * 260 szExeFile
End Type

Const PROCESS_VM_READ = &H0010
Const PROCESS_QUERY_INFORMATION = &H0400
Const PROCESS_VM_WRITE = &H0020
Const PROCESS_VM_OPERATION = &H0008
Const STANDARD_RIGHTS_REQUIRED = &H000F0000
Const SYNCHRONIZE = &H00100000
Const PROCESS_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED Or SYNCHRONIZE Or &HFFFF

Const TH32CS_INHERIT = &H80000000
Const TH32CS_SNAPHEAPLIST = &H00000001
Const TH32CS_SNAPMODULE = &H00000008
Const TH32CS_SNAPMODULE32 = &H00000010
Const TH32CS_SNAPPROCESS = &H00000002
Const TH32CS_SNAPTHREAD = &H00000004
Const TH32CS_SNAPALL = TH32CS_SNAPHEAPLIST Or TH32CS_SNAPMODULE Or TH32CS_SNAPPROCESS Or TH32CS_SNAPTHREAD

Const TOM_TRUE = -1
Const TOM_FALSE = 0

Declare Dynamic Library "Kernel32"
    Function CreateToolhelp32Snapshot%& (ByVal dwFlags As Unsigned Long, Byval th32ProcessID As Unsigned Long)
    Function Process32First& (ByVal hSnapshot As Offset, Byval lppe As Offset)
    Function Process32Next& (ByVal hSnapshot As Offset, Byval lppe As Offset)
    Function OpenProcess%& (ByVal dwDesiredAccess As Unsigned Long, Byval bInheritHandle As Long, Byval dwProcessId As Unsigned Long)
    Function ReadProcessMemory& (ByVal hProcess As Offset, Byval lpBaseAddress As Offset, Byval lpBuffer As Offset, Byval nSize As Offset, Byval lpNumberOfBytesRead As Offset)
    Function WriteProcessMemory& (ByVal hProcess As Offset, Byval lpBaseAddress As Offset, Byval lpBuffer As Offset, Byval nSize As Offset, Byval lpNumberOfBytesWritten As Offset)
    Sub ReadProcessMemory (ByVal hProcess As Offset, Byval lpBaseAddress As Offset, Byval lpBuffer As Offset, Byval nSize As Offset, Byval lpNumberOfBytesRead As Offset)
    Sub WriteProcessMemory (ByVal hProcess As Offset, Byval lpBaseAddress As Offset, Byval lpBuffer As Offset, Byval nSize As Offset, Byval lpNumberOfBytesWritten As Offset)
    Sub CloseHandle (ByVal hObject As Offset)
End Declare

Declare CustomType Library
    Function strlen& (ByVal ptr As Unsigned Offset)
End Declare

Function PeekByte%% (process As String, address As Unsigned Offset)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Byte result
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = ReadProcessMemory(hProcess, address, Offset(result), 1, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PeekByte = result
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = ReadProcessMemory(hProcess, address, Offset(result), 1, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PeekByte = result
End Function

Function PokeByte& (process As String, address As Unsigned Offset, value As Byte)
    Dim As Offset hProcessSnap
    Dim As Offset hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = WriteProcessMemory(hProcess, address, Offset(value), 1, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PokeByte = memo
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = WriteProcessMemory(hProcess, address, Offset(value), 1, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PokeByte = memo
End Function

Function PeekUnsignedByte~%% (process As String, address As Unsigned Offset)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Unsigned Byte result
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = ReadProcessMemory(hProcess, address, Offset(result), 1, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PeekUnsignedByte = result
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = ReadProcessMemory(hProcess, address, Offset(result), 1, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PeekUnsignedByte = result
End Function

Function PokeUnsignedByte& (process As String, address As Unsigned Offset, value As Unsigned Byte)
    Dim As Offset hProcessSnap
    Dim As Offset hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo:
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = WriteProcessMemory(hProcess, address, Offset(value), 1, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PokeUnsignedByte = memo
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = WriteProcessMemory(hProcess, address, Offset(value), 1, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PokeUnsignedByte = memo
End Function

Function PeekInt% (process As String, address As Unsigned Offset)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Integer result
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = ReadProcessMemory(hProcess, address, Offset(result), 2, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PeekInt = result
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = ReadProcessMemory(hProcess, address, Offset(result), 2, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PeekInt = result
End Function

Function PokeInt& (process As String, address As Unsigned Offset, value As Integer)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = WriteProcessMemory(hProcess, address, Offset(value), 2, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PokeInt = memo
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = WriteProcessMemory(hProcess, address, Offset(value), 2, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PokeInt = memo
End Function

Function PeekUnsignedInt~% (process As String, address As Unsigned Offset)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Unsigned Integer result
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = ReadProcessMemory(hProcess, address, Offset(result), 2, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PeekUnsignedInt = result
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = ReadProcessMemory(hProcess, address, Offset(result), 2, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PeekUnsignedInt = result
End Function

Function PokeUnsignedInt& (process As String, address As Unsigned Offset, value As Unsigned Integer)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = WriteProcessMemory(hProcess, address, Offset(value), 2, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PokeUnsignedInt = memo
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = WriteProcessMemory(hProcess, address, Offset(value), 2, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PokeUnsignedInt = memo
End Function

Function PeekLong& (process As String, address As Unsigned Offset)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long result
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = ReadProcessMemory(hProcess, address, Offset(result), 4, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PeekLong = result
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = ReadProcessMemory(hProcess, address, Offset(result), 4, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PeekLong = result
End Function

Function PokeLong& (process As String, address As Unsigned Offset, value As Long)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = WriteProcessMemory(hProcess, address, Offset(value), 4, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PokeLong = memo
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = WriteProcessMemory(hProcess, address, Offset(value), 4, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PokeLong = memo
End Function

Function PeekUnsignedLong~& (process As String, address As Unsigned Offset)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Unsigned Long result
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = ReadProcessMemory(hProcess, address, Offset(result), 4, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PeekUnsignedLong = result
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = ReadProcessMemory(hProcess, address, Offset(result), 4, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PeekUnsignedLong = result
End Function

Function PokeUnsignedLong& (process As String, address As Unsigned Offset, value As Unsigned Long)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = WriteProcessMemory(hProcess, address, Offset(value), 4, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PokeUnsignedLong = memo
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = WriteProcessMemory(hProcess, address, Offset(value), 4, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PokeUnsignedLong = memo
End Function

Function PeekInt64&& (process As String, address As Unsigned Offset)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo
    Dim As Integer64 result
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = ReadProcessMemory(hProcess, address, Offset(result), 8, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PeekInt64 = result
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = ReadProcessMemory(hProcess, address, Offset(result), 8, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PeekInt64 = result
End Function

Function PokeInt64& (process As String, address As Unsigned Offset, value As Integer64)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = WriteProcessMemory(hProcess, address, Offset(value), 8, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PokeInt64 = memo
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = WriteProcessMemory(hProcess, address, Offset(value), 8, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PokeInt64 = memo
End Function

Function PeekUnsignedInt64~&& (process As String, address As Unsigned Offset)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo
    Dim As Unsigned Integer64 result
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = ReadProcessMemory(hProcess, address, Offset(result), 8, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PeekUnsignedInt64 = result
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = ReadProcessMemory(hProcess, address, Offset(result), 8, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PeekUnsignedInt64 = result
End Function

Function PokeUnsignedInt64& (process As String, address As Unsigned Offset, value As Unsigned Integer64)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            memo = WriteProcessMemory(hProcess, address, Offset(value), 8, 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PokeUnsignedInt64 = memo
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                memo = WriteProcessMemory(hProcess, address, Offset(value), 8, 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PokeUnsignedInt64 = memo
End Function

Function PeekString$ (process As String, address As Unsigned Offset)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As String result
    Dim As Long memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            result = Space$(strlen(address))
            memo = ReadProcessMemory(hProcess, address, Offset(result), Len(result), 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PeekString = result
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                result = Space$(strlen(address))
                memo = ReadProcessMemory(hProcess, address, Offset(result), Len(result), 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PeekString = result
End Function

Function PokeString& (process As String, address As Unsigned Offset, value As String)
    Dim As Offset hProcessSnap, hProcess
    Dim As PROCESSENTRY32 pe32
    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    pe32.dwSize = Len(pe32)
    Dim As Long lenaddress: lenaddress = strlen(address)
    Dim As Long i, memo
    If Process32First(hProcessSnap, Offset(pe32)) Then
        If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
            hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
            If lenaddress > Len(value) Then
                For i = 1 To lenaddress
                    value = value + Chr$(0)
                Next
            End If
            memo = WriteProcessMemory(hProcess, address, Offset(value), Len(value), 0)
            CloseHandle hProcessSnap
            CloseHandle hProcess
            PokeString = memo
            Exit Function
        End If
        While Process32Next(hProcessSnap, Offset(pe32))
            If StrCmp(Left$(pe32.szExeFile, InStr(pe32.szExeFile, ".exe" + Chr$(0)) + 3), process) = 0 Then
                hProcess = OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION Or PROCESS_VM_WRITE Or PROCESS_VM_OPERATION, TOM_FALSE, pe32.th32ProcessID)
                If lenaddress > Len(value) Then
                    For i = 1 To lenaddress
                        value = value + Chr$(0)
                    Next
                End If
                memo = WriteProcessMemory(hProcess, address, Offset(value), Len(value), 0)
                Exit While
            End If
        Wend
    End If
    CloseHandle hProcessSnap
    CloseHandle hProcess
    PokeString = memo
End Function
'End $INCLUDE
